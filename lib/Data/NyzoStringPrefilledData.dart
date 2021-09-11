// Dart imports:
import 'dart:math';
import 'dart:typed_data';

// Package imports:
import 'package:binary/binary.dart';

// Project imports:
import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoStringPrefilledData implements NyzoString {
  NyzoStringPrefilledData(
      Uint8List receiverIdentifier, Uint8List senderData, int amount) {
    _receiverIdentifier = receiverIdentifier;
    if (senderData.length <= 32) {
      _senderData = senderData;
    } else {
      _senderData!.setRange(0, 32, senderData.getRange(0, 32));
    }
    _amount = amount;
  }

  Uint8List? _receiverIdentifier;
  Uint8List? _senderData;
  int? _amount;

  Uint8List? getReceiverIdentifier() {
    return _receiverIdentifier;
  }

  Uint8List? getSenderData() {
    return _senderData;
  }

  int? getAmount() {
    return _amount;
  }

  @override
  Uint8List getBytes() {
    final int length = 32 + 1 + _senderData!.length;
    final Uint8List bytes = Uint8List(length);
    int bi = 0;
    final ByteBuffer buffer = bytes.buffer;
    for (int eachByte in _receiverIdentifier!) {
      buffer.asByteData().setUint8(bi++, eachByte);
    }
    buffer.asByteData().setUint8(bi++, _senderData!.length);
    for (int eachByte in _senderData!) {
      buffer.asByteData().setUint8(bi++, eachByte);
    }
    if (_amount! > 0) {
      buffer.asByteData().setInt8(bi++, _amount!);
    }
    return bytes;
  }

  @override
  NyzoStringType getType() {
    return NyzoStringType.forPrefix(NyzoStringType.PrefilledData);
  }

  static NyzoStringPrefilledData fromByteBuffer(ByteBuffer buffer) {
    // Read the receiver identifier. This is always present.
    final Uint8List receiverIdentifier =
        Uint8List.fromList(buffer.asInt8List().getRange(0, 32).toList());

    // Read the data-length byte. The most-significant bit of this byte indicates whether an amount is present.
    final int dataLengthByte = buffer.asInt8List().elementAt(32);
    final bool amountPresent =
        (dataLengthByte & '10000000'.bits) == '10000000'.bits;

    // Read the sender-data length and the sender data. The sender-data length uses the 6 least-significant bits,
    // with a maximum value of 0x0010_0000 (decimal 32).
    final int senderDataLength = min(dataLengthByte & '00111111'.bits, 32);
    final Uint8List senderData = Uint8List.fromList(
        buffer.asUint8List().getRange(33, 33 + senderDataLength).toList());

    // Read the amount, if present. Ensure it is not negative.
    int amount = 0;
    if (amountPresent) {
      final Uint8List amountBytes = Uint8List.fromList(buffer
          .asUint8List()
          .getRange(33 + senderDataLength, 33 + senderDataLength + 8)
          .toList());
      amount = ByteData.view(amountBytes.buffer).getUint64(0);
    }
    amount = max(0, amount);

    return NyzoStringPrefilledData(Uint8List.fromList(receiverIdentifier),
        Uint8List.fromList(senderData), amount);
  }

  static int binaryArrayToNumber(List<int> digits) {
    int result = 0;
    for (int digit in digits) {
      result <<= 1;
      result |= digit;
    }
    return result;
  }
}
