// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

// Package imports:
import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'ByteBuffer.dart';
import 'PreviousHashResponse.dart';
import 'TransactionResponse.dart';

// Package imports:



class NyzoMessage {
  static const Invalid0 = 0;
  static const BootstrapRequest1 = 1;
  static const BootstrapResponse2 = 2;
  static const NodeJoin3 = 3;
  static const NodeJoinAcknowledgement4 = 4;
  static const Transaction5 = 5;
  static const TransactionResponse6 = 6;
  static const PreviousHashRequest7 = 7;
  static const PreviousHashResponse8 = 8;
  static const NewBlock9 = 9;
  static const NewBlockAcknowledgement10 = 10;
  static const Ping200 = 200;
  static const PingResponse201 = 201;
  static const Unknown65535 = 65535;

  int? timestamp;

  Uint8List? sourceNodeIdentifier;

  int? type;

  var content;

  Uint8List? sourceNodeSignature;

  List? signature;

  NyzoMessage() {
    timestamp = DateTime.now().millisecondsSinceEpoch;
    sourceNodeIdentifier = Uint8List(32);
    type = 0;
    content = null;
    sourceNodeSignature = Uint8List(64);
  }

  setSourceNodeIdentifier(Uint8List newSourceNodeIdentifier) {
    sourceNodeIdentifier = newSourceNodeIdentifier;
    return this;
  }

  setType(int newType) {
    type = newType;
    return this;
  }

  setContent(var newContent) {
    content = newContent;
  }

  Uint8List getBytes(bool includeSignature) {
    final ByteBuffer byteBuffer = ByteBuffer(1000);

    var contentBytes;
    int contentSize = 110;
    if (content != null) {
      contentBytes = content.getBytes(true);
      contentSize += contentBytes.lengthInBytes as int;
    }
    if (includeSignature) {
      byteBuffer.putInt(contentSize);
    }
    byteBuffer.putLong(timestamp!);
    byteBuffer.putShort(type!);
    if (contentBytes != null) {
      byteBuffer.putBytes(contentBytes);
    }
    byteBuffer.putBytes(sourceNodeIdentifier!);
    if (includeSignature) {
      byteBuffer.putBytes(sourceNodeSignature!);
    }
    return byteBuffer.toArray();
  }

  sign(Uint8List privKey) async {
    final KeyPair keyPair = await Ed25519().newKeyPairFromSeed(privKey);
    final SimplePublicKey pubKey =
        await keyPair.extractPublicKey() as SimplePublicKey;
    for (var i = 0; i < 32; i++) {
      this.sourceNodeIdentifier![i] = pubKey.bytes[i];
    }
    final Signature signature =
        await Ed25519().sign(this.getBytes(false), keyPair: keyPair);
    for (var i = 0; i < 64; i++) {
      this.sourceNodeSignature![i] = signature.bytes[i];
    }
  }

  fromByteBuffer(byteBuffer) {}

  Future<NyzoMessage> send(Uint8List privKey, http.Client client) async {
    final KeyPair keyPair = await Ed25519().newKeyPairFromSeed(
        privKey); //Creates a KeyPair from the generated Seed
    final SimplePublicKey publicKey =
        keyPair.extractPublicKey() as SimplePublicKey; //Set the Public Key

    final http.Response response =
        await client.post(Uri.parse('https://nyzo.co/message'),
            headers: {
              'Host': 'nyzo.co',
              'Connection': 'keep-alive',
              'Origin': 'https://nyzo.co',
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36',
              'DNT': '1',
              'Content-Type': 'application/octet-stream',
              'Accept': '*/*',
              'Referer': 'https://nyzo.co/wallet?id=' +
                  HEX.encode(publicKey.bytes), //change this to + pubKey
              'Accept-Encoding': 'gzip, deflate, br',
              'Accept-Language':
                  'en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-MX;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,en-US;q=0.2',
            },
            body: this.getBytes(true));

    final arrayBuffer = response.bodyBytes;
    final byteArray = new Uint8List.fromList(arrayBuffer);
    final response2 = new NyzoMessage();

    response2.timestamp = intValueFromArray(byteArray, 4, 8);
    response2.type = intValueFromArray(byteArray, 12, 2);
    response2.content = contentForType(response2.type, byteArray, 14);
    final int sourceNodeIdentifierIndex =
        14 + contentSizeForType(response2.type, byteArray, 14);
    response2.sourceNodeIdentifier =
        arrayFromArray(byteArray, sourceNodeIdentifierIndex, 32);
    response2.signature =
        arrayFromArray(byteArray, sourceNodeIdentifierIndex + 32, 64);
    return response2;
  }

  contentForType(messageType, Uint8List byteArray, index) {
    var result;
    if (messageType == TransactionResponse6) {
      final transactionAccepted = byteArray[index];
      final message = stringFromArray(byteArray, index + 1);
      result = TransactionResponse(transactionAccepted, message);
    } else if (messageType == PreviousHashResponse8) {
      final height = intValueFromArray(byteArray, index, 8);
      final hash = arrayFromArray(byteArray, index + 8, 32);
      result = PreviousHashResponse(height, hash);
    }

    return result;
  }

  int contentSizeForType(messageType, byteArray, index) {
    var contentSize = 0;
    if (messageType == TransactionResponse6) {
      contentSize = 3 + intValueFromArray(byteArray, index + 1, 2);
    } else if (messageType == PreviousHashResponse8) {
      contentSize = 8 + 32;
    }
    return contentSize;
  }
}

String stringFromArray(Uint8List byteArray, int index) {
  final length = byteArray[index] * 256 + byteArray[index + 1];
  return stringFromArrayWithLength(byteArray, index + 2, length);
}

String stringFromArrayWithLength(Uint8List byteArray, int index, int length) {
  final arrayCopy = Uint8List(length);
  for (var i = 0; i < length; i++) {
    arrayCopy[i] = byteArray[i + index];
  }

  return utf8.decode(arrayCopy);
}

String hexStringFromArrayWithDashes(
    Uint8List byteArray, int index, int length) {
  var result = '';
  var dashCount = 0;
  for (var i = index; i < index + length && i < byteArray.length; i++) {
    var byteString = HEX.encode([byteArray[i]]);
    while (byteString.length < 2) {
      byteString = '0' + byteString;
    }
    result += byteString;
    dashCount++;
    if (dashCount == 8 && i < index + length - 1) {
      result += '-';
      dashCount = 0;
    }
  }

  return result;
}

int intValueFromArray(Uint8List byteArray, int index, int length) {
  var timestamp = 0;
  for (var i = index; i < index + length; i++) {
    timestamp *= 256;
    timestamp += byteArray[i];
  }

  return timestamp;
}

Uint8List arrayFromArray(Uint8List byteArray, int index, int length) {
  final result = Uint8List(length);
  for (var i = 0; i < length; i++) {
    result[i] = byteArray[index + i];
  }

  return result;
}
