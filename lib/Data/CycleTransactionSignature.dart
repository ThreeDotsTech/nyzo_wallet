

// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'ByteBuffer.dart';

class CycleTransactionSignature {
  Uint8List? transactionInitiator;
  Uint8List? identifier;
  Uint8List? signature;

  CycleTransactionSignature() {
    this.transactionInitiator = new Uint8List(32);
    this.identifier = new Uint8List(32);
    this.signature = new Uint8List(64);
  }

  setTransactionInitiator(transactionInitiator) {
    for (var i = 0; i < 32; i++) {
      this.transactionInitiator![i] = transactionInitiator[i];
    }
  }

  setIdentifier(identifier) {
    for (var i = 0; i < 32; i++) {
      this.identifier![i] = identifier[i];
    }
  }

  setSignature(signature) {
    for (var i = 0; i < 64; i++) {
      this.signature![i] = signature[i];
    }
  }

  getBytes(includeSignature) {
    var buffer = new ByteBuffer(1000);

    buffer.putBytes(this.transactionInitiator!);
    buffer.putBytes(this.identifier!);
    buffer.putBytes(this.signature!);

    if (includeSignature) {
      buffer.putBytes(this.signature!);
    }

    return buffer.toArray();
  }
}
