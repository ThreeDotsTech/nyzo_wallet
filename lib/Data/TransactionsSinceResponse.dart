// To parse this JSON data, do
//
//     final transactionsSinceResponse = transactionsSinceResponseFromJson(jsonString);

// Dart imports:
import 'dart:convert';

TransactionsSinceResponse transactionsSinceResponseFromJson(String str) =>
    TransactionsSinceResponse.fromJson(json.decode(str));

String transactionsSinceResponseToJson(TransactionsSinceResponse data) =>
    json.encode(data.toJson());

class TransactionsSinceResponse {
  TransactionsSinceResponse({
    this.endHeight,
    this.txs,
  });

  int? endHeight;
  List<Tx>? txs;

  factory TransactionsSinceResponse.fromJson(Map<String, dynamic> json) =>
      TransactionsSinceResponse(
        endHeight: json["end_height"],
        txs: List<Tx>.from(json["txs"].map((x) => Tx.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "end_height": endHeight,
        "txs": List<dynamic>.from(txs!.map((x) => x.toJson())),
      };
}

class Tx {
  Tx({
    this.height,
    this.type,
    this.canonical,
    this.timestamp,
    this.sender,
    this.recipient,
    this.data,
    this.amount,
    this.amountAfterFees,
    this.senderBalance,
    this.recipientBalance,
    this.signature,
  });

  int? height;
  int? type;
  int? canonical;
  int? timestamp;
  String? sender;
  String? recipient;
  String? data;
  int? amount;
  int? amountAfterFees;
  int? senderBalance;
  int? recipientBalance;
  String? signature;

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
        height: json["height"],
        type: json["type"],
        canonical: json["canonical"],
        timestamp: json["timestamp"],
        sender: json["sender"],
        recipient: json["recipient"],
        data: json["data"],
        amount: json["amount"],
        amountAfterFees: json["amount_after_fees"],
        senderBalance: json["sender_balance"],
        recipientBalance: json["recipient_balance"],
        signature: json["signature"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "type": type,
        "canonical": canonical,
        "timestamp": timestamp,
        "sender": sender,
        "recipient": recipient,
        "data": data,
        "amount": amount,
        "amount_after_fees": amountAfterFees,
        "sender_balance": senderBalance,
        "recipient_balance": recipientBalance,
        "signature": signature,
      };
}
