// To parse this JSON data, do
//
//     final nftAddressInstancesResponse = nftAddressInstancesResponseFromJson(jsonString);

// Dart imports:
import 'dart:convert';

List<NftAddressInstancesResponse> nftAddressInstancesResponseFromJson(
        String str) =>
    List<NftAddressInstancesResponse>.from(
        json.decode(str).map((x) => NftAddressInstancesResponse.fromJson(x)));

String nftAddressInstancesResponseToJson(
        List<NftAddressInstancesResponse> data) =>
    json.encode(List<dynamic>.from(
        data.map((NftAddressInstancesResponse x) => x.toJson())));

class NftAddressInstancesResponse {
  NftAddressInstancesResponse({
    this.nftClass,
    this.nftId,
  });

  String? nftClass;
  String? nftId;

  factory NftAddressInstancesResponse.fromJson(Map<String, dynamic> json) =>
      NftAddressInstancesResponse(
        nftClass: json['nft_class'],
        nftId: json['nft_id'],
      );

  Map<String, dynamic> toJson() => {
        'nft_class': nftClass,
        'nft_id': nftId,
      };
}
