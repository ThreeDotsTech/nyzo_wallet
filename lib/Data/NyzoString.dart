import 'dart:typed_data';

import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoString {
  // Common ancestor

  NyzoStringType _type;
  Uint8List _bytes;

  NyzoString(_type, _bytes) {
    this._type = _type;
    this._bytes = _bytes;
  }

  NyzoStringType getType() {
    return this._type;
  }

  Uint8List getBytes() {
    return this._bytes;
  }

}