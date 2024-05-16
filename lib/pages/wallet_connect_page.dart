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
      child: Column(
        children: [
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
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
                  onPressed: () => showQrTypeDataModal(
                    AppLocalizations.of(context)!.scan_qr_code, context,
                    expectedType: ReefQrCodeType.walletConnect),
                  child: Text(
                    AppLocalizations.of(context)!.create_new_connection,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Styles.whiteColor
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ValueListenableBuilder<List<SessionData>>(
                  valueListenable: ReefAppState.instance.walletConnect.sessions,
                  builder: (context, sessionList, child) {
                    if (sessionList.isEmpty) {
                      return Container(
                        decoration: BoxDecoration(color: Styles.whiteColor,borderRadius: BorderRadius.circular(10.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.error,color: Styles.errorColor,),
                            ),
                            Gap(4.0),
                            Text(
                              AppLocalizations.of(context)!.no_active_sessions, 
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Styles.errorColor)
                            ),
                          ],
                        ),
                      );
                    }
                          
                    return ListView.separated(
                      itemCount: sessionList.length,
                      separatorBuilder: (context, index) => const Gap(10),
                      itemBuilder: (context, index) {
                        final session = sessionList[index];
                        var wcIcon = "https://avatars.githubusercontent.com/u/37784886";
                        var iconSrc = session.peer.metadata.icons.isNotEmpty
                                  ? session.peer.metadata.icons[0]
                                  : wcIcon;
                        return Container(
                          decoration: BoxDecoration(
                            color: Styles.whiteColor,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: ListTile(
                            
                            title: Text(session.peer.metadata.name,style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(session.peer.metadata.url),
                                Text("${AppLocalizations.of(context)!.address}: ${session.namespaces["reef"]?.accounts[0].substring(5).shorten() ?? "???"}"),
                              ],
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(iconSrc,
                                height: 80),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Disconnected ${session.peer.metadata.name} connection")));
                                ReefAppState.instance.walletConnect.disconnectSession(session.topic);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
);
  }

}