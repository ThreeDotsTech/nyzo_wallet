import 'dart:typed_data';

import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';

class NyzoStringType {
  static const PrefilledData = "pre_";
  static const PrivateSeed = "key_";
  static const PublicIdentifier = "id__";
  static const Micropay = "pay_";
  static const Transaction = "tx__";

  String _prefix;
  Uint8List _prefixBytes;
  NyzoString data;

  NyzoStringType(String prefix) {
    this._prefix = prefix;
    this._prefixBytes = NyzoStringEncoder.byteArrayForEncodedString(prefix);
  }

  String getPrefix() {
    return _prefix;
  }

  Uint8List getPrefixBytes() {
    return _prefixBytes;
  }

  static String forPrefix(String prefix) {
    String result;
    switch (prefix) {
      case NyzoStringType.Micropay:
        result = NyzoStringType.Micropay;
        break;
      case NyzoStringType.PrefilledData:
        result = NyzoStringType.PrefilledData;
        break;
      case NyzoStringType.PrivateSeed:
        result = NyzoStringType.PrivateSeed;
        break;
      case NyzoStringType.PublicIdentifier:
        result = NyzoStringType.PublicIdentifier;
        break;
      case NyzoStringType.Transaction:
        result = NyzoStringType.Transaction;
        break;
      default:
    }

    return result;
  }
}
