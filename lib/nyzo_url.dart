// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:hex/hex.dart';

// Project imports:
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';

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
    String checksum;
    link = link.replaceAll('nyzo://', '');
    final List<String> params = link.split('/');

    // format url based b64urlsafe
    if (params.isNotEmpty) {
      action = params[0];
    }
    if (action == 'pre') {
      // Prefilled transactions
      // nyzo://pre/recipient/amount/b64_data/b64_checksum
      if (params.length > 1) {
        address = params[1];
      }
      if (params.length > 2) {
        amount = params[2];
      }
      if (params.length > 3) {
        data = String.fromCharCodes(base64Url.decode(params[3]));
      }
      if (params.length > 4) {
        // TODO : Verify checksum
        checksum = HEX.encode(base64Url.decode(params[4]));
      }
      _nyzoUrl.action = action ?? '';
      _nyzoUrl.address = address ?? '';
      if (_nyzoUrl.address!.isNotEmpty) {
        try {
          final Contact _contact = await getContact(_nyzoUrl.address);
          _nyzoUrl.contactName = _contact.name;
        } on Exception {
          _nyzoUrl.contactName = '';
        }
      }
      _nyzoUrl.amount = amount ?? '0';
      _nyzoUrl.data = data ?? '';

      // TODO: Implement with tokens management
      _nyzoUrl.isTokenToSend = false;
      _nyzoUrl.tokenToSendQty = 0;
      _nyzoUrl.tokenName = '';
    }
    return _nyzoUrl;
  }
}
