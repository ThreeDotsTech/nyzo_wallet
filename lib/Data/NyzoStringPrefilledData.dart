

// Dart imports:
import 'dart:math';
import 'dart:typed_data';

// Project imports:
import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoStringPrefilledData implements NyzoString {
  Uint8List? _receiverIdentifier;
  Uint8List? _senderData;

  NyzoStringPrefilledData(Uint8List receiverIdentifier, Uint8List senderData) {
    this._receiverIdentifier = receiverIdentifier;
    if (senderData.length <= 32) {
      this._senderData = senderData;
    } else {
      this._senderData!.setRange(0, 32, senderData.getRange(0, 32));
    }
  }

  Uint8List? getReceiverIdentifier() {
    return this._receiverIdentifier;
  }

  Uint8List? getSenderData() {
    return this._senderData;
  }

  @override
  Uint8List getBytes() {
    final length = 32 + 1 + _senderData!.length;
    final bytes = Uint8List(length);
    var bi = 0;
    final buffer = bytes.buffer;
    for (var eachByte in this._receiverIdentifier!) {
      buffer.asByteData().setUint8(bi++, eachByte);
    }
    buffer.asByteData().setUint8(bi++, this._senderData!.length);
    for (var eachByte in this._senderData!) {
      buffer.asByteData().setUint8(bi++, eachByte);
    }
    return bytes;
  }

  @override
  getType() {
    return NyzoStringType.forPrefix(NyzoStringType.PrefilledData);
  }

  static NyzoStringPrefilledData fromByteBuffer(ByteBuffer buffer) {
    var receiverIdentifier =
        Uint8List.fromList(buffer.asUint8List().getRange(0, 32).toList());
    int senderDataLength = min(buffer.asByteData().getUint8(32), 32);
    var senderData = Uint8List.fromList(
        buffer.asUint8List().getRange(33, 33 + senderDataLength).toList());
    return new NyzoStringPrefilledData(receiverIdentifier, senderData);
  }
}
