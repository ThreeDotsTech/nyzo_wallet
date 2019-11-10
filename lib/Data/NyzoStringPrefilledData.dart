import 'dart:typed_data';

import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoStringPrefilledData implements NyzoString {

  Uint8List _receiverIdentifier;
  Uint8List _senderData;

NyzoStringPrefilledData(_receiverIdentifier, _senderData) {
this._receiverIdentifier = _receiverIdentifier;
this._senderData = _senderData;
}

getReceiverIdentifier() {
return this._receiverIdentifier;
}

getSenderData() {
return this._senderData;
}

  @override
  getBytes() {
    Uint8List _bytes =Uint8List.fromList([]); 
    _bytes.addAll(this._receiverIdentifier.sublist(0));
    _bytes.addAll(this._senderData.sublist(0));
    return _bytes;
  }

  @override
  getType() {

    return NyzoStringType.PrefilledData;
  }
} 