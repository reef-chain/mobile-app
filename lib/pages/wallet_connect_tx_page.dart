import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/CircularCountdown.dart';
import 'package:reef_mobile_app/utils/styles.dart';

// ================== CONSTANTS ==================
const double kWCTxMarginTop = 12.0;
const double kWCTxBorderRadius = 12.0;

const double kWCTxPaddingAll = 16.0;

const double kWCTxGap4 = 4.0;

const double kWCTxTitleFontSize = 18.0;

const int kWCTxCountdownMs = 10000;
const double kWCTxCountdownSize = 75.0;
const double kWCTxCountdownStroke = 4.0;

const double kWCTxBtnRadius = 40.0;
const double kWCTxBtnPaddingV = 12.0;
const double kWCTxBtnPaddingH = 28.0;
const double kWCTxBtnFontSize = 14.0;
// ==============================================

class WalletConnectTxPage extends StatefulWidget {
  const WalletConnectTxPage({super.key});

  @override
  State<WalletConnectTxPage> createState() => _WalletConnectTxPageState();
}

class _WalletConnectTxPageState extends State<WalletConnectTxPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: kWCTxMarginTop),
      decoration: BoxDecoration(
        color: Styles.whiteColor,
        borderRadius: BorderRadius.circular(kWCTxBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kWCTxPaddingAll),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const Gap(kWCTxGap4),

              Text(
                "Confirming Transaction with WalletConnect",
                style: TextStyle(
                  fontSize: kWCTxTitleFontSize,
                  fontWeight: FontWeight.w700,
                  color: Styles.textColor,
                ),
              ),

              const Gap(kWCTxGap4),

              CircularCountDown(
                countdownMs: kWCTxCountdownMs,
                width: kWCTxCountdownSize,
                height: kWCTxCountdownSize,
                fillColor: Styles.blueColor,
                strokeWidth: kWCTxCountdownStroke,
                svgAssetPath: 'assets/images/walletconnect.svg',
              ),

              const Gap(kWCTxGap4),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kWCTxBtnRadius),
                  ),
                  shadowColor: const Color(0x559d6cff),
                  elevation: 5,
                  backgroundColor: Styles.primaryAccentColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: kWCTxBtnPaddingV,
                    horizontal: kWCTxBtnPaddingH,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "OK",
                        style: TextStyle(
                          fontSize: kWCTxBtnFontSize,
                          fontWeight: FontWeight.w700,
                          color: Styles.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
