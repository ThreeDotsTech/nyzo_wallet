

// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

// Package imports:

import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:pinenacl/ed25519.dart' as ed25519;

// Project imports:
import 'ByteBuffer.dart';
import 'PreviousHashResponse.dart';
import 'TransactionResponse.dart';

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
    this.timestamp = DateTime.now().millisecondsSinceEpoch;
    this.sourceNodeIdentifier = new Uint8List(32);
    this.type = 0;
    this.content = null;
    this.sourceNodeSignature = new Uint8List(64);
  }

  setSourceNodeIdentifier(Uint8List newSourceNodeIdentifier) {
    this.sourceNodeIdentifier = newSourceNodeIdentifier;
    return this;
  }

  setType(int newType) {
    this.type = newType;
    return this;
  }

  setContent(var newContent) {
    this.content = newContent;
  }

  Uint8List getBytes(bool includeSignature) {
    ByteBuffer byteBuffer = new ByteBuffer(1000);

    var contentBytes;
    int contentSize = 110;
    if (this.content != null) {
      contentBytes = this.content.getBytes(true);
      contentSize += contentBytes.lengthInBytes as int;
    }
    if (includeSignature) {
      byteBuffer.putInt(contentSize);
    }
    byteBuffer.putLong(this.timestamp!);
    byteBuffer.putShort(this.type!);
    if (contentBytes != null) {
      byteBuffer.putBytes(contentBytes);
    }
    byteBuffer.putBytes(this.sourceNodeIdentifier!);
    if (includeSignature) {
      byteBuffer.putBytes(this.sourceNodeSignature!);
    }
    return byteBuffer.toArray();
  }

  sign(Uint8List privKey) {
    final ed25519.SigningKey signingKey = ed25519.SigningKey(seed: privKey);
    final ed25519.SignatureBase sm =
        signingKey.sign(this.getBytes(false)).signature;
    this.sourceNodeSignature = Uint8List.fromList(sm).sublist(0, 64);
  }

  fromByteBuffer(byteBuffer) {}

  Future<NyzoMessage?> send(privKey, http.Client client) async {
    return null;
  }

  contentForType(messageType, Uint8List byteArray, index) {
    var result;
    if (messageType == TransactionResponse6) {
      var transactionAccepted = byteArray[index];
      var message = stringFromArray(byteArray, index + 1);
      result = new TransactionResponse(transactionAccepted, message);
    } else if (messageType == PreviousHashResponse8) {
      var height = intValueFromArray(byteArray, index, 8);
      var hash = arrayFromArray(byteArray, index + 8, 32);
      result = new PreviousHashResponse(height, hash);
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
  var length = byteArray[index] * 256 + byteArray[index + 1];
  return stringFromArrayWithLength(byteArray, index + 2, length);
}

String stringFromArrayWithLength(Uint8List byteArray, int index, int length) {
  var arrayCopy = new Uint8List(length);
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
  var result = new Uint8List(length);
  for (var i = 0; i < length; i++) {
    result[i] = byteArray[index + i];
  }

  return result;
}
