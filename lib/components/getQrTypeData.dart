import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/components/modals/import_account_from_qr.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/password_manager.dart';
import 'package:reef_mobile_app/utils/styles.dart';
// import 'package:qr_code_tools/qr_code_tools.dart';

// lib/components/getQrTypeData.dart

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/splash_screen.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';

// If your PasswordManager / ChangePassword widgets live elsewhere,
// keep this import or adjust to your actual path:
import 'package:reef_mobile_app/utils/password_manager.dart';

class QrDataDisplay extends StatefulWidget {
  final ReefQrCodeType? expectedType;
  final String? preselectedTokenAddress;

  const QrDataDisplay(this.expectedType, this.preselectedTokenAddress, {Key? key})
      : super(key: key);

  @override
  State<QrDataDisplay> createState() => _QrDataDisplayState();
}

class _QrDataDisplayState extends State<QrDataDisplay> {
  final GlobalKey _globalKey = GlobalKey();

  // Keep controller non-null & dispose it properly
  late final MobileScannerController _controller;

  ReefQrCode? qrCodeValue;
  String? qrTypeLabel;
  bool _isProcessing = false; // prevent re-entrancy on scan

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- Human-readable helpers ----------
  String getHumanReadableQrType(ReefQrCodeType? type) {
    switch (type) {
      case ReefQrCodeType.address:
        return "Account Address QR Code";
      case ReefQrCodeType.accountJson:
        return "JSON File QR Code";
      case ReefQrCodeType.walletConnect:
        return "WalletConnect QR Code";
      case ReefQrCodeType.info:
        return "Info QR Code";
      default:
        return "Not a Reef QR Code";
    }
  }

  String getQrDataTypeMessage(ReefQrCodeType? type) {
    switch (type) {
      case ReefQrCodeType.address:
        return "This is an Account Address. You can send funds by scanning this QR code.";
      case ReefQrCodeType.accountJson:
        return "You can import this account by scanning this QR code and entering the password.";
      case ReefQrCodeType.walletConnect:
        return "This is a WalletConnect QR code.";
      case ReefQrCodeType.info:
        return "Information QR.";
      default:
        return "Not a Reef QR code.";
    }
  }

  // ---------- Validation helpers ----------
  Uri? _validateWalletConnectUri(String input) {
    try {
      final uri = Uri.parse(input.trim());
      final okScheme = uri.scheme == 'wc' || uri.scheme == 'reefApp';
      if (!okScheme) return null;

      if (uri.scheme == 'wc') {
        // Minimal wc: "wc:<topic>@<version>?bridge=...&key=..."
        final auth = uri.authority; // "topic@2"
        if (auth.isEmpty || !auth.contains('@')) return null;
        final version = int.tryParse(auth.split('@').last);
        if (version == null || version <= 0) return null;
        if (uri.queryParameters.isEmpty) return null;
      }

      // For "reefApp:" you can add stricter checks if needed
      return uri;
    } catch (_) {
      return null;
    }
  }

  bool _isLikelyAccountJson(String data) {
    try {
      final obj = jsonDecode(data);
      if (obj is Map) {
        final hasAddr = obj.containsKey('address') || obj.containsKey('encoded');
        final hasMeta = obj.containsKey('meta') || obj.containsKey('encoding');
        return hasAddr && hasMeta;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------- Main QR handlers ----------
  Future<void> handleQrCodeData(String qrCodeData) async {
    // 1) Sanitize + size guard
    final raw = qrCodeData.trim();
    if (raw.isEmpty) {
      setState(() {
        qrCodeValue = const ReefQrCode(ReefQrCodeType.invalid, "");
        qrTypeLabel = "Empty QR code.";
      });
      return;
    }
    if (raw.length > 2048) {
      setState(() {
        qrCodeValue = const ReefQrCode(ReefQrCodeType.invalid, "");
        qrTypeLabel = "QR payload too large.";
      });
      return;
    }

    ReefQrCode? finalCode;

    // 2) WalletConnect / deep link
    if (raw.startsWith("wc:") || raw.startsWith("reefApp:")) {
      final uri = _validateWalletConnectUri(raw);
      if (uri != null) {
        finalCode = ReefQrCode(ReefQrCodeType.walletConnect, uri.toString());
      }
    } else {
      // 3) Try JSON structure {"type":"...", "data":"..."}
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded["type"] is String) {
          final tName = (decoded["type"] as String).trim();
          final tData = (decoded["data"] as String?)?.trim() ?? "";
          final maybeType =
          ReefQrCodeType.values.where((e) => e.name == tName).toList();
          if (maybeType.isNotEmpty) {
            finalCode = ReefQrCode(maybeType.first, tData);
          }
        }
      } catch (_) {
        // ignore, try address path
      }

      // 4) Plain Reef address
      if (finalCode == null) {
        try {
          final isAddr = await ReefAppState.instance.accountCtrl
              .isValidSubstrateAddress(raw);
          if (isAddr && isReefAddrPrefix(raw)) {
            finalCode = ReefQrCode(ReefQrCodeType.address, raw);
          }
        } catch (_) {/* ignore */}
      }
    }

    // 5) Finalize & UI
    setState(() {
      qrCodeValue = finalCode ?? const ReefQrCode(ReefQrCodeType.invalid, "");
      if (widget.expectedType != null &&
          widget.expectedType == qrCodeValue!.type) {
        actOnQrCodeValue(qrCodeValue!);
        return;
      }

      if (widget.expectedType == ReefQrCodeType.walletConnect &&
          widget.expectedType != qrCodeValue!.type) {
        qrTypeLabel =
        "Please place device correctly, detected ${getHumanReadableQrType(qrCodeValue?.type)} instead of WalletConnect.";
        return;
      }

      qrTypeLabel = getQrDataTypeMessage(qrCodeValue?.type);
    });
  }

  void actOnQrCodeValue(ReefQrCode qrCode) async {
    // Enforce expectedType if provided
    if (widget.expectedType != null && widget.expectedType != qrCode.type) {
      setState(() {
        qrTypeLabel =
        "Expected ${getHumanReadableQrType(widget.expectedType)} but detected ${getHumanReadableQrType(qrCode.type)}.";
      });
      return;
    }

    try {
      switch (qrCode.type) {
        case ReefQrCodeType.address: {
          // Validate defensively again
          final isAddr = await ReefAppState.instance.accountCtrl
              .isValidSubstrateAddress(qrCode.data);
          if (!isAddr || !isReefAddrPrefix(qrCode.data)) {
            setState(() => qrTypeLabel = "Invalid Reef address QR.");
            return;
          }

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ReefAppState.instance.navigationCtrl.navigateToSendPage(
            context: context,
            preselected:
            widget.preselectedTokenAddress ?? Constants.REEF_TOKEN_ADDRESS,
            preSelectedTransferAddress: qrCode.data.trim(),
          );
          break;
        }

        case ReefQrCodeType.accountJson: {
          if (!_isLikelyAccountJson(qrCode.data)) {
            setState(() => qrTypeLabel = "Invalid Account JSON QR.");
            return;
          }

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          if (await PasswordManager.checkIfPassword()) {
            showImportAccountQrModal(data: qrCode);
          } else {
            showModal(
              context,
              headText: "Choose Password",
              child: ChangePassword(
                onChanged: () => showImportAccountQrModal(data: qrCode),
              ),
            );
          }
          break;
        }

        case ReefQrCodeType.walletConnect: {
          final uri = _validateWalletConnectUri(qrCode.data);
          if (uri == null) {
            setState(() => qrTypeLabel = "Invalid WalletConnect URI.");
            return;
          }

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          await ReefAppState.instance.walletConnect.getWeb3Wallet().pair(
            uri: uri,
          );
          break;
        }

        default:
          setState(() => qrTypeLabel = "Unsupported / invalid QR code.");
          break;
      }
    } catch (e) {
      setState(() => qrTypeLabel = "Failed to process QR: $e");
    }
  }

  // ---------- Scan-from-image helper ----------
  Future<String?> scanFile() async {
    try {
      final pickedFile =
      await FilePicker.platform.pickFiles(type: FileType.image);
      if (pickedFile == null) return null;

      final filePath = pickedFile.files.single.path;
      if (filePath == null) return null;

      final res = await MobileScannerController().analyzeImage(filePath);
      final raw = res?.barcodes.first.rawValue;
      return raw?.trim();
    } catch (e) {
      debugPrint("scanFile ERR: $e");
      return null;
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: _globalKey,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button row
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                if (qrCodeValue == null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Center(
                          child: SizedBox(
                            width: 400,
                            height: 300,
                            child: MobileScanner(
                              controller: _controller,
                              onDetect: (capture) async {
                                if (_isProcessing) return;
                                final codes = capture.barcodes;
                                if (codes.isEmpty) return;
                                final val = codes.first.rawValue;
                                if (val == null || val.trim().isEmpty) return;

                                _isProcessing = true;
                                try {
                                  await handleQrCodeData(val);
                                } finally {
                                  _isProcessing = false;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const Gap(16.0),
                      Center(
                        child: ElevatedButton.icon(
                          icon:  Icon(Icons.crop_free,
                              color: Styles.whiteColor),
                          label: Text(
                            AppLocalizations.of(context)!.scan_from_image,
                            style:  TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Styles.whiteColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            shadowColor: const Color(0x559d6cff),
                            elevation: 5,
                            backgroundColor: Styles.primaryAccentColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 28),
                          ),
                          onPressed: () async {
                            final res = await scanFile();
                            if (res != null) {
                              await handleQrCodeData(res);
                            } else {
                              if (Navigator.of(context).mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("No valid QR found in image"),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                if (qrCodeValue != null)
                  Column(
                    children: [
                      Text(qrTypeLabel ?? ''),
                      const Gap(16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          shadowColor: const Color(0x559d6cff),
                          elevation: 5,
                          backgroundColor: Styles.primaryAccentColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 28),
                        ),
                        onPressed: () {
                          // Re-open scanner modal to rescan WalletConnect by default
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          showQrTypeDataModal(
                            AppLocalizations.of(context)!.scan_qr_code,
                            context,
                            expectedType: ReefQrCodeType.walletConnect,
                          );
                        },
                        child:  Text(
                          "Scan again",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Styles.whiteColor),
                        ),
                      ),
                      if (qrCodeValue?.type != ReefQrCodeType.invalid &&
                          widget.expectedType == ReefQrCodeType.info)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              shadowColor: const Color(0x559d6cff),
                              elevation: 5,
                              backgroundColor: const Color(0xff9d6cff),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              actOnQrCodeValue(qrCodeValue!);
                            },
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (widget.expectedType == qrCodeValue?.type)
                        const CircularProgressIndicator(
                          color: Styles.primaryAccentColor,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

// ---------- Modal launcher ----------
void showQrTypeDataModal(
    String title,
    BuildContext context, {
      ReefQrCodeType? expectedType,
      String? preselectedTokenAddress,
    }) {
  showModal(
    context,
    child: QrDataDisplay(expectedType, preselectedTokenAddress),
    headText: title,
  );
}

// ---------- Model ----------
class ReefQrCode {
  final ReefQrCodeType type;
  final String data;

  const ReefQrCode(this.type, this.data);
}

enum ReefQrCodeType { address, accountJson, info, walletConnect, invalid }
