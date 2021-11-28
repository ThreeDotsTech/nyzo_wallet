// To parse this JSON data, do
//
//     final frozenEdgeResponse = frozenEdgeResponseFromJson(jsonString);

import 'dart:convert';

FrozenEdgeResponse frozenEdgeResponseFromJson(String str) => FrozenEdgeResponse.fromJson(json.decode(str));

String frozenEdgeResponseToJson(FrozenEdgeResponse data) => json.encode(data.toJson());

class FrozenEdgeResponse {
    FrozenEdgeResponse({
        this.notices,
        this.errors,
        this.result,
    });

    List<dynamic>? notices;
    List<dynamic>? errors;
    List<Result>? result;

    factory FrozenEdgeResponse.fromJson(Map<String, dynamic> json) => FrozenEdgeResponse(
        notices: json["notices"] == null ? null : List<dynamic>.from(json["notices"].map((x) => x)),
        errors: json["errors"] == null ? null : List<dynamic>.from(json["errors"].map((x) => x)),
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
        this.height,
        this.hash,
        this.verificationTimestampMilliseconds,
        this.distanceFromOpenEdge,
    });

    int? height;
    String? hash;
    int? verificationTimestampMilliseconds;
    int? distanceFromOpenEdge;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        height: json["height"] == null ? null : json["height"],
        hash: json["hash"] == null ? null : json["hash"],
        verificationTimestampMilliseconds: json["verificationTimestampMilliseconds"] == null ? null : json["verificationTimestampMilliseconds"],
        distanceFromOpenEdge: json["distanceFromOpenEdge"] == null ? null : json["distanceFromOpenEdge"],
    );

    Map<String, dynamic> toJson() => {
        "height": height == null ? null : height,
        "hash": hash == null ? null : hash,
        "verificationTimestampMilliseconds": verificationTimestampMilliseconds == null ? null : verificationTimestampMilliseconds,
        "distanceFromOpenEdge": distanceFromOpenEdge == null ? null : distanceFromOpenEdge,
    };
}
