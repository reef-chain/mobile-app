import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/json_big_int.dart';

Map<String, dynamic> extractSignatureDetails(SignatureRequest? signatureReq) {
  if (signatureReq == null || !signatureReq.hasResults) {
    return {};
  }

  var evmMethodData = signatureReq.decodedMethod['vm']['evm'];
  var isEVM = evmMethodData != null && !evmMethodData.isEmpty;

  if (isEVM == true) {
    var fragmentData = evmMethodData['decodedData']['functionFragment'];
    var args = List.from(fragmentData['inputs']).asMap().map((i, val) =>
        MapEntry(
            val['name'], _getValue(evmMethodData['decodedData']['args'][i])));
    List<String> argsList = args.entries.map((e) => e.key).join(',').split(',');
    List<String> argsValuesList =
        args.entries.map((e) => e.value.toString()).join(',').split(',');
    Map<String, String> decodedData = {
      "Contract Address": toShortDisplay(evmMethodData['contractAddress']),
      "Method Name": fragmentData['name']
    };
    for (var i = 0; i < argsList.length; i++) {
      decodedData[argsList[i]] = argsValuesList[i];
    }

    return decodedData;
  } else {
    final List<dynamic>? argsList = [signatureReq?.decodedMethod['args']];
    final String args = argsList?.join(', ').toString() ?? "";
    var methodName = signatureReq.decodedMethod['methodName'].split('(')[0];

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
      if (paramValuesList[i].startsWith(" {")) {
        for (var entry in parseStringToMap(paramValuesList[i]).entries)
          decodedData["${paramsList[i]}.${entry.key}"] = entry.value.toString();
      } else {
        decodedData[paramsList[i]] = paramValuesList[i];
      }
    }
    return decodedData;
  }
  
}

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