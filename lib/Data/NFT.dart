class NFT {
  String? className;
  String? uid;
  double? amount;
  String? comment;

  static const NFT_TRANSFER_PREFIX = 'NT';

  NFT({required this.className, required this.amount, required this.comment});

  NFT.fromJson(Map<String, dynamic> data)
      : className = data['className'],
        uid = data['uid'],
        amount = data['amount'] == null ? 0 : double.tryParse(data['amount']),
        comment = data['comment'];

  Map<String, dynamic> toJson() => {
        'className': className,
        'uid': uid,
        'amount': amount,
        'comment': comment,
      };

  bool isNT(String? senderData) {
    if (senderData!.startsWith(NFT_TRANSFER_PREFIX + ":")) {
      return true;
    } else {
      return false;
    }
  }

  String getSenderData() {
    return NFT_TRANSFER_PREFIX + ':' + className! + ':' + uid! + ':' + comment!;
  }

  void parseNT(String? senderData) {
    List<String>? params = senderData!.split(":");

    if (params.length > 1 && params[1].isNotEmpty) {
      className = params[1];
    }
    if (params.length > 2 && params[2].isNotEmpty) {
      uid = params[2];
    }
    if (params.length > 3 && params[3].isNotEmpty) {
      comment = params[3];
    }
  }
}
