// Dart imports:
import 'dart:core';

// Project imports:
import 'ByteBuffer.dart';

class PreviousHashResponse {
  var height;

  var hash;

  PreviousHashResponse(height, hash) {
    this.height = height;
    this.hash = hash;
  }

  getBytes(includeSignatureIgnored) {
    final ByteBuffer buffer = ByteBuffer(1000);

    buffer.putLong(height);
    buffer.putBytes(hash);

    return buffer.toArray();
  }
}
