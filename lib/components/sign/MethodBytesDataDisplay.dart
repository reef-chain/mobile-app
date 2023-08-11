import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../model/signing/signature_request.dart';

class MethodBytesDataDisplay extends StatelessWidget {
  MethodBytesDataDisplay(this.signatureReq,this.bytes, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;
  dynamic bytes;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
    if (signatureReq != null && signatureReq!.hasResults && bytes != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Message to be signed",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              bytes.toString(),
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return Container();
  }));
}
