// Project imports:
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrefilledData.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/Utils.dart';

class NyzoUrl {
  NyzoUrl(
      {this.action,
      this.contactName,
      this.address,
      this.amount,
      this.data,
      this.isTokenToSend,
      this.tokenName,
      this.tokenToSendQty});

  String? action;
  String? contactName;
  String? address;
  String? amount;
  String? data;
  bool? isTokenToSend;
  int? tokenToSendQty;
  String? tokenName;

  Future<NyzoUrl> getInfo(String link) async {
    final NyzoUrl _nyzoUrl = NyzoUrl();
    link = link.replaceAll('nyzo://', '');

    final NyzoStringPrefilledData _nyzoStringPrefilledData =
        NyzoStringEncoder.decode(link) as NyzoStringPrefilledData;
    print(_nyzoStringPrefilledData.getReceiverIdentifier());
    _nyzoUrl.address = NyzoStringEncoder.encode(NyzoStringPublicIdentifier(
        _nyzoStringPrefilledData.getReceiverIdentifier()!));
    _nyzoUrl.data =
        Utils.senderDataForDisplay(_nyzoStringPrefilledData.getSenderData()!);
    _nyzoUrl.amount = _nyzoStringPrefilledData.getAmount() == null
        ? '0'
        : (_nyzoStringPrefilledData.getAmount()! / 1000000).toString();
    return _nyzoUrl;
  }
}
