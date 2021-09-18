// To parse this JSON data, do
//
//     final tokensTransactionsResponse = tokensTransactionsResponseFromJson(jsonString);

import 'dart:convert';

List<TokensTransactionsResponse> tokensTransactionsResponseFromJson(String str) => List<TokensTransactionsResponse>.from(json.decode(str).map((x) => TokensTransactionsResponse.fromJson(x)));

String tokensTransactionsResponseToJson(List<TokensTransactionsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TokensTransactionsResponse {
    TokensTransactionsResponse({
        this.timestamp,
        this.type,
        this.blockHeight,
        this.token,
        this.sender,
        this.recipient,
        this.amount,
        this.nftId,
        this.comment,
        this.signature,
        this.amountInt,
    });

    int? timestamp;
    String? type;
    int? blockHeight;
    String? token;
    String? sender;
    String? recipient;
    String? amount;
    String? nftId;
    String? comment;
    String? signature;
    int? amountInt;

    factory TokensTransactionsResponse.fromJson(Map<String, dynamic> json) => TokensTransactionsResponse(
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        type: json["type"] == null ? null : json["type"],
        blockHeight: json["block_height"] == null ? null : json["block_height"],
        token: json["token"] == null ? null : json["token"],
        sender: json["sender"] == null ? null : json["sender"],
        recipient: json["recipient"] == null ? null : json["recipient"],
        amount: json["amount"] == null ? null : json["amount"],
        nftId: json["nft_id"] == null ? null : json["nft_id"],
        comment: json["comment"] == null ? null : json["comment"],
        signature: json["signature"] == null ? null : json["signature"],
        amountInt: json["amount_int"] == null ? null : json["amount_int"],
    );

    Map<String, dynamic> toJson() => {
        "timestamp": timestamp == null ? null : timestamp,
        "type": type == null ? null : type,
        "block_height": blockHeight == null ? null : blockHeight,
        "token": token == null ? null : token,
        "sender": sender == null ? null : sender,
        "recipient": recipient == null ? null : recipient,
        "amount": amount == null ? null : amount,
        "nft_id": nftId == null ? null : nftId,
        "comment": comment == null ? null : comment,
        "signature": signature == null ? null : signature,
        "amount_int": amountInt == null ? null : amountInt,
    };
}
