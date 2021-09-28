// To parse this JSON data, do
//
//     final tokensListResponse = tokensListResponseFromJson(jsonString);

// Dart imports:
import 'dart:convert';

Map<String, TokensListResponse> tokensListResponseFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) =>
        MapEntry<String, TokensListResponse>(
            k, TokensListResponse.fromJson(v)));

String tokensListResponseToJson(Map<String, TokensListResponse> data) =>
    json.encode(
        Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class TokensListResponse {
  TokensListResponse({
    this.issuer,
    this.owner,
    this.signature,
    this.supply,
    this.supplyInt,
    this.mintable,
    this.decimals,
    this.blockHeight,
    this.timestamp,
  });

  String? issuer;
  String? owner;
  String? signature;
  String? supply;
  double? supplyInt;
  bool? mintable;
  int? decimals;
  int? blockHeight;
  int? timestamp;

  factory TokensListResponse.fromJson(Map<String, dynamic> json) =>
      TokensListResponse(
        issuer: json["issuer"],
        owner: json["owner"],
        signature: json["signature"],
        supply: json["supply"],
        supplyInt: json["supply_int"].toDouble(),
        mintable: json["mintable"],
        decimals: json["decimals"],
        blockHeight: json["block_height"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "issuer": issuer,
        "owner": owner,
        "signature": signature,
        "supply": supply,
        "supply_int": supplyInt,
        "mintable": mintable,
        "decimals": decimals,
        "block_height": blockHeight,
        "timestamp": timestamp,
      };
}
