import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:restart_app/restart_app.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
   String? jsConnState;
  String? indexerConnState;
  String? providerConnState;
  StreamSubscription? jsConnStateSubs;
  StreamSubscription? providerConnStateSubs;
  StreamSubscription? indexerConnStateSubs;

  @override
  void dispose() {
    jsConnStateSubs?.cancel();
    providerConnStateSubs?.cancel();
    indexerConnStateSubs?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    providerConnStateSubs =
        ReefAppState.instance.networkCtrl.getProviderConnLogs().listen((event) {
      setState(() {
        providerConnState = event != null && event.isConnected
            ? 'connected'
            : event?.toString();
      });
    });
    indexerConnStateSubs =
        ReefAppState.instance.networkCtrl.getIndexerConnected().listen((event) {
      setState(() {
        indexerConnState = event!=null && !!event
            ? 'connected'
            : event?.toString();
      });
    });
    jsConnStateSubs =
        ReefAppState.instance.metadataCtrl.getJsConnStream().listen((event) {
      setState(() {
        jsConnState = event!=null && !!event
            ? 'connected'
            : event?.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...getDivider(),
            Text('JS conn: ${jsConnState ?? "getting status"}'),
            ...getDivider(),
            Text('Indexer conn: ${indexerConnState ?? "getting indexer status"}'),
            ...getDivider(),
            Text('Provider conn: ${providerConnState ?? "getting provider status"}'),
            ...getDivider(),
            ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34)),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 0,
                    backgroundColor:  const Color(0xffe6e2f1),
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: ()async{
                    await ReefAppState.instance.networkCtrl.reconnectProvider();
                  },
                  child: Ink(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffe6e2f1),
                      gradient:const LinearGradient(colors: [
                              Color(0xffae27a5),
                              Color(0xff742cb2),
                            ]),
                      borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                    ),
                    child: Center(
                      child: Text(
                        "Reconnect Provider",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:  Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
          ],
        ));
  }
}

void showReconnectProviderModal(String title,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: AddAccount(), headText: title);
}

List<Widget> getDivider(){
  return [const Gap(7),
    const Divider(
      color: Styles.textLightColor,
      thickness: 0.1,
    ),
    const Gap(2)];
}