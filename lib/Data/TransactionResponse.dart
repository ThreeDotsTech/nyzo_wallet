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
    final buffer = ByteBuffer(1000);

    buffer.putByte(transactionAccepted!);

    final messageBytes = stringAsUint8Array(message);
    buffer.putShort(messageBytes.length);
    buffer.putBytes(messageBytes);

    return buffer.toArray();
  }
}

Uint8List stringAsUint8Array(string) {
  final unescape = HtmlUnescape();
  final String encodedString = unescape.convert(Uri.encodeComponent(string));
  final Uint8List array = Uint8List(encodedString.length);
  for (int i = 0; i < encodedString.length; i++) {
    array[i] = encodedString.codeUnitAt(i);
  }

  return array;
}
