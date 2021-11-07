class Token {
  bool isNFT;
  String? name;
  String? uid;
  double? amount;
  String? comment;

  Token(
      {required this.isNFT,
      required this.name,
      required this.uid,
      required this.amount,
      required this.comment});

  Token.fromJson(Map<String, dynamic> data)
      : isNFT = data['isNFT'],
        name = data['name'],
        uid = data['uid'],
        amount = data['amount'] == null ? 0 : double.tryParse(data['amount']),
        comment = data['comment'];

  Map<String, dynamic> toJson() => {
        'isNFT': isNFT,
        'name': name,
        'uid': uid,
        'amount': amount,
        'comment': comment,
      };
}
