// Project imports:
import 'package:nyzo_wallet/Data/Wallet.dart';

class WatchedAddress {
  String? address;
  String? balance;
  String? nickname;

  WatchedAddress._fromAddress(this.address);
  static WatchedAddress fromAddress(String address) {
    final WatchedAddress watchedAddress = WatchedAddress._fromAddress(address);
    watchedAddress.nickname =
        nyzoStringFromPublicIdentifier(address).substring(0, 4) +
            '...' +
            nyzoStringFromPublicIdentifier(address)
                .substring(nyzoStringFromPublicIdentifier(address).length - 4);

    return watchedAddress;
  }

  WatchedAddress.fromJson(Map<String, dynamic> data)
      : address = data['address'],
        nickname = data['nickname'];

  Map<String, dynamic> toJson() => {'address': address, 'nickname': nickname};
}
