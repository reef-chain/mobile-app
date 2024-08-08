import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';

class TransactionDescService {
  static Future<String?> getTransactionDesc(BuildContext context, SignatureRequest? request) async {
    // if (request == null) return null;

    // try {
    //   var signatureDetails = extractSignatureDetails(request);
      
    //   final methodName = signatureDetails["Method Name"];

    //   // if it is evm erc20 transfer 
    //   if(methodName=="transfer"){
    //     final contractAddress = signatureDetails["Contract Address"]; 

    //     final toAddress = signatureDetails["to"];
    //     final amount = signatureDetails["amount"];
    //     return "transferring ${amount} to ${toAddress}";
    //   }
    //   // if it is native reef transfer
    //   else if(methodName=="balances.transfer"){
    //     final dest = signatureDetails["dest.Id"];
    //     final value = signatureDetails["value"];
    //     return "transferring ${value} to ${dest.toString().shorten()}";
    //   }

    //   print("getTransactionDesc ${signatureDetails}");
    // }catch(e){
    //   print("ERROR getTransactionDesc ${e}");
    // }
    return "";
  }
}
