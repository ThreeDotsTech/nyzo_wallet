// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart' as material;

// Package imports:
import 'package:cryptography/helpers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hex/hex.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:pinenacl/ed25519.dart' as ed25519;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_encryption/string_encryption.dart';

// Project imports:
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/CycleTransaction.dart';
import 'package:nyzo_wallet/Data/CycleTransactionSignature.dart';
import 'package:nyzo_wallet/Data/NFTAddressInstances.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/Token.dart';
import 'package:nyzo_wallet/Data/TokensBalancesResponse.dart';
import 'package:nyzo_wallet/Data/TokensListResponse.dart';
import 'package:nyzo_wallet/Data/TokensTransactionsResponse.dart';
import 'package:nyzo_wallet/Data/TransactionsSinceResponse.dart';
import 'package:nyzo_wallet/Data/Verifier.dart';
import 'package:nyzo_wallet/Data/WatchedAddress.dart';
import 'NyzoMessage.dart';
import 'Transaction.dart';
import 'TransactionMessage.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final PlatformStringCryptor crypto = PlatformStringCryptor();
final Random r = Random.secure();
const int CycleTransactionSignature47 = 47;
const int CycleTransactionSignatureResponse48 = 48;

Future<bool> checkWallet() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool flag;
  final String? values = prefs.getString('pubKey');
  if (values == null) {
    flag = false;
  } else {
    flag = true;
  }
  return flag;
}

Future createNewWallet(String password) async {
  final SharedPreferences prefs = await SharedPreferences
      .getInstance(); //Create a Shared Preferences instance to save balance
  prefs.setDouble('balance', 0.0);
  prefs.setBool('sentinel', false);
  final Uint8List privKey = Uint8List(32);

  //Generates a 32 bytes array to use as SEED (Crypto Secure)
  fillBytesWithSecureRandom(privKey);
  final ed25519.SigningKey signingKey = ed25519.SigningKey(seed: privKey);
  final Uint8List pubBuf = signingKey.publicKey.toUint8List();

  /*here we Store our keys in the device, Secure_storage encrypts and decrypts the content when reading and saving 
  so we dont need to take care of security, anyhow, Private key is encrypted again using user's password
  */
  final String? salt = await crypto.generateSalt(); //Generate the Salt value
  final String? key = await crypto.generateKeyFromPassword(
      password, salt!); //Get the key to encrypt our Nyzo Private key
  final String? encryptedPrivKey = await crypto.encrypt(HEX.encode(privKey),
      key!); // We encrypt the private key using password and salt
  //Now we store the values in the device using secure_storage
  await _storage.write(key: 'salt', value: salt);
  await _storage.write(key: 'privKey', value: encryptedPrivKey);
  // We take the values starting from index 1 to get rid of the two leading '0's (pubKey)
  prefs.setString('pubKey', HEX.encode(pubBuf));
  await _storage.write(key: 'Password', value: password);
  setNightModeValue(true);
  setWatchSentinels(false);
  prefs.setBool('nigthMode', true);
  return [HEX.encode(privKey), HEX.encode(pubBuf)];
}

Future<bool> importWallet(String nyzoString, String password) async {
  Uint8List hexStringAsUint8Array(String identifier) {
    identifier = identifier.split('-').join('');
    final Uint8List array = Uint8List((identifier.length / 2).floor());
    for (int i = 0; i < array.length; i++) {
      array[i] = HEX.decode(identifier.substring(i * 2, i * 2 + 2))[0];
    }
    return array;
  }

  final String privateKeyAsString =
      HEX.encode(NyzoStringEncoder.decode(nyzoString).getBytes());

  final SharedPreferences prefs = await SharedPreferences
      .getInstance(); //Create a Shared Preferences instance to save balance and pubKey
  setNightModeValue(true);
  setWatchSentinels(false);
  prefs.setDouble('balance', 0.0);
  prefs.setBool('sentinel', false);
  final Uint8List privateKey = hexStringAsUint8Array(privateKeyAsString);
  final ed25519.SigningKey signingKey = ed25519.SigningKey(seed: privateKey);
  final Uint8List pubBuf = signingKey.publicKey.toUint8List();

  /*here we Store our keys in the device, Secure_storage encrypts and decrypts the content when reading and saving 
  so we dont need to take care of security, anyhow, Private key is encrypted again using user's password
  */
  final String? salt = await crypto.generateSalt(); //Generate the Salt value
  final String? key = await crypto.generateKeyFromPassword(
      password, salt!); //Get the key to encrypt our Nyzo Private key
  final String? encryptedPrivKey = await crypto.encrypt(HEX.encode(privateKey),
      key!); // We encrypt the private key using password and salt
  //Now we store the values in the device using secure_storage
  await _storage.write(key: 'salt', value: salt);
  await _storage.write(key: 'privKey', value: encryptedPrivKey);
  // We take the values starting from index 1 to get  rid of the two leading '0's (pubKey)
  prefs.setString('pubKey', HEX.encode(pubBuf));
  await _storage.write(key: 'Password', value: password);
  return true;
}

Future<String> getAddress() async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  final String _address = _prefs.getString('pubKey') ?? '';
  return _address;
}

Future<double> getSavedBalance() async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  final double? _address = _prefs.getDouble('balance')!;
  return _address!;
}

Future<void> setSavedBalance(double balance) async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setDouble('balance', balance);
}

Future<double> getBalance(String address) async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  double _balance = _prefs.getDouble('balance') ?? 0.0;
  final String url = 'https://nyzo.co/walletRefresh?id=' + address;
  try {
    final http.Response response = await http.get(Uri.parse(url), headers: {
      'accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language':
          'en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2',
      'Connection': 'keep-alive',
      'DNT': '1',
      'Referer': 'https://nyzo.co/wallet',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36',
    });
    final balanceMicronyzos =
        await json.decode(response.body)['balanceMicronyzos'];
    _balance = double.parse(balanceMicronyzos.toString());
  } catch (e) {
//TODO: Correct error handling
  }
  return _balance;
}

Future<List<Token>> getTokensBalance(String address) async {
  final List<Token> tokensList = List<Token>.empty(growable: true);

  final HttpClient httpClient = HttpClient();
  try {
    final HttpClientRequest request = await httpClient
        .getUrl(Uri.parse('https://tokens.nyzo.today/api/balances/' + address));
    request.headers.set('content-type', 'application/json');
    final HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      final String reply = await response.transform(utf8.decoder).join();
      final TokensBalancesResponse tokensBalanceGetResponse =
          tokensBalancesResponseFromJson(reply);

      for (int i = 0; i < tokensBalanceGetResponse.tokensList!.length; i++) {
        final Token token = Token(
            isNFT: false,
            name: tokensBalanceGetResponse.tokensList![i].name,
            uid: '',
            amount: tokensBalanceGetResponse.tokensList![i].amount,
            comment: tokensBalanceGetResponse.tokensList![i].comment);
        if (token.amount! > 0) {
          tokensList.add(token);
        }
      }
    }
  } catch (e) {}
  return tokensList;
}

Future<List<Token>> getNFTBalance(String address) async {
  final List<Token> nftsList = List<Token>.empty(growable: true);

  final HttpClient httpClient = HttpClient();
  try {
    final HttpClientRequest request = await httpClient.getUrl(Uri.parse(
        'https://tokens.nyzo.today/api/nft_address_instances/' + address));
    request.headers.set('content-type', 'application/json');
    final HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      final String reply = await response.transform(utf8.decoder).join();
      final List<NftAddressInstancesResponse> nftAddressInstancesListResponse =
          nftAddressInstancesResponseFromJson(reply);

      for (int i = 0; i < nftAddressInstancesListResponse.length; i++) {
        final Token nft = Token(
            isNFT: true,
            name: nftAddressInstancesListResponse[i].nftClass,
            uid: nftAddressInstancesListResponse[i].nftId,
            amount: 0,
            comment: '');
        nftsList.add(nft);
      }
    }
  } catch (e) {}
  return nftsList;
}

Future<TransactionsSinceResponse> getTransactionsSinceList(
    String address) async {
  TransactionsSinceResponse transactionsSinceResponse =
      TransactionsSinceResponse();
  final HttpClient httpClient = HttpClient();
  try {
    final HttpClientRequest request = await httpClient
        .getUrl(Uri.parse('https://nyzo.today/api/tx_since/0/' + address));
    request.headers.set('content-type', 'application/json');
    final HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      final String reply = await response.transform(utf8.decoder).join();
      transactionsSinceResponse = transactionsSinceResponseFromJson(reply);
      transactionsSinceResponse.txs =
          transactionsSinceResponse.txs!.reversed.toList();
    }
  } catch (e) {}
  return transactionsSinceResponse;
}

Future<List<TokensTransactionsResponse>> getTokensTransactionsList(
    String address) async {
  List<TokensTransactionsResponse> transactionsList =
      List<TokensTransactionsResponse>.empty(growable: true);

  final HttpClient httpClient = HttpClient();
  try {
    final HttpClientRequest request = await httpClient.getUrl(
        Uri.parse('https://tokens.nyzo.today/api/transactions/' + address));
    request.headers.set('content-type', 'application/json');
    final HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      final String reply = await response.transform(utf8.decoder).join();
      transactionsList = tokensTransactionsResponseFromJson(reply);
    }
  } catch (e) {}
  return transactionsList;
}

Future<Map<String, TokensListResponse>> getTokensList() async {
  Map<String, TokensListResponse>? tokensList;

  final HttpClient httpClient = HttpClient();
  try {
    final HttpClientRequest request = await httpClient
        .getUrl(Uri.parse('https://tokens.nyzo.today/api/tokens_list'));
    request.headers.set('content-type', 'application/json');
    final HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      final String reply = await response.transform(utf8.decoder).join();
      tokensList = tokensListResponseFromJson(reply);
    }
  } catch (e) {}
  return tokensList!;
}

Future<TokensListResponse> getTokenStructure(String tokenName) async {
  Map<String, TokensListResponse>? tokensList = await getTokensList();
  TokensListResponse tokensListResponse = TokensListResponse();
  tokensList.forEach((key, value) {
    if (key == tokenName) {
      tokensListResponse = value;
    }
  });
  return tokensListResponse;
}

Future<String> getPrivateKey(String password) async {
  final String? salt = await _storage.read(key: 'salt');
  final String? encryptedPrivKey = await _storage.read(key: 'privKey');
  //String encryptedPrivKey = prefs.getString("privKey");
  final String? key = await crypto.generateKeyFromPassword(
      password, salt!); //Get the key to encrypt our Nyzo Private key
  final String? privKey = await crypto.decrypt(encryptedPrivKey!, key!);
  return privKey!;
}

Future<List<Transaction>> getTransactions(String address) async {
  final List<Transaction> transactions =
      List<Transaction>.empty(growable: true);
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  final String _address = _prefs.getString('pubKey') ?? '';
  final String url = 'https://nyzo.co/walletRefresh?id=' + _address;
  try {
    final http.Response response = await http.get(Uri.parse(url), headers: {
      'accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language':
          'en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2',
      'Connection': 'keep-alive',
      'DNT': '1',
      'Referer': 'https://nyzo.co/wallet',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36',
    });
    final html = await json.decode(response.body)['creditsAndDebits'];
    final document = parse(html);

    final List<Element> transactionElementList =
        document.getElementsByTagName('tr');
    for (Element eachTransaction in transactionElementList) {
      if (eachTransaction.text != 'typeblockamountbalance') {
        final Transaction transaction = Transaction();
        if (eachTransaction.text.toString().contains('from')) {
          transaction.type = 'from';
        } else {
          transaction.type = 'to';
        }
        final List transactionSlice =
            eachTransaction.text.toString().split(' ');
        transaction.address = eachTransaction
            .children[0].children[0].attributes.values
            .toList()[0]
            .substring(11);
        transaction.block = transactionSlice[2]
            .toString()
            .split('(')[0]
            .split('∩')[0]
            .substring(transactionSlice[2]
                    .toString()
                    .split('(')[0]
                    .split('∩')[0]
                    .length -
                7);
        final List balanceSlice = eachTransaction.text.toString().split('∩');
        transaction.amount = double.parse(
            balanceSlice[1].toString().split('.')[0] +
                '.' +
                balanceSlice[1].toString().split('.')[1].substring(0, 6));
        transactions.add(transaction);
      }
    }

    return transactions;
  } catch (e) {}
  return transactions;
}

Uint8List byteArrayForEncodedString(String encodedString) {
  final List<String> characterLookup = ('0123456789' +
          'abcdefghijkmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNPQRSTUVWXYZ' +
          '-.~_')
      .split('');

  final Map<String, dynamic> characterToValueMap = {};

  for (int i = 0; i < characterLookup.length; i++) {
    characterToValueMap[characterLookup[i]] = i;
  }

  final int arrayLength = ((encodedString.length * 6 + 7) / 8).floor();

  final Uint8List array = Uint8List(arrayLength);
  for (int i = 0; i < arrayLength; i++) {
    final String leftCharacter = encodedString.split('')[(i * 8 / 6).floor()];
    final String rightCharacter =
        encodedString.split('')[(i * 8 / 6 + 1).floor()];

    final leftValue = characterToValueMap[leftCharacter];
    final rightValue = characterToValueMap[rightCharacter];
    final bitOffset = (i * 2) % 6;
    array[i] = (((leftValue << 6) + rightValue) >> 4 - bitOffset) & 0xff;
  }

  return array;
}

String encodedStringForByteArray(array) {
  final List<String> characterLookup = ('0123456789' +
          'abcdefghijkmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNPQRSTUVWXYZ' +
          '-.~_')
      .split('');

  final Map<String, dynamic> characterToValueMap = {};

  for (var i = 0; i < characterLookup.length; i++) {
    characterToValueMap[characterLookup[i]] = i;
  }
  var index = 0;
  var bitOffset = 0;
  var encodedString = '';
  while (index < array.length) {
    final leftByte = array[index] & 0xff;
    final rightByte = index < array.length - 1 ? array[index + 1] & 0xff : 0;

    final lookupIndex =
        (((leftByte << 8) + rightByte) >> (10 - bitOffset)) & 0x3f;
    encodedString += characterLookup[lookupIndex];

    if (bitOffset == 0) {
      bitOffset = 6;
    } else {
      index++;
      bitOffset -= 2;
    }
  }

  return encodedString;
}

encodeNyzoString(prefix, Uint8List? contentBytes) {
  final prefixBytes = byteArrayForEncodedString(prefix);

  final int checksumLength = 4 + (3 - (contentBytes!.length + 2) % 3) % 3;
  final int expandedLength = 4 + contentBytes.length + checksumLength;

  final expandedArray = Uint8List(expandedLength);
  for (var i = 0; i < prefixBytes.length; i++) {
    expandedArray[i] = prefixBytes[i];
  }
  expandedArray[3] = contentBytes.length;
  for (var i = 0; i < contentBytes.length; i++) {
    expandedArray[i + 4] = contentBytes[i];
  }

  final checksum =
      doubleSha256(expandedArray.sublist(0, 4 + contentBytes.length));
  for (var i = 0; i < checksumLength; i++) {
    expandedArray[expandedArray.length - checksumLength + i] = checksum[i];
  }

  return encodedStringForByteArray(expandedArray);
}

nyzoStringFromPrivateKey(String byteArray) {
  final Uint8List bytes = hexStringAsUint8Array(byteArray);
  return encodeNyzoString('key_', bytes);
}

nyzoStringFromPublicIdentifier(String byteArray) {
  final Uint8List bytes = hexStringAsUint8Array(byteArray);
  return encodeNyzoString('id__', bytes);
}

Future<String> _getPrivKey(String password) async {
  final String? encryptedprivKey = await _storage.read(key: 'privKey');
  final String? salt = await _storage.read(key: 'salt');
  final String? key = await crypto.generateKeyFromPassword(password, salt!);
  final String? privKey = await crypto.decrypt(encryptedprivKey!, key!);
  return privKey!;
}

Future<String> send(String password, String nyzoStringPiblicId, int amount,
    int balance, String data) async {
  final String account =
      HEX.encode(NyzoStringEncoder.decode(nyzoStringPiblicId).getBytes());
  final http.Client client = http.Client();
  final String? encryptedprivKey = await _storage.read(key: 'privKey');
  final String? salt = await _storage.read(key: 'salt');
  final String? key = await crypto.generateKeyFromPassword(password, salt!);
  final String? privKey = await crypto.decrypt(encryptedprivKey!, key!);
  final String walletPrivateSeed = await getPrivateKey(password);
  final String recipientIdentifier = account;
  final int balanceMicronyzos = balance;
  final int micronyzosToSend = amount;
  final String senderData = data;

  bool specifiedTransactionIsValid() {
    return walletPrivateSeed.length == 64 &&
        recipientIdentifier.length == 64 &&
        micronyzosToSend <= balanceMicronyzos;
  }

  Uint8List hexStringAsUint8Array(String identifier) {
    identifier = identifier.split('-').join('');
    final Uint8List array = Uint8List((identifier.length / 2).floor());
    for (int i = 0; i < array.length; i++) {
      array[i] = HEX.decode(identifier.substring(i * 2, i * 2 + 2))[0];
    }

    return array;
  }

  Future<NyzoMessage> fetchPreviousHash(String senderPrivateSeed) async {
    final NyzoMessage message = NyzoMessage();
    message.setType(NyzoMessage.PreviousHashRequest7);
    await message.sign(hexStringAsUint8Array(senderPrivateSeed));
    final NyzoMessage result =
        await message.send(hexStringAsUint8Array(privKey!), client);
    return result;
  }

  Future<NyzoMessage> submitTransaction(
      int timestamp,
      String senderPrivateSeed,
      previousHashHeight,
      previousBlockHash,
      recipientIdentifier,
      micronyzosToSend,
      senderData) async {
    final TransactionMessage transaction = TransactionMessage();
    transaction.setTimestamp(timestamp);
    transaction.setAmount(micronyzosToSend);
    transaction
        .setRecipientIdentifier(hexStringAsUint8Array(recipientIdentifier));
    transaction.setPreviousHashHeight(previousHashHeight);
    transaction.setPreviousBlockHash(previousBlockHash);
    transaction.setSenderData(senderData);
    await transaction.sign(hexStringAsUint8Array(senderPrivateSeed));
    final NyzoMessage message = NyzoMessage();
    message.setType(NyzoMessage.Transaction5);
    message.setContent(transaction);
    await message.sign(hexStringAsUint8Array(senderPrivateSeed));
    final NyzoMessage? result =
        await message.send(hexStringAsUint8Array(privKey!), client);
    return result!;
  }

  if (specifiedTransactionIsValid()) {
    final NyzoMessage result = await fetchPreviousHash(walletPrivateSeed);
    if (result.content == null ||
        result.content.height == null ||
        result.content.hash == null) {
    } else {
      if (result.content.height > 10000000000) {
      } else {
        final NyzoMessage result2 = await submitTransaction(
            result.timestamp! + 7000,
            walletPrivateSeed,
            result.content.height,
            result.content.hash,
            recipientIdentifier,
            micronyzosToSend,
            utf8.encode(senderData));
        if (result2.content == null) {
          return 'There was a problem communicating with the server. To protect yourself ' +
              'against possible coin theft, please wait to resubmit this transaction. Refer ' +
              'to the Nyzo white paper for full details on why this is necessary, how long ' +
              'you need to wait, and to understand how Nyzo provides stronger protection ' +
              'than other blockchains against this type of potential vulnerability.';
        } else {
          client.close();
          return result2.content.message;
        }
      }
    }
  } else {
    client.close();
    return 'Invalid Transaction';
  }
  client.close();
  return 'Something went wrong';
}

Uint8List? signBytes(List<int> bytes, Uint8List key) {
  final ed25519.SigningKey signingKey = ed25519.SigningKey(seed: key);
  final ed25519.SignatureBase sm =
      signingKey.sign(Uint8List.fromList(bytes)).signature;
  return Uint8List.fromList(sm);
}

sendMessage(NyzoMessage message) async {
  //Send NyzoMessage for the cycle transaction.
  final http.Client client = http.Client();
  final http.Response response = await client.post(
      Uri.parse('https://nyzo.co/messageCycleTransactionSignature'),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: message.getBytes(true));
  final dynamic list = json.decode(response.body);
  return list;
}

Future<dynamic> signTransaction(String? initiatorSignature,
    String? initiatorIdentifier, String? transactionBytes,
    {String? password, String? walletPrivateSeed}) async {
  walletPrivateSeed ??= await _getPrivKey(password!);

  final ed25519.SigningKey signingKey = walletPrivateSeed.length == 64
      ? ed25519.SigningKey(seed: hexStringAsUint8Array(walletPrivateSeed))
      : null!;
  if (signingKey == null) {
  } else {
    final signature = CycleTransactionSignature();
    signature
        .setTransactionInitiator(hexStringAsUint8Array(initiatorIdentifier!));
    signature.setIdentifier(signingKey.publicKey.toUint8List());
    signature.setSignature(signBytes(hexStringAsUint8Array(transactionBytes!),
        hexStringAsUint8Array(walletPrivateSeed)));

    final message = NyzoMessage();
    message.setType(CycleTransactionSignature47);
    message.setContent(signature);
    await message
        .sign(Uint8List.fromList(hexStringAsUint8Array(walletPrivateSeed)));

    return sendMessage(message);
  }
}

Future<List<Contact>> getContacts() async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  final String? _contactListJson = _prefs.getString('contactList');

  if (_contactListJson != null) {
    final List<Contact> _contactList = [];
    final List<dynamic> _contactListDeserialized =
        json.decode(_contactListJson);
    final int index = _contactListDeserialized.length;
    for (int i = 0; i < index; i++) {
      _contactList.add(Contact.fromJson(_contactListDeserialized[i]));
    }
    return _contactList;
  } else {
    return [];
  }
}

Future<Contact> getContact(String? address) async {
  final _prefs = await SharedPreferences.getInstance();
  final _contactListJson = _prefs.getString('contactList');
  const bool contactFound = false;
  if (_contactListJson != null) {
    final List<dynamic> _contactListDeserialized =
        json.decode(_contactListJson);
    final int index = _contactListDeserialized.length;
    for (var i = 0; i < index; i++) {
      final Contact _contact = Contact.fromJson(_contactListDeserialized[i]);
      if (_contact.address.toUpperCase() == address!.toUpperCase()) {
        return _contact;
      }
    }
    if (!contactFound) {
      throw Exception;
    }
  } else {
    throw Exception;
  }
}

Future<List<Verifier>> getVerifiers() async {
  final _prefs = await SharedPreferences.getInstance();
  final _verifiersListJson = _prefs.getString('verifiersList');

  if (_verifiersListJson != null) {
    final List<Verifier> _verifiersList = [];
    final List<dynamic> _verifiersListDeserialized =
        json.decode(_verifiersListJson);
    final int index = _verifiersListDeserialized.length;
    for (var i = 0; i < index; i++) {
      _verifiersList
          .add(await Verifier.fromJson(_verifiersListDeserialized[i]).update());
    }
    return _verifiersList;
  } else {
    return [];
  }
}

Future<List<WatchedAddress>> getWatchAddresses() async {
  final _prefs = await SharedPreferences.getInstance();
  final _watchAddressesListJson = _prefs.getString('watchAddressList');

  if (_watchAddressesListJson != null) {
    final List<WatchedAddress> _watchAddressesList = [];
    final List<dynamic> _watchAddressesListDeserialized =
        json.decode(_watchAddressesListJson);
    final int index = _watchAddressesListDeserialized.length;
    for (var i = 0; i < index; i++) {
      _watchAddressesList
          .add(WatchedAddress.fromJson(_watchAddressesListDeserialized[i]));
    }
    return _watchAddressesList;
  } else {
    return [];
  }
}

Future<bool> addContact(List<Contact> contactList, Contact contact) async {
  final _prefs = await SharedPreferences.getInstance();
  final _contactListJson = _prefs.getString('contactList');
  final List<Contact> _contactList = [];
  if (_contactListJson != null) {
    final List<dynamic> _contactListDeserialized =
        json.decode(_contactListJson);
    final int index = _contactListDeserialized.length;
    for (var i = 0; i < index; i++) {
      _contactList.add(Contact.fromJson(_contactListDeserialized[i]));
    }
    _contactList.add(contact);
  } else {
    _contactList.add(contact);
  }
  saveContacts(_contactList);
  return true;
}

Future<bool> addVerifier(Verifier verifier) async {
  final _prefs = await SharedPreferences.getInstance();
  final _verifiersListJson = _prefs.getString('verifiersList');
  final List<Verifier> _verifierstList = [];
  if (_verifiersListJson != null) {
    final List<dynamic> _verifiersListDeserialized =
        json.decode(_verifiersListJson);
    final int index = _verifiersListDeserialized.length;
    for (var i = 0; i < index; i++) {
      _verifierstList.add(Verifier.fromJson(_verifiersListDeserialized[i]));
    }
    _verifierstList.add(verifier);
  } else {
    _verifierstList.add(verifier);
  }
  await saveVerifier(_verifierstList);
  return true;
}

Future<bool> addWatchAddress(WatchedAddress watchedAddres) async {
  final _prefs = await SharedPreferences.getInstance();
  final _watchAddressAsJsonList = _prefs.getString('watchAddressList');
  final List<WatchedAddress> _watchAddressList = [];
  if (_watchAddressAsJsonList != null) {
    final List<dynamic> _watchAddressesDeserialized =
        json.decode(_watchAddressAsJsonList);
    final int index = _watchAddressesDeserialized.length;
    for (var i = 0; i < index; i++) {
      _watchAddressList
          .add(WatchedAddress.fromJson(_watchAddressesDeserialized[i]));
    }
    _watchAddressList.add(watchedAddres);
  } else {
    _watchAddressList.add(watchedAddres);
  }
  await saveWatchAddress(_watchAddressList);
  return true;
}

Future<bool> saveContacts(List<Contact> contactList) async {
  final _prefs = await SharedPreferences.getInstance();
  final List<dynamic> _contactsAsJsonList = [];
  for (var eachContact in contactList) {
    _contactsAsJsonList.add(json.encode(eachContact.toJson()));
  }
  _prefs.setString('contactList', _contactsAsJsonList.toString());
  return true;
}

Future<bool> saveVerifier(List<Verifier> verifierList) async {
  final _prefs = await SharedPreferences.getInstance();
  final List<dynamic> _verifiersAsJsonList = [];
  for (var eachVerifier in verifierList) {
    _verifiersAsJsonList.add(json.encode(eachVerifier.toJson()));
  }
  _prefs.setString('verifiersList', _verifiersAsJsonList.toString());
  return true;
}

Future<bool> saveWatchAddress(List<WatchedAddress> watchAddressList) async {
  final _prefs = await SharedPreferences.getInstance();
  final List<dynamic> _watchAddressAsJsonList = [];
  for (var eachVerifier in watchAddressList) {
    _watchAddressAsJsonList.add(json.encode(eachVerifier.toJson()));
  }
  _prefs.setString('watchAddressList', _watchAddressAsJsonList.toString());
  return true;
}

Future<void> deleteWallet() async {
  final pref = await SharedPreferences.getInstance();
  await pref.clear();
  await _storage.deleteAll();
}

Future<bool?> watchSentinels() async {
  final _prefs = await SharedPreferences.getInstance();
  return _prefs.getBool('sentinel');
}

Future<bool?> getNightModeValue() async {
  final _prefs = await SharedPreferences.getInstance();
  return _prefs.getBool('nigthMode');
}

Future<bool> setNightModeValue(bool value) async {
  final _prefs = await SharedPreferences.getInstance();
  return _prefs.setBool('nigthMode', value);
}

Future<void> setWatchSentinels(bool val) async {
  final _prefs = await SharedPreferences.getInstance();
  _prefs.setBool('sentinel', val);
}

Future<List<CycleTransaction>> getCycleTransactions() async {
  const String url = 'https://nyzo.co/cycleTransactions';
  final List<CycleTransaction> transactions = [];
  try {
    final http.Response response = await http.get(Uri.parse(url));
    final Document document = parse(response.body, encoding: 'utf-8');

    for (var eachTransaction
        in document.getElementsByClassName('transaction-table')) {
      //for each transaction

      final transaction = CycleTransaction();
      final List valuesList = eachTransaction.getElementsByClassName(
          'transaction-table-cell transaction-table-cell-right');
      transaction.initiatorNickname = valuesList[0].text;
      transaction.initiatorId = valuesList[1].text;
      transaction.initiatorIdAsNyzoString = valuesList[2].text;
      transaction.ammount = valuesList[3].text;
      transaction.receiverNickname = valuesList[4].text;
      transaction.receiverId = valuesList[5].text;
      transaction.receiverIdAsNyzoString = valuesList[6].text;
      transaction.senderData = valuesList[7].text;
      transaction.initiatorSignature = valuesList[8].text;
      transaction.totalVotes = valuesList[9].text;
      transaction.votesAgainst = valuesList[10].text;
      transaction.votesForTransaction = valuesList[11].text;
      transactions.add(transaction);
    }
    document
        .getElementsByClassName('transaction-table')[0]
        .getElementsByClassName(
            'transaction-table-cell transaction-table-cell-right')[1]
        .text;
    return transactions;
  } catch (e) {
    return null!;
  }
}

Future<Verifier> getVerifierStatus(Verifier verifier) async {
  final String url = 'https://nyzo.co/status?id=' + verifier.id!;
  try {
    final http.Response response = await http.get(Uri.parse(url), headers: {
      'accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language':
          'en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2',
      'Connection': 'keep-alive',
      'DNT': '1',
      'Referer': 'https://nyzo.co/wallet',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36',
    });
    //var lmao = await json.decode(response.body)["verifier"];
    final Document document = parse(response.body, encoding: 'utf-8');
    List? attributeElementList;
    final Map<String, String>? verifierMap = <String, String>{};

    try {
      if (document
          .getElementsByClassName('verifier verifier-not-producing')
          .isNotEmpty) {
        attributeElementList =
            document.getElementsByClassName('verifier verifier-not-producing');
        verifier.status = Verifier.NOT_PRODUCING;
        verifier.iconBlack = material.Image.asset('images/NotProducing.png');
        verifier.iconWhite = material.Image.asset(
          'images/NotProducing.png',
          color: material.Colors.white,
        );
      }
    } catch (e) {}
    try {
      if (document
          .getElementsByClassName('verifier verifier-active')
          .isNotEmpty) {
        attributeElementList =
            document.getElementsByClassName('verifier verifier-active');
        verifier.status = Verifier.ACTIVE;
        verifier.iconBlack = material.Image.asset('images/normal.png');
        verifier.iconWhite = material.Image.asset('images/normal.png',
            color: material.Colors.white);
      }
    } catch (e) {}
    try {
      if (document
          .getElementsByClassName('verifier verifier-inactive')
          .isNotEmpty) {
        attributeElementList =
            document.getElementsByClassName('verifier verifier-inactive');
        verifier.status = Verifier.COMMUNICATION_PROBLEM;
        verifier.iconBlack =
            material.Image.asset('images/communicationProblem.png');
        verifier.iconWhite = material.Image.asset(
            'images/communicationProblem.png',
            color: material.Colors.white);
      }
    } catch (e) {}
    try {
      if (document
          .getElementsByClassName('verifier verifier-warning')
          .isNotEmpty) {
        attributeElementList =
            document.getElementsByClassName('verifier verifier-warning');
        verifier.status = Verifier.TRACKING_PROBLEM;
        verifier.iconBlack = material.Image.asset('images/trackingProblem.png');
        verifier.iconWhite = material.Image.asset('images/trackingProblem.png',
            color: material.Colors.white);
      }
    } catch (e) {}

    for (Element eachAttribute in attributeElementList!) {
      for (String eachAttribute in eachAttribute.innerHtml.split('<br>')) {
        final List<String> tempAttributeList = eachAttribute.split(':');
        if (tempAttributeList.length == 2) {
          verifierMap![tempAttributeList[0]] = tempAttributeList[1];
        }
      }
      verifier.isValid = true;
    }

    verifier.nickname = verifierMap!['nickname'];
    verifier.iPAddress = verifierMap['IP address'];
    verifier.lastQueried = verifierMap['last queried'];
    verifier.version = verifierMap['version'];
    verifier.mesh = verifierMap['mesh'];
    verifier.cycleLength = verifierMap['cycle length'];
    verifier.transactions = verifierMap['transactions'];
    verifier.retentionEdge = verifierMap['retention edge'];
    verifier.trailingEdge = verifierMap['trailing edge'];
    verifier.frozenEdge = verifierMap['frozen edge'];
    verifier.openEdge = verifierMap['open edge'];
    verifier.blocksCT = verifierMap['blocks transmitted/created'];
    verifier.blockVote = verifierMap['block vote'];
    verifier.lastRemovalHeight = verifierMap['last removal height'];
    verifier.receivingUDP = verifierMap['receiving UDP'];
    verifier.transactions == '0' ? verifier.balance = 0 : verifier.balance = 0;
    verifier.blocksCT!.split('/')[0] != ' 0'
        ? verifier.inCicle = true
        : verifier.inCicle = false;

    return verifier;
  } catch (e) {}
  return verifier;
}

Future<List<List<String>>> getBalanceList() async {
  List<Element> attributeElementList;
  final List<List<String>> balanceList = [];
  const String url = 'https://nyzo.co/balanceListPlain/L';
  try {
    http.head(Uri.parse(url));
    final http.Response response = await http.get(Uri.parse(url));
    final Document document = parse(response.body, encoding: 'utf-8');
    attributeElementList = document.getElementsByTagName('div');
    attributeElementList = attributeElementList[1].getElementsByTagName('p');
    for (var eachElement in attributeElementList) {
      balanceList.add(eachElement.text.split(' '));
    }
    for (List<String> eachList in balanceList) {
      eachList.removeWhere((String value) {
        return value == '';
      });
    }
    for (var eachAddress in balanceList) {
      eachAddress[0] = eachAddress[0].split('-').join();
    }
    return balanceList;
  } catch (e) {}
  return balanceList;
}
