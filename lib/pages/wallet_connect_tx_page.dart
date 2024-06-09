import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/CircularCountdown.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletConnectTxPage extends StatefulWidget {
  const WalletConnectTxPage({super.key});

  @override
  State<WalletConnectTxPage> createState() => _WalletConnectTxPageState();
}

class _WalletConnectTxPageState extends State<WalletConnectTxPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(
        color: Styles.whiteColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Gap(4.0),
              Text(
                "Confirming Transaction with WalletConnect",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Styles.textColor,
                ),
              ),
              Gap(4.0),
              CircularCountDown(
                countdownMs: 10000,
                width: 75,
                height: 75,
                fillColor: Styles.blueColor,
                strokeWidth: 4,
                svgAssetPath: 'assets/images/walletconnect.svg',
              ),
              Gap(4.0),
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
                  Navigator.pop(context);
                },
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "OK",
                        style: TextStyle(
                          fontSize: 14,
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