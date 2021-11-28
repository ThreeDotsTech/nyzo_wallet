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
  static const int Invalid0 = 0;
  static const int BootstrapRequest1 = 1;
  static const int BootstrapResponse2 = 2;
  static const int NodeJoin3 = 3;
  static const int NodeJoinAcknowledgement4 = 4;
  static const int Transaction5 = 5;
  static const int TransactionResponse6 = 6;
  static const int PreviousHashRequest7 = 7;
  static const int PreviousHashResponse8 = 8;
  static const int NewBlock9 = 9;
  static const int NewBlockAcknowledgement10 = 10;
  static const int Ping200 = 200;
  static const int PingResponse201 = 201;
  static const int Unknown65535 = 65535;

  int? timestamp;

  Uint8List? sourceNodeIdentifier;

  int? type;

  var content;

  Uint8List? sourceNodeSignature;

  List? signature;

  NyzoMessage() {
    this.timestamp = DateTime.now().millisecondsSinceEpoch;
    this.sourceNodeIdentifier = Uint8List(32);
    this.type = 0;
    this.content = null;
    this.sourceNodeSignature = Uint8List(64);
  }

  NyzoMessage setSourceNodeIdentifier(Uint8List newSourceNodeIdentifier) {
    this.sourceNodeIdentifier = newSourceNodeIdentifier;
    return this;
  }

  NyzoMessage setType(int newType) {
    this.type = newType;
    return this;
  }

  void setContent(var newContent) {
    this.content = newContent;
  }

  Uint8List getBytes(bool includeSignature) {
    final ByteBuffer byteBuffer = ByteBuffer(1000);

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

  Future<void> sign(Uint8List privKey) async {
    final ed25519.SigningKey signingKey = ed25519.SigningKey(seed: privKey);
    final Uint8List pubBuf = signingKey.publicKey.toUint8List();

    for (int i = 0; i < 32; i++) {
      this.sourceNodeIdentifier![i] = pubBuf[i];
    }
    final ed25519.SignatureBase sm =
        signingKey.sign(this.getBytes(false)).signature;

    for (int i = 0; i < 64; i++) {
      this.sourceNodeSignature![i] = sm[i];
    }
  }

  fromByteBuffer(byteBuffer) {}

  contentForType(int? messageType, Uint8List byteArray, int index) {
    var result;
    if (messageType == TransactionResponse6) {
      final int transactionAccepted = byteArray[index];
      final String message = stringFromArray(byteArray, index + 1);
      result = TransactionResponse(transactionAccepted, message);
    } else if (messageType == PreviousHashResponse8) {
      final int height = intValueFromArray(byteArray, index, 8);
      final Uint8List hash = arrayFromArray(byteArray, index + 8, 32);
      result = PreviousHashResponse(height, hash);
    }

    return result;
  }

  int contentSizeForType(int? messageType, Uint8List byteArray, int index) {
    int contentSize = 0;
    if (messageType == TransactionResponse6) {
      contentSize = 3 + intValueFromArray(byteArray, index + 1, 2);
    } else if (messageType == PreviousHashResponse8) {
      contentSize = 8 + 32;
    }
    return contentSize;
  }
}

String stringFromArray(Uint8List byteArray, int index) {
  final int length = byteArray[index] * 256 + byteArray[index + 1];
  return stringFromArrayWithLength(byteArray, index + 2, length);
}

String stringFromArrayWithLength(Uint8List byteArray, int index, int length) {
  final Uint8List arrayCopy = Uint8List(length);
  for (int i = 0; i < length; i++) {
    arrayCopy[i] = byteArray[i + index];
  }

  return utf8.decode(arrayCopy);
}

String hexStringFromArrayWithDashes(
    Uint8List byteArray, int index, int length) {
  String result = '';
  int dashCount = 0;
  for (int i = index; i < index + length && i < byteArray.length; i++) {
    String byteString = HEX.encode([byteArray[i]]);
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
  int timestamp = 0;
  for (int i = index; i < index + length; i++) {
    timestamp *= 256;
    timestamp += byteArray[i];
  }

  return timestamp;
}

Uint8List arrayFromArray(Uint8List byteArray, int index, int length) {
  final Uint8List result = Uint8List(length);
  for (int i = 0; i < length; i++) {
    result[i] = byteArray[index + i];
  }

  return result;
}
