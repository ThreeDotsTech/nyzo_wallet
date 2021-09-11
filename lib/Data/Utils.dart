// Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';

class Utils {
  static int addToBuffer(final ByteBuffer buffer, int index, Uint8List data,
      {final Endian endian = Endian.little,
      final int offset = 0,
      int? length,
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
        for (int i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint32(index, data[i], endian);
        }
        break;
      case 8:
        for (int i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint8(index, data[i]);
        }
        break;
      case 16:
        for (int i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint16(index, data[i], endian);
        }
        break;
      case 64:
        for (int i = offset; i < offset + length; i++) {
          buffer.asByteData().setUint64(index, data[i], endian);
        }
        break;
      default:
        throw ArgumentError.value(bits, 'bits', 'Invalid number of bits');
    }
    return index;
  }

  static Future<String> getVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static String senderDataForDisplay(Uint8List senderData) {
    // Sender data is stored and handled as a raw array of bytes. Often, this byte array represents a character
    // string. If encoding to a UTF-8 character string and back to a byte array produces the original byte array,
    // display as a string. Otherwise, display the hex values of the bytes.
    String result = '';
    try {
      result = utf8.decode(senderData);
      if (!listEquals(senderData, result.codeUnits)) {
        result = arrayAsStringWithDashes(senderData);
      }
    } catch (e) {}

    return result;
  }

  static String arrayAsStringWithDashes(Uint8List array) {
    final StringBuffer result = StringBuffer('');
    try {
      for (int i = 0; i < array.length; i++) {
        if (i % 8 == 7 && i < array.length - 1) {
          result.write(sprintf('%02x-', [array[i]]));
        } else {
          result.write(sprintf('%02x', [array[i]]));
        }
      }
    } catch (e) {}

    return result.toString();
  }
}
