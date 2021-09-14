class Token {
  String? name;
  double? amount;
  String? comment;

  static const TOKEN_TRANSFER_PREFIX = 'TT';

  Token({required this.name, required this.amount, required this.comment});

  Token.fromJson(Map<String, dynamic> data)
      : name = data['name'],
        amount = data['amount'] == null ? 0 : double.tryParse(data['amount']),
        comment = data['comment'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'comment': comment,
      };

  bool isTT(String? senderData) {
    if (senderData!.startsWith(TOKEN_TRANSFER_PREFIX + ":")) {
      return true;
    } else {
      return false;
    }
  }

  String getSenderData() {
    return TOKEN_TRANSFER_PREFIX +
        ':' +
        name! +
        ':' +
        amount.toString() +
        ':' +
        comment!;
  }

  void parseTT(String? senderData) {
    List<String>? params = senderData!.split(":");

    if (params.length > 1 && params[1].isNotEmpty) {
      name = params[1];
    }
    if (params.length > 2 && params[2].isNotEmpty) {
      amount = double.tryParse(params[2]);
    }
    if (params.length > 3 && params[3].isNotEmpty) {
      comment = params[3];
    }
  }
}
