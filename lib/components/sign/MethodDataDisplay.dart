import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/json_big_int.dart';
import '../../model/signing/signature_request.dart';

class MethodDataDisplay extends StatelessWidget {
  const MethodDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
        if (signatureReq != null && signatureReq!.hasResults) {
          var evmMethodData = signatureReq?.decodedMethod['vm']['evm'];
          var isEVM = evmMethodData != null && !evmMethodData.isEmpty;
          var dataWidget;
          if (isEVM == true) {
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
                  toShortDisplay(evmMethodData['contractAddress']),
              "Method Name": fragmentData['name']
            };
            for (var i = 0; i < argsList.length; i++) {
              decodedData[argsList[i]] = argsValuesList[i];
            }
            final decodedDetails = createDecodedDataTable(decodedData);

            dataWidget = Table(children: decodedDetails, columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(4),
            });
          } else {
            final List<dynamic>? argsList = [
              signatureReq?.decodedMethod['args']
            ];
            final String args = argsList?.join(', ').toString() ?? "";
            var methodName =
                signatureReq?.decodedMethod['methodName'].split('(')[0];

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
              decodedData[paramsList[i]] = paramValuesList[i];
            }
            final decodedDetails = createDecodedDataTable(decodedData);
            dataWidget = Table(children: decodedDetails, columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(4),
            });
          }
          return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: Column(
                  children: [
                    Text(isEVM ? 'EVM Contract Call' : 'Method Call ',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Gap(12),
                    dataWidget
                  ],
                )),
          );
        }
        return Container();
      }));

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

  List<TableRow> createDecodedDataTable(Map<String, String> decodedData) {
    List<String> keyTexts = [];
    List<String> valueTexts = [];

    decodedData.forEach((key, value) {
      keyTexts.add(key);
      valueTexts.add(value);
    });

    return createTable(keyTexts: keyTexts, valueTexts: valueTexts);
  }

  List<TableRow> createTable({required keyTexts, required valueTexts}) {
    List<TableRow> rows = [];
    for (int i = 0; i < keyTexts.length; ++i) {
      rows.add(TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: GradientText(
            keyTexts[i],
            gradient: textGradient(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            valueTexts[i],
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.fade,
          ),
        ),
      ]));
    }
    return rows;
  }
}
