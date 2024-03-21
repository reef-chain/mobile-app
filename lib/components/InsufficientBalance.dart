import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/home/WebviewPage.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class InsufficientBalance extends StatelessWidget {
  const InsufficientBalance({super.key});

  @override
  Widget build(BuildContext context) {
    var isMainnet = ReefAppState
        .instance.model.network.selectedNetworkName ==
        Network.mainnet.name;
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor: const Color(0xffe6e2f1),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return WebViewScreen(
                  title: isMainnet?"Buy Reef":"Get Reef Testnet Tokens",
                  url: isMainnet
                      ? "https://onramp.money/main/buy/?appId=487411&walletAddress=${ReefAppState.instance.signingCtrl.accountModel.selectedAddress}"
                      : "https://discord.com/channels/793946260171259904/1087737503550816396");
              },
            ),
          )
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: Styles.buttonGradient,
            // image: DecorationImage(
            // image: AssetImage("./assets/images/buy-button.png"),
            // fit: BoxFit.fitWidth,
            // opacity: 0.2),
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              isMainnet?"Buy Reef":"Get Testnet Tokens",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
