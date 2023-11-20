import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reef_mobile_app/components/home/WebviewPage.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';

class InsufficientBalance extends StatelessWidget {
  const InsufficientBalance({super.key});

  @override
  Widget build(BuildContext context) {
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
              builder: (context) => WebViewScreen(
                  title: "Buy Reef",
                  url:
                      "https://onramp.money/main/buy/?appId=487411&walletAddress=${ReefAppState.instance.signingCtrl.accountModel.selectedAddress}}"),
            ),
          )
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: const LinearGradient(colors: [
              Color(0xffae27a5),
              Color(0xff742cb2),
            ]),
            // image: DecorationImage(
            // image: AssetImage("./assets/images/buy-button.png"),
            // fit: BoxFit.fitWidth,
            // opacity: 0.2),
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              "Insufficient Funds! Buy Reef",
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
