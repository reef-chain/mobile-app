import 'package:reef_mobile_app/model/tokens/Token.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/utils/constants.dart';

import 'token_model.dart';

class TokenCtrl {
  final JsApiService jsApi;

  TokenCtrl(this.jsApi, TokenModel tokenModel) {
    jsApi.jsObservable('appState.tokenPrices\$').listen((tokens) {
      if (tokens == null) {
        return;
      }
      List<TokenWithAmount> tknList =
          List.from(tokens.map((t) => TokenWithAmount.fromJSON(t)));
      tokenModel.setSelectedSignerTokens(tknList);
    });

    // get real list with all available tokens
    /*List<TokenWithAmount> tknList = [
      TokenWithAmount(
          name: 'REEF',
          address: Constants.REEF_TOKEN_ADDRESS,
          iconUrl:
              'https://s2.coinmarketcap.com/static/img/coins/64x64/6951.png',
          symbol: 'REEF',
          balance: BigInt.parse('1542087625938626180855'),
          decimals: 18,
          amount: BigInt.zero,
          price: 0.0841),
      TokenWithAmount(
          name: 'Free Mint Token',
          address: '0x4676199AdA480a2fCB4b2D4232b7142AF9fe9D87',
          iconUrl: '',
          symbol: 'FMT',
          balance: BigInt.parse('2761008739220176308876'),
          decimals: 18,
          amount: BigInt.zero,
          price: 0),
      TokenWithAmount(
          name: 'Reef To Moon',
          address: '0x06E346efDfB45ECe8e2F17Baef9a9d7aCF2f3653',
          iconUrl: '',
          symbol: 'RTM',
          balance: BigInt.parse('0'),
          decimals: 18,
          amount: BigInt.zero,
          price: 0)
    ];
    tokenModel.setTokenList(tknList);*/

    jsApi.jsObservable('appState.selectedSignerNFTs\$').listen((tokens) {
      if (tokens == null) {
        return;
      }
      print('NFTs=${tokens}');
      List<TokenNFT> tknList =
          List.from(tokens.map((t) => TokenNFT.fromJSON(t)));
      tokenModel.setSelectedSignerNFTs(tknList);
    });

    jsApi.jsObservable('appState.reefPrice\$').listen((value) {
      if (value == null) {
        return;
      }
      tokenModel.setReefPrice(value);
    });

    jsApi.jsObservable('appState.transferHistory\$').listen((items) {
      if (items == null) {
        return;
      }
      List<TokenActivity> tknList =
          List.from(items.map((i) => TokenActivity.fromJSON(i)));
      tokenModel.setTokenActivity(tknList);
    });
  }

  Future<dynamic> findToken(String address) async {
    return jsApi.jsPromise('utils.findToken("$address")');
  }
}
