
class WatchedAddress {
  String address;
  String balance;

  WatchedAddress.fromAddress(this.address);

  WatchedAddress.fromJson(Map<String, dynamic> data) : address = data['address'];

  Map<String, dynamic> toJson() => {'address': address};
}
