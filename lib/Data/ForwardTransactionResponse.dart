// To parse this JSON data, do
//
//     final forwardTransactionResponse = forwardTransactionResponseFromJson(jsonString);

import 'dart:convert';

ForwardTransactionResponse forwardTransactionResponseFromJson(String str) => ForwardTransactionResponse.fromJson(json.decode(str));

String forwardTransactionResponseToJson(ForwardTransactionResponse data) => json.encode(data.toJson());

class ForwardTransactionResponse {
    ForwardTransactionResponse({
        this.notices,
        this.errors,
        this.result,
    });

    List<dynamic>? notices;
    List<String>? errors;
    List<Result>? result;

    factory ForwardTransactionResponse.fromJson(Map<String, dynamic> json) => ForwardTransactionResponse(
        notices: json["notices"] == null ? null : List<dynamic>.from(json["notices"].map((x) => x)),
        errors: json["errors"] == null ? null : List<String>.from(json["errors"].map((x) => x)),
        result: json["result"] == null ? null : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "notices": notices == null ? null : List<dynamic>.from(notices!.map((x) => x)),
        "errors": errors == null ? null : List<dynamic>.from(errors!.map((x) => x)),
        "result": result == null ? null : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    Result({
        this.blockHeight,
        this.senderIdBytes,
        this.senderIdNyzoString,
        this.receiverIdBytes,
        this.receiverIdNyzoString,
        this.amount,
        this.previousVerifierIdBytes,
        this.previousVerifierIdNyzoString,
        this.expectedVerifierIdBytes,
        this.expectedVerifierIdNyzoString,
        this.nextVerifierIdBytes,
        this.nextVerifierIdNyzoString,
        this.forwarded,
        this.previouslyForwarded,
        this.inBlockchain,
        this.age,
        this.senderBalance,
        this.supplementalTransactionValid,
        this.senderDataBytes,
    });

    int? blockHeight;
    String? senderIdBytes;
    String? senderIdNyzoString;
    String? receiverIdBytes;
    String? receiverIdNyzoString;
    String? amount;
    dynamic previousVerifierIdBytes;
    dynamic previousVerifierIdNyzoString;
    dynamic expectedVerifierIdBytes;
    dynamic expectedVerifierIdNyzoString;
    dynamic nextVerifierIdBytes;
    dynamic nextVerifierIdNyzoString;
    bool? forwarded;
    bool? previouslyForwarded;
    bool? inBlockchain;
    double? age;
    String? senderBalance;
    bool? supplementalTransactionValid;
    String? senderDataBytes;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        blockHeight: json["blockHeight"] == null ? null : json["blockHeight"],
        senderIdBytes: json["senderIdBytes"] == null ? null : json["senderIdBytes"],
        senderIdNyzoString: json["senderIdNyzoString"] == null ? null : json["senderIdNyzoString"],
        receiverIdBytes: json["receiverIdBytes"] == null ? null : json["receiverIdBytes"],
        receiverIdNyzoString: json["receiverIdNyzoString"] == null ? null : json["receiverIdNyzoString"],
        amount: json["amount"] == null ? null : json["amount"],
        previousVerifierIdBytes: json["previousVerifierIdBytes"],
        previousVerifierIdNyzoString: json["previousVerifierIdNyzoString"],
        expectedVerifierIdBytes: json["expectedVerifierIdBytes"],
        expectedVerifierIdNyzoString: json["expectedVerifierIdNyzoString"],
        nextVerifierIdBytes: json["nextVerifierIdBytes"],
        nextVerifierIdNyzoString: json["nextVerifierIdNyzoString"],
        forwarded: json["forwarded"] == null ? null : json["forwarded"],
        previouslyForwarded: json["previouslyForwarded"] == null ? null : json["previouslyForwarded"],
        inBlockchain: json["inBlockchain"] == null ? null : json["inBlockchain"],
        age: json["age"] == null ? null : json["age"].toDouble(),
        senderBalance: json["senderBalance"] == null ? null : json["senderBalance"],
        supplementalTransactionValid: json["supplementalTransactionValid"] == null ? null : json["supplementalTransactionValid"],
        senderDataBytes: json["senderDataBytes"] == null ? null : json["senderDataBytes"],
    );

    Map<String, dynamic> toJson() => {
        "blockHeight": blockHeight == null ? null : blockHeight,
        "senderIdBytes": senderIdBytes == null ? null : senderIdBytes,
        "senderIdNyzoString": senderIdNyzoString == null ? null : senderIdNyzoString,
        "receiverIdBytes": receiverIdBytes == null ? null : receiverIdBytes,
        "receiverIdNyzoString": receiverIdNyzoString == null ? null : receiverIdNyzoString,
        "amount": amount == null ? null : amount,
        "previousVerifierIdBytes": previousVerifierIdBytes,
        "previousVerifierIdNyzoString": previousVerifierIdNyzoString,
        "expectedVerifierIdBytes": expectedVerifierIdBytes,
        "expectedVerifierIdNyzoString": expectedVerifierIdNyzoString,
        "nextVerifierIdBytes": nextVerifierIdBytes,
        "nextVerifierIdNyzoString": nextVerifierIdNyzoString,
        "forwarded": forwarded == null ? null : forwarded,
        "previouslyForwarded": previouslyForwarded == null ? null : previouslyForwarded,
        "inBlockchain": inBlockchain == null ? null : inBlockchain,
        "age": age == null ? null : age,
        "senderBalance": senderBalance == null ? null : senderBalance,
        "supplementalTransactionValid": supplementalTransactionValid == null ? null : supplementalTransactionValid,
        "senderDataBytes": senderDataBytes == null ? null : senderDataBytes,
    };
}
