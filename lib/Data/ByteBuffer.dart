import 'dart:core';
import 'dart:typed_data';
import 'dart:math';

class ByteBuffer {
  int index;

  Uint8List array;

  ByteBuffer(maximumSize) {
    this.index = 0;
    this.array = new Uint8List(max(maximumSize, 1));
  }

  putBytes(List<int> bytes) {
    for (var i = 0; i < bytes.length; i++) {
      this.array[this.index++] = bytes[i];
    }
  }

  putByte(int byte) {
    this.array[this.index++] = byte;
  }

  putIntegerValue(int value, int length) {
    value = value.floor();
    for (var i = 0; i < length; i++) {
      this.array[this.index + length - 1 - i] = value % 256;
      value = (value / 256).floor();
    }
    this.index += length;
  }

  putShort(int value) {
    this.putIntegerValue(value, 2);
  }

  putInt(int value) {
    this.putIntegerValue(value, 4);
  }

  putLong(int value) {
    this.putIntegerValue(value, 8);
  }

  Uint8List toArray() {
    var result = new Uint8List(this.index);
    for (var i = 0; i < this.index; i++) {
      result[i] = this.array[i];
    }

    return result;
  }
}
