import 'dart:typed_data';

class NyzoString {
  // Common ancestor

  String _type;
  Uint8List _bytes;

  NyzoString(_type, _bytes) {
    this._type = _type;
    this._bytes = _bytes;
  }

  getType() {
    return this._type;
  }

  getBytes() {
    return this._bytes;
  }

}