 import 'dart:typed_data';

import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';

class NyzoStringPrivateSeed implements NyzoString {

     
     Uint8List _seed;

     NyzoStringPrivateSeed(Uint8List _seed) {
        this._seed = _seed;
    }

    Uint8List getSeed() {
        return _seed;
    }

    @override
    NyzoStringType getType() {
        return NyzoStringType(NyzoStringType.PrivateSeed);
    }

    @override
    Uint8List getBytes() {
        return _seed;
    }




}