import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/reconnect_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class ConnectWrapperButton extends StatefulWidget {
  final Widget child;
  const ConnectWrapperButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ConnectWrapperButton> createState() => _ConnectWrapperButtonState();
}

class _ConnectWrapperButtonState extends State<ConnectWrapperButton> {
  var indexerConn = false;
  var providerConn = false;
  var jsConn = false;
  List<StreamSubscription> listeners = [];

  @override
  void initState() {
    listeners.add(
        ReefAppState.instance.networkCtrl.getProviderConnLogs().listen((event) {
      setState(() {
        this.providerConn = event != null && event.isConnected;
      });
    }));
    listeners.add(
        ReefAppState.instance.networkCtrl.getIndexerConnected().listen((event) {
      setState(() {
        this.indexerConn = event != null && event == true;
      });
    }));
    ReefAppState.instance.metadataCtrl.getJsConnStream().then((jsStream) {
      listeners.add(jsStream.listen((event) {
        setState(() {
          this.jsConn = event != null && event == true;
        });
      }));
    });

    super.initState();
  }

  @override
  void dispose() {
    listeners.forEach((element) => element.cancel());
    super.dispose();
  }

  // modal
  void showReconnectProviderModal(String title, {BuildContext? context}) {
    showModal(context ?? navigatorKey.currentContext,
        child: ConnectionDetails(), headText: title);
  }

  @override
  Widget build(BuildContext context) {
    var isConnected = jsConn&&indexerConn&&providerConn;
    return isConnected?widget.child:SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor:  Color.fromARGB(255, 125, 125, 125),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () {
          showReconnectProviderModal(AppLocalizations.of(context)!.connection_stats);
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient:  null,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
           
          ),
          child: Center(
            child: Text(
              "Connecting...",
              style: TextStyle(
                fontSize: 16,
                color:  const Color(0x65898e9c),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
