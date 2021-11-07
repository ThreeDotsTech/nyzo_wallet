// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoString {
  // Common ancestor

  NyzoStringType? _type;
  Uint8List? _bytes;

  NyzoString(_type, _bytes) {
    this._type = _type;
    this._bytes = _bytes;
  }

  NyzoStringType getType() {
    return _type!;
  }

  Uint8List getBytes() {
    return _bytes!;
  }
}
