// To parse this JSON data, do
//
//     final tokensBalancesResponse = tokensBalancesResponseFromJson(jsonString);

// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:nyzo_wallet/Data/Token.dart';

TokensBalancesResponse tokensBalancesResponseFromJson(String str) =>
    TokensBalancesResponse.fromJson(json.decode(str));

class TokensBalancesResponse {
  TokensBalancesResponse({
    this.tokensList,
  });

  factory TokensBalancesResponse.fromJson(Map<String, dynamic> json) {
    final List<Token>? _tokensList = List<Token>.empty(growable: true);
    json.forEach((String key, value) {
      _tokensList!.add(Token(
          isNFT: false,
          name: key,
          uid: '',
          amount:
              value['amount'] == null ? null : double.tryParse(value['amount']),
          comment: ''));
    });
    final TokensBalancesResponse tokensBalancesResponse =
        TokensBalancesResponse();
    tokensBalancesResponse.tokensList = _tokensList;
    return tokensBalancesResponse;
  }

  List<Token>? tokensList = List<Token>.empty(growable: true);
}
