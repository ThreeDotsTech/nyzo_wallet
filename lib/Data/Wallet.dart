import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart' as material;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:http/http.dart' as http;
import "package:hex/hex.dart";
import 'package:nyzo_wallet/Data/CycleTransaction.dart';
import 'package:nyzo_wallet/Data/CycleTransactionSignature.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/Verifier.dart';
import 'package:nyzo_wallet/Data/watchedAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'Transaction.dart';
import 'NyzoMessage.dart';
import 'dart:typed_data';
import 'TransactionMessage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:nyzo_wallet/Data/Contact.dart';

final _storage = new FlutterSecureStorage();
final crypto = new PlatformStringCryptor();
final r = new Random.secure();
const CycleTransactionSignature47 = 47;
const CycleTransactionSignatureResponse48 = 48;

Future<bool> checkWallet() async {
  final prefs = await SharedPreferences.getInstance();
  bool flag;
  String values = prefs.getString('pubKey');
  if (values == null) {
    flag = false;
  } else {
    flag = true;
  }
  return flag;
}

Future createNewWallet(String password) async {
  final prefs = await SharedPreferences
      .getInstance(); //Create a Shared Preferences instance to save balance
  prefs.setDouble('balance', 0.0);
  prefs.setBool('sentinel', false);
  PrivateKey privKey;
  KeyPair keyPair;
  PublicKey pubKey;
  //Generates a 32 bytes array to usa as SEED (Crypto Secure)
  privKey = PrivateKey.randomBytes(32);
  //Creates a KeyPair from the generated Seed
  keyPair = ed25519.newKeyPairFromSeedSync(privKey);
  //Set the Public Key
  pubKey = keyPair.publicKey;

  /*here we Store our keys in the device, Secure_storage encrypts adn decrypts the content when reading and saving 
  so we dont need to take care of security, anyhow, Private key is encrypted again using user's password
  */
  final String salt = await crypto.generateSalt(); //Generate the Salt value
  final String key = await crypto.generateKeyFromPassword(
      password, salt); //Get the key to encrypt our Nyzo Private key
  final String encryptedPrivKey = await crypto.encrypt(
      HEX.encode(await privKey.extract()),
      key); // We encrypt the private key using password and salt
  //Now we store the values in the device using secure_storage
  await _storage.write(key: "salt", value: salt);
  await _storage.write(key: "privKey", value: encryptedPrivKey);
  // We take the values starting from index 1 to get  rid of the two leading '0's (pubKey)
  prefs.setString('pubKey', HEX.encode(pubKey.bytes));
  await _storage.write(key: "Password", value: password);
  setNightModeValue(false);
  setWatchSentinels(false);
  addContact(
      [],
      Contact("id__88UT5xYF0PY5eN2utfiaVSqTq36V9Tg3PS.eurTw5k_QYnHKVtQG",
          "Donate", "Help us develop this wallet."));
  return [HEX.encode(await privKey.extract()), HEX.encode(pubKey.bytes)];
}

Future<bool> importWallet(String nyzoString, String password) async {
  Uint8List hexStringAsUint8Array(String identifier) {
    identifier = identifier.split('-').join('');
    var array = new Uint8List((identifier.length / 2).floor());
    for (var i = 0; i < array.length; i++) {
      array[i] = HEX.decode(identifier.substring(i * 2, i * 2 + 2))[0];
    }
    return array;
  }

  String privateKeyAsString =
      HEX.encode(NyzoStringEncoder.decode(nyzoString).getBytes());

  final prefs = await SharedPreferences
      .getInstance(); //Create a Shared Preferences instance to save balance and pubKey
  setNightModeValue(false);
  setWatchSentinels(false);
  prefs.setDouble('balance', 0.0);
  prefs.setBool('sentinel', false);
  PrivateKey privateKey = PrivateKey(hexStringAsUint8Array(privateKeyAsString));
  KeyPair keyPair = ed25519.newKeyPairFromSeedSync(
      privateKey); //Creates a KeyPair from the generated Seed
  PublicKey pubKey = keyPair.publicKey; //Set the Public Key

  /*here we Store our keys in the device, Secure_storage encrypts adn decrypts the content when reading and saving 
  so we dont need to take care of security, anyhow, Private key is encrypted again using user's password
  */
  final String salt = await crypto.generateSalt(); //Generate the Salt value
  final String key = await crypto.generateKeyFromPassword(
      password, salt); //Get the key to encrypt our Nyzo Private key
  final String encryptedPrivKey = await crypto.encrypt(
      HEX.encode(await privateKey.extract()),
      key); // We encrypt the private key using password and salt
  //Now we store the values in the device using secure_storage
  await _storage.write(key: "salt", value: salt);
  await _storage.write(key: "privKey", value: encryptedPrivKey);
  // We take the values starting from index 1 to get  rid of the two leading '0's (pubKey)
  prefs.setString('pubKey', HEX.encode(pubKey.bytes));
  await _storage.write(key: "Password", value: password);
  addContact(
      [],
      Contact("id__88UT5xYF0PY5eN2utfiaVSqTq36V9Tg3PS.eurTw5k_QYnHKVtQG",
          "Donate", "Help us develop this wallet."));

  return true;
}

Future getAddress() async {
  final _prefs = await SharedPreferences.getInstance();
  final _address = _prefs.getString('pubKey') ?? '';
  return _address;
}

Future<double> getSavedBalance() async {
  final _prefs = await SharedPreferences.getInstance();
  final _address = _prefs.getDouble('balance') ?? '';
  return _address;
}

void setSavedBalance(double balance) async {
  final _prefs = await SharedPreferences.getInstance();
  _prefs.setDouble('balance', balance);
}

Future getBalance(String address) async {
  final _prefs = await SharedPreferences.getInstance();
  double _balance = _prefs.getDouble('balance') ?? 70.0;
  String url = "https://nyzo.co/walletRefresh?id=" + address;
  try {
    http.Response response = await http.get(url, headers: {
      "accept": "*/*",
      "Accept-Encoding": 'gzip, deflate, br',
      "Accept-Language":
          "en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2",
      "Connection": "keep-alive",
      "DNT": "1",
      "Referer": "https://nyzo.co/wallet",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36",
    });
    var lmao = await json.decode(response.body)["balanceMicronyzos"];
    _balance = double.parse(lmao.toString());
    return lmao;
  } catch (e) {
//TODO: Correct error handling
  }
  return _balance;
}

Future<String> getPrivateKey(String password) async {
  String salt = await _storage.read(key: "salt");
  String encryptedPrivKey = await _storage.read(key: "privKey");
  //String encryptedPrivKey = prefs.getString("privKey");
  final String key = await crypto.generateKeyFromPassword(
      password, salt); //Get the key to encrypt our Nyzo Private key
  String privKey = await crypto.decrypt(encryptedPrivKey, key);
  return privKey;
}

Future<List> getTransactions(String address) async {
  List<Transaction> transactions = new List();
  final _prefs = await SharedPreferences.getInstance();
  final _address = _prefs.getString('pubKey') ?? '';
  String url = "https://nyzo.co/walletRefresh?id=" + _address;
  try {
    http.Response response = await http.get(url, headers: {
      "accept": "*/*",
      "Accept-Encoding": 'gzip, deflate, br',
      "Accept-Language":
          "en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2",
      "Connection": "keep-alive",
      "DNT": "1",
      "Referer": "https://nyzo.co/wallet",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36",
    });
    var html = await json.decode(response.body)["creditsAndDebits"];
    var document = parse(html);

    List<Element> transactionElementList = document.getElementsByTagName("tr");
    for (Element eachTransaction in transactionElementList) {
      if (eachTransaction.text != 'typeblockamountbalance') {
        Transaction transaction = new Transaction();
        if (eachTransaction.text.toString().contains("from")) {
          transaction.type = "from";
        } else {
          transaction.type = "to";
        }
        List transactionSlice = eachTransaction.text.toString().split(" ");
        transaction.address = eachTransaction
            .children[0].children[0].attributes.values
            .toList()[0]
            .substring(11);
        transaction.block = transactionSlice[2]
            .toString()
            .split("(")[0]
            .split("∩")[0]
            .substring(transactionSlice[2]
                    .toString()
                    .split("(")[0]
                    .split("∩")[0]
                    .length -
                7);
        List balanceSlice = eachTransaction.text.toString().split("∩");
        transaction.amount = double.parse(
            balanceSlice[1].toString().split(".")[0] +
                "." +
                balanceSlice[1].toString().split(".")[1].substring(0, 6));
        transactions.add(transaction);
      }
    }

    return transactions;
  } catch (e) {
    //print(e.toString());
  }
  return transactions;
}

byteArrayForEncodedString(String encodedString) {
  var characterLookup = ('0123456789' +
          'abcdefghijkmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNPQRSTUVWXYZ' +
          '-.~_')
      .split('');

  Map<String, dynamic> characterToValueMap = Map();

  for (var i = 0; i < characterLookup.length; i++) {
    characterToValueMap[characterLookup[i]] = i;
  }

  var arrayLength = ((encodedString.length * 6 + 7) / 8).floor();

  var array = new Uint8List(arrayLength);
  for (var i = 0; i < arrayLength; i++) {
    var leftCharacter = encodedString.split('')[(i * 8 / 6).floor()];
    var rightCharacter = encodedString.split('')[(i * 8 / 6 + 1).floor()];

    var leftValue = characterToValueMap[leftCharacter];
    var rightValue = characterToValueMap[rightCharacter];
    var bitOffset = (i * 2) % 6;
    array[i] = ((((leftValue << 6) + rightValue) >> 4 - bitOffset) & 0xff);
  }

  return array;
}

encodedStringForByteArray(array) {
  var characterLookup = ('0123456789' +
          'abcdefghijkmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNPQRSTUVWXYZ' +
          '-.~_')
      .split('');

  Map<String, dynamic> characterToValueMap = Map();

  for (var i = 0; i < characterLookup.length; i++) {
    characterToValueMap[characterLookup[i]] = i;
  }
  var index = 0;
  var bitOffset = 0;
  var encodedString = "";
  while (index < array.length) {
    var leftByte = array[index] & 0xff;
    var rightByte = index < array.length - 1 ? array[index + 1] & 0xff : 0;

    var lookupIndex =
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

encodeNyzoString(prefix, contentBytes) {
  var prefixBytes = byteArrayForEncodedString(prefix);

  var checksumLength = 4 + (3 - (contentBytes.length + 2) % 3) % 3;
  var expandedLength = 4 + contentBytes.length + checksumLength;

  var expandedArray = new Uint8List(expandedLength);
  for (var i = 0; i < prefixBytes.length; i++) {
    expandedArray[i] = prefixBytes[i];
  }
  expandedArray[3] = contentBytes.length;
  for (var i = 0; i < contentBytes.length; i++) {
    expandedArray[i + 4] = contentBytes[i];
  }

  var checksum =
      doubleSha256(expandedArray.sublist(0, 4 + contentBytes.length));
  for (var i = 0; i < checksumLength; i++) {
    expandedArray[expandedArray.length - checksumLength + i] = checksum[i];
  }

  return encodedStringForByteArray(expandedArray);
}

nyzoStringFromPrivateKey(byteArray) {
  Uint8List bytes = hexStringAsUint8Array(byteArray);
  return encodeNyzoString('key_', bytes);
}

nyzoStringFromPublicIdentifier(byteArray) {
  Uint8List bytes = hexStringAsUint8Array(byteArray);
  return encodeNyzoString('id__', bytes);
}

Future<String> _getPrivKey(String password) async {
  String encryptedprivKey = await _storage.read(key: "privKey");
  String salt = await _storage.read(key: "salt");
  final String key = await crypto.generateKeyFromPassword(password, salt);
  final String privKey = await crypto.decrypt(encryptedprivKey, key);
  return privKey;
}

Future<String> send(String password, String nyzoStringPiblicId, int amount,
    int balance, String data) async {
  String account =
      HEX.encode(NyzoStringEncoder.decode(nyzoStringPiblicId).getBytes());
  http.Client client = new http.Client();
  String encryptedprivKey = await _storage.read(key: "privKey");
  String salt = await _storage.read(key: "salt");
  final String key = await crypto.generateKeyFromPassword(password, salt);
  final String privKey = await crypto.decrypt(encryptedprivKey, key);
  String walletPrivateSeed = await getPrivateKey(password);
  String recipientIdentifier = account;
  int balanceMicronyzos = balance;
  int micronyzosToSend = amount;
  String senderData = data;

  bool specifiedTransactionIsValid() {
    return walletPrivateSeed.length == 64 &&
        recipientIdentifier.length == 64 &&
        micronyzosToSend > 0 &&
        micronyzosToSend <= balanceMicronyzos;
  }

  Uint8List hexStringAsUint8Array(String identifier) {
    identifier = identifier.split('-').join('');
    var array = new Uint8List((identifier.length / 2).floor());
    for (var i = 0; i < array.length; i++) {
      array[i] = HEX.decode(identifier.substring(i * 2, i * 2 + 2))[0];
    }

    return array;
  }

  Future<NyzoMessage> fetchPreviousHash(senderPrivateSeed) async {
    var message = new NyzoMessage();
    message.setType(NyzoMessage.PreviousHashRequest7);
    message.sign(PrivateKey(hexStringAsUint8Array(senderPrivateSeed)));
    NyzoMessage result =
        await message.send(PrivateKey(hexStringAsUint8Array(privKey)), client);
    return result;
  }

  Future<NyzoMessage> submitTransaction(
      timestamp,
      senderPrivateSeed,
      previousHashHeight,
      previousBlockHash,
      recipientIdentifier,
      micronyzosToSend,
      senderData) async {
    var transaction = new TransactionMessage();
    transaction.setTimestamp(timestamp);
    transaction.setAmount(micronyzosToSend);
    transaction
        .setRecipientIdentifier(hexStringAsUint8Array(recipientIdentifier));
    transaction.setPreviousHashHeight(previousHashHeight);
    transaction.setPreviousBlockHash(previousBlockHash);
    transaction.setSenderData(senderData);
    transaction.sign(PrivateKey(hexStringAsUint8Array(senderPrivateSeed)));
    var message = new NyzoMessage();
    message.setType(NyzoMessage.Transaction5);
    message.setContent(transaction);
    message.sign(PrivateKey(hexStringAsUint8Array(senderPrivateSeed)));
    NyzoMessage result =
        await message.send(PrivateKey(hexStringAsUint8Array(privKey)), client);
    return result;
  }

  if (specifiedTransactionIsValid()) {
    NyzoMessage result = await fetchPreviousHash(walletPrivateSeed);
    if (result == null ||
        result.content == null ||
        result.content.height == null ||
        result.content.hash == null) {
    } else {
      if (result.content.height > 10000000000) {
      } else {
        NyzoMessage result2 = await submitTransaction(
            result.timestamp + 7000,
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
    return "Invalid Transaction";
  }
  client.close();
  return "Something went wrong";
}

Uint8List signBytes(List<int> bytes, PrivateKey key) {
  KeyPair keyPair = ed25519.newKeyPairFromSeedSync(key);
  Signature signature = ed25519.signSync(bytes, keyPair);

  return signature.bytes;
}

sendMessage(NyzoMessage message) async {
  //Send NyzoMessage for the cycle transaction.
  http.Client client = new http.Client();
  http.Response response =
      await client.post("https://nyzo.co/messageCycleTransactionSignature",
          headers: {
            "Content-Type": "application/octet-stream",
          },
          body: message.getBytes(true));
  dynamic list = json.decode(response.body);
  return list;
}

Future<dynamic> signTransaction(String initiatorSignature,
    String initiatorIdentifier, String transactionBytes,
    {String password, String walletPrivateSeed}) async {
  if (walletPrivateSeed == null) {
    walletPrivateSeed = await _getPrivKey(password);
  }

  KeyPair keyPair = walletPrivateSeed.length == 64
      ? ed25519.newKeyPairFromSeedSync(
          PrivateKey(hexStringAsUint8Array(walletPrivateSeed)))
      : null;
  if (keyPair == null) {
  } else {
    var signature = new CycleTransactionSignature();
    signature
        .setTransactionInitiator(hexStringAsUint8Array(initiatorIdentifier));
    signature.setIdentifier(keyPair.publicKey);
    signature.setSignature(
        signBytes(hexStringAsUint8Array(transactionBytes), keyPair.privateKey));

    var message = new NyzoMessage();
    message.setType(CycleTransactionSignature47);
    message.setContent(signature);
    message.sign(keyPair.privateKey);

    return sendMessage(message);
  }
}

Future<List<Contact>> getContacts() async {
  final _prefs = await SharedPreferences.getInstance();
  final _contactListJson = _prefs.getString('contactList');

  if (_contactListJson != null) {
    List<Contact> _contactList = [];
    List<dynamic> _contactListDeserialized = json.decode(_contactListJson);
    int index = _contactListDeserialized.length;
    for (var i = 0; i < index; i++) {
      _contactList.add(Contact.fromJson(_contactListDeserialized[i]));
    }
    return _contactList;
  } else {
    return [];
  }
}

Future<List<Verifier>> getVerifiers() async {
  final _prefs = await SharedPreferences.getInstance();
  final _verifiersListJson = _prefs.getString('verifiersList');

  if (_verifiersListJson != null) {
    List<Verifier> _verifiersList = [];
    List<dynamic> _verifiersListDeserialized = json.decode(_verifiersListJson);
    int index = _verifiersListDeserialized.length;
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
    List<WatchedAddress> _watchAddressesList = [];
    List<dynamic> _watchAddressesListDeserialized =
        json.decode(_watchAddressesListJson);
    int index = _watchAddressesListDeserialized.length;
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
  List<Contact> _contactList = [];
  if (_contactListJson != null) {
    List<dynamic> _contactListDeserialized = json.decode(_contactListJson);
    int index = _contactListDeserialized.length;
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
  List<Verifier> _verifierstList = [];
  if (_verifiersListJson != null) {
    List<dynamic> _verifiersListDeserialized = json.decode(_verifiersListJson);
    int index = _verifiersListDeserialized.length;
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
  List<WatchedAddress> _watchAddressList = [];
  if (_watchAddressAsJsonList != null) {
    List<dynamic> _watchAddressesDeserialized =
        json.decode(_watchAddressAsJsonList);
    int index = _watchAddressesDeserialized.length;
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
  List<dynamic> _contactsAsJsonList = [];
  for (var eachContact in contactList) {
    _contactsAsJsonList.add(json.encode(eachContact.toJson()));
  }
  _prefs.setString('contactList', _contactsAsJsonList.toString());
  return true;
}

Future<bool> saveVerifier(List<Verifier> verifierList) async {
  final _prefs = await SharedPreferences.getInstance();
  List<dynamic> _verifiersAsJsonList = [];
  for (var eachVerifier in verifierList) {
    _verifiersAsJsonList.add(json.encode(eachVerifier.toJson()));
  }
  _prefs.setString('verifiersList', _verifiersAsJsonList.toString());
  return true;
}

Future<bool> saveWatchAddress(List<WatchedAddress> watchAddressList) async {
  final _prefs = await SharedPreferences.getInstance();
  List<dynamic> _watchAddressAsJsonList = [];
  for (var eachVerifier in watchAddressList) {
    _watchAddressAsJsonList.add(json.encode(eachVerifier.toJson()));
  }
  _prefs.setString('watchAddressList', _watchAddressAsJsonList.toString());
  return true;
}

void deleteWallet() async {
  final pref = await SharedPreferences.getInstance();
  await pref.clear();
  await _storage.deleteAll();
}

Future<bool> watchSentinels() async {
  final _prefs = await SharedPreferences.getInstance();
  return _prefs.getBool('sentinel');
}

Future<bool> getNightModeValue() async {
  final _prefs = await SharedPreferences.getInstance();
  return _prefs.getBool('nigthMode');
}

Future<bool> setNightModeValue(bool value) async {
  final _prefs = await SharedPreferences.getInstance();
  return _prefs.setBool('nigthMode', value);
}

void setWatchSentinels(bool val) async {
  final _prefs = await SharedPreferences.getInstance();
  _prefs.setBool('sentinel', val);
}

Future<List<CycleTransaction>> getCycleTransactions() async {
  String url = "https://nyzo.co/cycleTransactions";
  List<CycleTransaction> transactions = [];
  try {
    http.Response response = await http.get(url);
    Document document = parse(response.body, encoding: "utf-8");

    for (var eachTransaction
        in document.getElementsByClassName("transaction-table")) {
      //for each transaction

      var transaction = CycleTransaction();
      List valuesList = eachTransaction.getElementsByClassName(
          "transaction-table-cell transaction-table-cell-right");
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
        .getElementsByClassName("transaction-table")[0]
        .getElementsByClassName(
            "transaction-table-cell transaction-table-cell-right")[1]
        .text;
    return transactions;
  } catch (e) {
    return null;
  }
}

Future<Verifier> getVerifierStatus(Verifier verifier) async {
  String url = "https://nyzo.co/status?id=" + verifier.id;
  try {
    http.Response response = await http.get(url, headers: {
      "accept": "*/*",
      "Accept-Encoding": 'gzip, deflate, br',
      "Accept-Language":
          "en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2",
      "Connection": "keep-alive",
      "DNT": "1",
      "Referer": "https://nyzo.co/wallet",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36",
    });
    //var lmao = await json.decode(response.body)["verifier"];
    Document document = parse(response.body, encoding: "utf-8");
    List attributeElementList;
    Map<String, String> verifierMap = Map<String, String>();

    try {
      if (document
              .getElementsByClassName("verifier verifier-not-producing")
              .length !=
          0) {
        attributeElementList =
            document.getElementsByClassName("verifier verifier-not-producing");
        verifier.status = Verifier.NOT_PRODUCING;
        verifier.iconBlack = material.Image.asset("images/NotProducing.png");
        verifier.iconWhite = material.Image.asset(
          "images/NotProducing.png",
          color: material.Colors.white,
        );
      }
    } catch (e) {}
    try {
      if (document.getElementsByClassName("verifier verifier-active").length !=
          0) {
        attributeElementList =
            document.getElementsByClassName("verifier verifier-active");
        verifier.status = Verifier.ACTIVE;
        verifier.iconBlack = material.Image.asset("images/normal.png");
        verifier.iconWhite = material.Image.asset("images/normal.png",
            color: material.Colors.white);
      }
    } catch (e) {}
    try {
      if (document
              .getElementsByClassName("verifier verifier-inactive")
              .length !=
          0) {
        attributeElementList =
            document.getElementsByClassName("verifier verifier-inactive");
        verifier.status = Verifier.COMMUNICATION_PROBLEM;
        verifier.iconBlack =
            material.Image.asset("images/communicationProblem.png");
        verifier.iconWhite = material.Image.asset(
            "images/communicationProblem.png",
            color: material.Colors.white);
      }
    } catch (e) {}
    try {
      if (document.getElementsByClassName("verifier verifier-warning").length !=
          0) {
        attributeElementList =
            document.getElementsByClassName("verifier verifier-warning");
        verifier.status = Verifier.TRACKING_PROBLEM;
        verifier.iconBlack = material.Image.asset("images/trackingProblem.png");
        verifier.iconWhite = material.Image.asset("images/trackingProblem.png",
            color: material.Colors.white);
      }
    } catch (e) {}

    for (Element eachAttribute in attributeElementList) {
      for (String eachAttribute in eachAttribute.innerHtml.split("<br>")) {
        List<String> tempAttributeList = eachAttribute.split(":");
        if (tempAttributeList.length == 2) {
          verifierMap[tempAttributeList[0]] = tempAttributeList[1];
        }
      }
      if (attributeElementList != null) {
        verifier.isValid = true;
      }
    }

    verifier.nickname = verifierMap["nickname"];
    verifier.iPAddress = verifierMap["IP address"];
    verifier.lastQueried = verifierMap["last queried"];
    verifier.version = verifierMap["version"];
    verifier.mesh = verifierMap["mesh"];
    verifier.cycleLength = verifierMap["cycle length"];
    verifier.transactions = verifierMap["transactions"];
    verifier.retentionEdge = verifierMap["retention edge"];
    verifier.trailingEdge = verifierMap["trailing edge"];
    verifier.frozenEdge = verifierMap["frozen edge"];
    verifier.openEdge = verifierMap["open edge"];
    verifier.blocksCT = verifierMap["blocks transmitted/created"];
    verifier.blockVote = verifierMap["block vote"];
    verifier.lastRemovalHeight = verifierMap["last removal height"];
    verifier.receivingUDP = verifierMap["receiving UDP"];
    verifier.transactions == "0" ? verifier.balance = 0 : verifier.balance = 0;
    verifier.blocksCT.split("/")[0] != " 0"
        ? verifier.inCicle = true
        : verifier.inCicle = false;

    return verifier;
  } catch (e) {}
  return verifier;
}

Future<List<List<String>>> getBalanceList() async {
  List<Element> attributeElementList;
  List<List<String>> balanceList = [];
  String url = "https://nyzo.co/balanceListPlain/L";
  try {
    http.head(url);
    http.Response response = await http.get(url);
    Document document = parse(response.body, encoding: "utf-8");
    attributeElementList = document.getElementsByTagName("div");
    attributeElementList = attributeElementList[1].getElementsByTagName("p");
    for (var eachElement in attributeElementList) {
      balanceList.add(eachElement.text.split(" "));
    }
    for (List<String> eachList in balanceList) {
      eachList.removeWhere((String value) {
        return value == "";
      });
    }
    for (var eachAddress in balanceList) {
      eachAddress[0] = eachAddress[0].split("-").join();
    }
    return balanceList;
  } catch (e) {}
  return balanceList;
}
