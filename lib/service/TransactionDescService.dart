import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/json_big_int.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

  _getValue(dynamic argVal) {
    if (argVal is String) {
      return argVal;
    }
    try {
      return JsonBigInt.toBigInt(argVal) ?? argVal;
    } catch (e) {
      return argVal;
    }
  }

  Map<String, String> parseStringToMap(String input) {
  RegExp regExp = RegExp(r'\{(\w+):\s*(\w+)\}');
  RegExpMatch? match = regExp.firstMatch(input);

  if (match != null) {
    String key = match.group(1)!;
    String value = match.group(2)!;
    return {key: value};
  }
  
  return {};
}

class TransactionDescService {
  static Future<String?> getTransactionDesc(BuildContext context, SignatureRequest? signatureReq) async {
    if (signatureReq == null) return null;

    final loc = AppLocalizations.of(context)!;

    try {
      if (signatureReq.hasResults){
          var evmMethodData = signatureReq.decodedMethod['vm']['evm'];
           var isEVM = evmMethodData != null && !evmMethodData.isEmpty;
          
          if(isEVM){
            var fragmentData = evmMethodData['decodedData']['functionFragment'];
            var args = List.from(fragmentData['inputs']).asMap().map((i, val) =>
                MapEntry(val['name'],
                    _getValue(evmMethodData['decodedData']['args'][i])));
            List<String> argsList =
                args.entries.map((e) => e.key).join(',').split(',');
            List<String> argsValuesList = args.entries
                .map((e) => e.value.toString())
                .join(',')
                .split(',');
            Map<String, String> decodedData = {
              "Contract Address":
                  evmMethodData['contractAddress'],
              "Method Name": fragmentData['name']
            };
            for (var i = 0; i < argsList.length; i++) {
              decodedData[argsList[i]] = argsValuesList[i];
            }

            var methodName = decodedData["Method Name"];

            var contractAddress = decodedData["Contract Address"];

            var contractDetails = await ReefAppState.instance.tokensCtrl.getTokenInfo(contractAddress!);

            if(methodName=="transfer"){
              return loc.send_transaction((BigInt.parse(decodedData["amount"]!).toDouble() / 1e18).toStringAsFixed(2),contractDetails["symbol"],toShortDisplay(decodedData["to"]));
            }
            else if(methodName=="approve"){
              return loc.approveTransaction(
            (BigInt.parse(decodedData["amount"]!).toDouble() / 1e18).toStringAsFixed(2),toShortDisplay(decodedData["spender"]),contractDetails["symbol"]);
            }else if(methodName=="swapExactTokensForTokensSupportingFeeOnTransferTokens"){

            var token1 = await ReefAppState.instance.tokensCtrl.getTokenInfo(decodedData["path"]?.split("[")[1].trim()??"");
            var token2 = await ReefAppState.instance.tokensCtrl.getTokenInfo(decodedData["to"]?.split("]")[0].trim()??"");;

              return loc.swap_transaction((BigInt.parse(decodedData["amountIn"]!).toDouble() / 1e18).toStringAsFixed(2),token1["name"], (BigInt.parse(decodedData["amountOutMin"]!).toDouble()/1e18).toStringAsFixed(2),token2["name"]);
            }else if(methodName=="safeTransferFrom"){
              return loc.nft_transfer(decodedData["amount"]!,decodedData["id"]!,toShortDisplay(decodedData["to"]));
            }
          }else{
         final List<dynamic>? argsList = [
              signatureReq.decodedMethod['args']
            ];
            final String args = argsList?.join(', ').toString() ?? "";
            var methodName =
                signatureReq.decodedMethod['methodName'].split('(')[0];

            String input = args.substring(1, args.length - 1);
            List<String> pairs = input.length > 0 ? input.split(", ") : [];
            Map<String, dynamic> resultMap = {};
            pairs.forEach((pair) {
              List<String> keyValue = pair.split(": ");
              String key = keyValue[0].trim();
              String value = keyValue[1].trim();
              resultMap[key] = value;
            });
            List<String> paramsList = [];
            List<String> paramValuesList = [];
            pairs.forEach((pair) {
              paramsList.add(pair.substring(0, pair.indexOf(":")));
              paramValuesList.add(pair.substring(pair.indexOf(":") + 1));
            });

            Map<String, String> decodedData = {"Method Name": methodName};
            for (var i = 0; i < paramsList.length; i++) {
              if(paramValuesList[i].startsWith(" {")){
                for(var entry in parseStringToMap(paramValuesList[i]).entries)
                 decodedData["${paramsList[i]}.${entry.key}"] = entry.value.toString();
              }else{
                 decodedData[paramsList[i]] = paramValuesList[i];
              }
            }
            var nativeMethodName = decodedData["Method Name"];

            if(nativeMethodName=="balances.transfer"){
              return loc.sending_native_transaction(toShortDisplay(decodedData["dest.Id"]), decodedData["value"]!);
            }else if(nativeMethodName=="evmAccounts.claimDefaultAccount"){
              return loc.claiming_default_account;
            }
          }
      }else{
        return "";
      }
    }catch(e){
      print("ERROR getTransactionDesc ${e}");
    }
    return null;
  }
}
