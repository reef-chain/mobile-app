import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/utils/extract_signature_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TransactionDescService {
  static Future<String?> getTransactionDesc(BuildContext context, SignatureRequest? request) async {
    if (request == null) return null;

    var signatureDetails = extractSignatureDetails(request);

    final method = signatureDetails["Method Name"];
    final contractAddress = signatureDetails["Contract Address"];
    final amount = signatureDetails["value"];
    final recipientAddress = signatureDetails["dest.Id"];
    const tokenSymbol = "Reef"; // Assuming you have a token symbol

    String shortAddr(String addr) =>
        '${addr.substring(0, 2)}...${addr.substring(addr.length - 5)}';

    // Retrieve localized strings
    final loc = AppLocalizations.of(context)!;

    if (isMethod(method, 'approve') && isApproveContract(contractAddress)) {
      return loc.approveTransaction(amount, tokenSymbol, shortAddr(recipientAddress));
    } else if (isMethod(method, 'swap') && isSwapContract(contractAddress)) {
      return loc.swapTransaction(amount, tokenSymbol, shortAddr(recipientAddress));
    } else if (isMethod(method, 'transfer')) {
      return loc.transferTransaction(amount, shortAddr(recipientAddress));
    } else if (isMethod(method, 'sendErc20')) {
      return loc.sendErc20Transaction(amount, tokenSymbol, shortAddr(recipientAddress));
    } else if (isMethod(method, 'sendNft') && isNftContract(contractAddress)) {
      final tokenId = request.payload.tokenId; // Assuming tokenId is in payload
      return loc.sendNftTransaction(tokenId, shortAddr(recipientAddress));
    } else if (isMethod(method, 'bindAccount')) {
      return loc.bindAccountTransaction(request.payload.accountDetails); // Assuming account details are in payload
    }

    return null;
  }

  static bool isMethod(String? method, String constMethod) {
    return method?.contains(constMethod) ?? false;
  }

  static bool isApproveContract(String? contractAddress) {
    // Implement your logic to verify the contract address for approval
    return true;
  }

  static bool isSwapContract(String? contractAddress) {
    // Implement your logic to verify the contract address for swap
    return true;
  }

  static bool isNftContract(String? contractAddress) {
    // Implement your logic to verify the contract address for NFT
    return true;
  }
}
