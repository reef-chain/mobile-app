import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';

class StealthexBuyPage extends StatefulWidget {
  const StealthexBuyPage({super.key});

  @override
  State<StealthexBuyPage> createState() => _StealthexBuyPageState();
}

class _StealthexBuyPageState extends State<StealthexBuyPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Text("Buy Reef"),
          ElevatedButton(onPressed: ()async{
            await ReefAppState.instance.stealthexCtrl.listExchanges();
          }, child: Text("test"))
        ],
    );
  }
}