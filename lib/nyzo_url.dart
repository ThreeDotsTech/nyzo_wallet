class NyzoUrl {
  String? contactName;
  String? address;
  String? amount;
  String? data;
  bool? isTokenToSend;
  int? tokenToSendQty;
  String? tokenName;

  NyzoUrl(
      {this.contactName,
      this.address,
      this.amount,
      this.data,
      this.isTokenToSend,
      this.tokenName,
      this.tokenToSendQty});

  NyzoUrl getInfo(String link) {
    NyzoUrl _nyzoUrl = new NyzoUrl();
    print("link: " + link);   
    return _nyzoUrl;
  }
}
