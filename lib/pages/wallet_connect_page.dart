import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectPage extends StatefulWidget {
  const WalletConnectPage({Key? key}) : super(key: key);

  @override
  State<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends State<WalletConnectPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 32),
            child: Column(children: [
              const Text("Scan QR code to create new connection", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        shadowColor: const Color(0x559d6cff),
                        elevation: 5,
                        backgroundColor: Styles.secondaryAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => showQrTypeDataModal(
                        AppLocalizations.of(context)!.scan_qr_code, context,
                        expectedType: ReefQrCodeType.walletConnect),
                      child: const Text(
                        "Create new connection",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],)
          ),
          ValueListenableBuilder<List<SessionData>>(
            valueListenable: ReefAppState.instance.walletConnect.sessions, 
            builder: (context, sessionList, child) {
              if (sessionList.isEmpty) {
                return const Text(
                  "No active sessions", 
                  style: TextStyle(fontSize: 16)
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: sessionList.length,
                  itemBuilder: (context, index) {
                    final session = sessionList[index];
                    return ListTile(
                      title: Text(session.peer.metadata.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.peer.metadata.url),
                          Text("Address: ${session.namespaces["reef"]?.accounts[0].substring(5).shorten() ?? "???"}"),
                      ]),
                      leading: Image.network(session.peer.metadata.icons.isNotEmpty 
                          ? session.peer.metadata.icons[0] 
                          : "https://avatars.githubusercontent.com/u/37784886",
                        height: 80),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          ReefAppState.instance.walletConnect.disconnectSession(session.topic);
                        },
                      ),
                    );
                  },
                ),
              );
            }
          ),
        ],
      );
  }

}
