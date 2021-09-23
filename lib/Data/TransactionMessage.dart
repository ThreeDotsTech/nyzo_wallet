// Dart imports:
import 'dart:math';
import 'dart:typed_data';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';

// Project imports:
import 'ByteBuffer.dart';

class TransactionMessage {
  int? timestamp;

  int? amount;

  Uint8List? recipientIdentifier;

  int? previousHashHeight;

  Uint8List? previousBlockHash;

  Uint8List? senderIdentifier;

  Uint8List? senderData;

  Uint8List? signature;

  TransactionMessage() {
    timestamp = DateTime.now().millisecondsSinceEpoch;
    amount = 0;
    recipientIdentifier = Uint8List(32);
    previousHashHeight = 0;
    previousBlockHash = Uint8List(32);
    senderIdentifier = Uint8List(32);
    senderData = Uint8List(0);
    signature = Uint8List(64);
  }

  setTimestamp(timestamp) {
    this.timestamp = timestamp;
  }

  setAmount(amount) {
    this.amount = amount;
  }

  setRecipientIdentifier(recipientIdentifier) {
    for (var i = 0; i < 32; i++) {
      this.recipientIdentifier![i] = recipientIdentifier[i];
    }
  }

  setPreviousHashHeight(previousHashHeight) {
    this.previousHashHeight = previousHashHeight;
  }

  setPreviousBlockHash(previousBlockHash) {
    for (var i = 0; i < 32; i++) {
      this.previousBlockHash![i] = previousBlockHash[i];
    }
  }

  setSenderData(senderData) {
    this.senderData = Uint8List(min(senderData.length, 32));
    for (var i = 0; i < this.senderData!.length; i++) {
      this.senderData![i] = senderData[i];
    }
  }

  sign(Uint8List privKey) async {
    final KeyPair keyPair = await Ed25519().newKeyPairFromSeed(privKey);
    final Signature sm =
        await Ed25519().sign(getBytes(false), keyPair: keyPair);
    final SimplePublicKey pubKey =
        await keyPair.extractPublicKey() as SimplePublicKey;
    for (int i = 0; i < 32; i++) {
      this.senderIdentifier![i] = pubKey.bytes[i];
    }
    signature = Uint8List.fromList(sm.bytes);
  }

  getBytes(bool includeSignature) {
    final forSigning = !includeSignature;

    final buffer = ByteBuffer(1000);

    buffer.putByte(2);
    buffer.putLong(timestamp!);
    buffer.putLong(amount!);
    buffer.putBytes(recipientIdentifier!);

    if (forSigning) {
      buffer.putBytes(previousBlockHash!);
    } else {
      buffer.putLong(previousHashHeight!);
    }
    buffer.putBytes(senderIdentifier!);

    if (forSigning) {
      buffer.putBytes(doubleSha256(senderData!));
    } else {
      buffer.putByte(senderData!.length);
      buffer.putBytes(senderData!);
    }

    if (!forSigning) {
      buffer.putBytes(signature!);
    }

    return buffer.toArray();
  }
}

Uint8List hexStringAsUint8Array(String identifier) {
  identifier = identifier.split('-').join('');
  final array = Uint8List((identifier.length / 2).floor());
  for (var i = 0; i < array.length; i++) {
    array[i] = HEX.decode(identifier.substring(i * 2, i * 2 + 2))[0];
  }
  return array;
}

Uint8List sha256Uint8(array) {
  return Uint8List.fromList(sha256.convert(array).bytes);
}

Uint8List doubleSha256(Uint8List array) {
  return sha256Uint8(sha256Uint8(array));
}
