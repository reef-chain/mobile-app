import 'dart:convert';

import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/functions.dart';

class SwapCtrl {
  final SwapSettings swapSettings;
  final ReefChainApi reefChainApi;

  SwapCtrl(this.swapSettings,this.reefChainApi);

  Future<dynamic> swapTokens(String signerAddress, TokenWithAmount token1,
      TokenWithAmount token2, SwapSettings settings) async {
    var mappedToken1 = {
      'address': token1.address,
      'decimals': token1.decimals,
      'amount': toAmountDisplayBigInt(token1.amount, decimals: token1.decimals, fractionDigits: token1.decimals),
    };
    var mappedToken2 = {
      'address': token2.address,
      'decimals': token2.decimals,
      'amount': toAmountDisplayBigInt(token2.amount, decimals: token2.decimals, fractionDigits: token2.decimals),
    };

    return reefChainApi.reefState.swapApi.swapTokens(signerAddress, mappedToken1, mappedToken2, settings);
  }

  Future<dynamic> getPoolReserves(
      String token1Address, String token2Address) async {
    return reefChainApi.reefState.swapApi.getPoolReserves(token1Address, token2Address);
  }

  dynamic getSwapAmount(String tokenAmount, bool buy,
      TokenWithAmount token1Reserve, TokenWithAmount token2Reserve) {
   return reefChainApi.reefState.swapApi.getSwapAmount(tokenAmount, buy,token1Reserve,token2Reserve);
  }
}
