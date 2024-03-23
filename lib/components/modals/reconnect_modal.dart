import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/CircularCountdown.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:restart_app/restart_app.dart';

class ConnectionDetails extends StatefulWidget {
  const ConnectionDetails({Key? key}) : super(key: key);

  @override
  State<ConnectionDetails> createState() => _ConnectionDetailsState();
}

class _ConnectionDetailsState extends State<ConnectionDetails> {
  bool jsConn = false;
  bool indexerConn = false;
  bool providerConn = false;
  String jsConnLabel = 'getting status';
  String indexerConnLabel = 'getting status';
  String providerConnLabel = 'getting status';

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
        providerConn = event != null && event.isConnected;
        providerConnLabel =
            providerConn ? 'connected' : providerConn.toString();
      });
    });
    indexerConnStateSubs =
        ReefAppState.instance.networkCtrl.getIndexerConnected().listen((event) {
      setState(() {
        indexerConn = event != null && !!event;
        indexerConnLabel = indexerConn ? 'connected' : indexerConn.toString();
      });
    });
    ReefAppState.instance.metadataCtrl.getJsConnStream().then((jsStream) {
      jsConnStateSubs = jsStream.listen((event) {
        setState(() {
          jsConn = event != null && !!event;
          jsConnLabel = jsConn ? 'connected' : jsConn.toString();
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var allConnected = jsConn && indexerConn && providerConn;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...getDivider(),
          Text('JS conn: ${jsConnLabel}'),
          ...getDivider(),
          Text('Indexer conn: ${indexerConnLabel}'),
          ...getDivider(),
          Text('Provider conn: ${providerConnLabel}'),
          ...getDivider(),
          Text(AppLocalizations.of(context)!.allow_10_s,
            style: TextStyle(color: Styles.textLightColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if(!allConnected)ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34)),
                  shadowColor: const Color(0x559d6cff),
                  elevation: 0,
                  backgroundColor: const Color(0xffe6e2f1),
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  Restart.restartApp();
                },
                child: Ink(
                  width: 140, // Adjust width as needed
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Styles.purpleColor,
                    gradient: Styles.buttonGradient,
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularCountDown(countdownMs: 10000),
                        Gap(8.0),
                        Text(
                          AppLocalizations.of(context)!.restart_app,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34)),
                  shadowColor: const Color(0x559d6cff),
                  elevation: 0,
                  backgroundColor: Styles.greyColor,
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Styles.textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showReconnectProviderModal(String title, {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ConnectionDetails(), headText: title);
}

List<Widget> getDivider() {
  return [
    const Gap(7),
    const Divider(
      color: Styles.textLightColor,
      thickness: 0.1,
    ),
    const Gap(2)
  ];
}
