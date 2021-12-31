// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';
import 'package:nyzo_wallet/Data/TransactionMessage.dart';

class NyzoStringTransaction implements NyzoString {
  TransactionMessage? transaction;

  NyzoStringTransaction(TransactionMessage transaction) {
    this.transaction = transaction;
  }

  TransactionMessage getTransaction() {
    return transaction!;
  }

  @override
  NyzoStringType getType() {
    return NyzoStringType(NyzoStringType.Transaction);
  }

  @override
  Uint8List getBytes() {
    return transaction!.getBytes(true);
  }
}
