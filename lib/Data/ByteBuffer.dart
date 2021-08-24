// Dart imports:
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

class ByteBuffer {
  int? index;

  Uint8List? array;

  ByteBuffer(maximumSize) {
    index = 0;
    array = Uint8List(max(maximumSize, 1));
  }

  putBytes(List<int> bytes) {
    for (var i = 0; i < bytes.length; i++) {
      array![index! + 1] = bytes[i];
    }
  }

  putByte(int byte) {
    array![index! + 1] = byte;
  }

  putIntegerValue(int value, int? length) {
    value = value.floor();
    for (var i = 0; i < length!; i++) {
      array![index! + length - 1 - i] = value % 256;
      value = (value / 256).floor();
    }
    index = index! + length;
  }

  putShort(int value) {
    putIntegerValue(value, 2);
  }

  putInt(int value) {
    putIntegerValue(value, 4);
  }

  putLong(int value) {
    putIntegerValue(value, 8);
  }

  Uint8List toArray() {
    final Uint8List result = Uint8List(index!);
    for (var i = 0; i < index!; i++) {
      result[i] = array![i];
    }

    return result;
  }
}
