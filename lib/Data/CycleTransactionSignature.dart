// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'ByteBuffer.dart';

class CycleTransactionSignature {
  Uint8List? transactionInitiator;
  Uint8List? identifier;
  Uint8List? signature;

  CycleTransactionSignature() {
    transactionInitiator = Uint8List(32);
    identifier = Uint8List(32);
    signature = Uint8List(64);
  }

  void setTransactionInitiator(Uint8List transactionInitiator) {
    for (int i = 0; i < 32; i++) {
      this.transactionInitiator![i] = transactionInitiator[i];
    }
  }

  void setIdentifier(Uint8List identifier) {
    for (int i = 0; i < 32; i++) {
      this.identifier![i] = identifier[i];
    }
  }

  void setSignature(Uint8List? signature) {
    for (int i = 0; i < 64; i++) {
      this.signature![i] = signature![i];
    }
  }

  Uint8List getBytes(bool includeSignature) {
    final ByteBuffer buffer = ByteBuffer(1000);

    buffer.putBytes(transactionInitiator!);
    buffer.putBytes(identifier!);
    buffer.putBytes(signature!);

    if (includeSignature) {
      buffer.putBytes(signature!);
    }

    return buffer.toArray();
  }
}
