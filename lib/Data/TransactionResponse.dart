

// Dart imports:
import 'dart:core';
import 'dart:typed_data';

// Package imports:
import 'package:html_unescape/html_unescape.dart';

// Project imports:
import 'ByteBuffer.dart';

class TransactionResponse {
  String? message;

  int? transactionAccepted;

  TransactionResponse(int transactionAccepted, String message) {
    this.transactionAccepted = transactionAccepted;
    this.message = message;
  }

  getBytes(includeSignatureIgnored) {
    var buffer = new ByteBuffer(1000);

    buffer.putByte(this.transactionAccepted!);

    var messageBytes = stringAsUint8Array(this.message);
    buffer.putShort(messageBytes.length);
    buffer.putBytes(messageBytes);

    return buffer.toArray();
  }
}

Uint8List stringAsUint8Array(string) {
  var unescape = new HtmlUnescape();
  String encodedString = unescape.convert(Uri.encodeComponent(string));
  Uint8List array = new Uint8List(encodedString.length);
  for (int i = 0; i < encodedString.length; i++) {
    array[i] = encodedString.codeUnitAt(i);
  }

  return array;
}
