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
    for (int i = 0; i < bytes.length; i++) {
      array![index!] = bytes[i];
      index = index! + 1;
    }
  }

  putByte(int byte) {
    array![index!] = byte;
    index = index! + 1;
  }

  putIntegerValue(int value, int? length) {
    value = value.floor();
    for (int i = 0; i < length!; i++) {
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

  toArray() {
    final Uint8List result = Uint8List(index!);
    for (int i = 0; i < index!; i++) {
      result[i] = array![i];
    }

    return result;
  }
}
