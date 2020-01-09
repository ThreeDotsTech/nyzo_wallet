import 'dart:typed_data';

import 'package:package_info/package_info.dart';

class Utils {
  static int addToBuffer(final ByteBuffer buffer, int index, Uint8List data,
      {final Endian endian = Endian.little,
      final int offset = 0,
      int length,
      int bits = 32}) {
    if (length != null) {
      if (length > data.length || data.length > buffer.lengthInBytes) {
        throw ArgumentError(
            '[length] must smaller than the length of [data] and the length of data shall be smaller than the length of the [buffer].');
      }
    }
    length ??= data
        .length; //If the length wasn't set, it will get the value from the data.
    index += length;
    switch (bits) {
      case 32:
        for (var i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint32(index, data[i], endian);
        }
        break;
      case 8:
        for (var i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint8(index, data[i]);
        }
        break;
      case 16:
        for (var i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint16(index, data[i], endian);
        }
        break;
      case 64:
        for (var i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint64(index, data[i], endian);
        }
        break;
      default:
        throw ArgumentError.value(bits, 'bits', 'Invalid number of bits');
    }
    return index;
  }

  static Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
