import 'dart:core';
import 'ByteBuffer.dart';

class PreviousHashResponse {
  var height;

  var hash;

  PreviousHashResponse(height, hash) {
    this.height = height;
    this.hash = hash;
  }

  getBytes(includeSignatureIgnored) {
    var buffer = new ByteBuffer(1000);

    buffer.putLong(this.height);
    buffer.putBytes(this.hash);

    return buffer.toArray();
  }
}
