// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoStringPublicIdentifier implements NyzoString {
  Uint8List? _identifier;

  NyzoStringPublicIdentifier(Uint8List _identifier) {
    this._identifier = _identifier;
  }

  Uint8List getIdentifier() {
    return _identifier!;
  }

  @override
  NyzoStringType getType() {
    return NyzoStringType(NyzoStringType.PublicIdentifier);
  }

  @override
  Uint8List getBytes() {
    return _identifier!;
  }
}
