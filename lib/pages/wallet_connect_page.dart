import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/components/modals/restore_json_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class WalletConnectPage extends StatefulWidget {
  const WalletConnectPage({Key? key}) : super(key: key);

  @override
  State<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends State<WalletConnectPage> {
  var hasAccounts = false;
  var accsFeedbackDataModel = ReefAppState.instance.model.accounts.accountsFDM;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() {
    ReefAppState.instance.storage.getAllAccounts().then((value) => setState(() {
          hasAccounts = value.isNotEmpty;
        }));
  }

  void openModal(String modalName) {
    switch (modalName) {
      case 'addAccount':
        showCreateAccountModal(context);
        break;
      case 'importAccount':
        showCreateAccountModal(context, fromMnemonic: true);
        break;
      case 'restoreJSON':
        showRestoreJson(context);
        break;
      case 'importFromQR':
        showQrTypeDataModal(
            AppLocalizations.of(context)!.import_the_account, context,
            expectedType: ReefQrCodeType.accountJson);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (accsFeedbackDataModel.hasStatus(StatusCode.completeData)) {
          _fetchAccounts();
        }
        return hasAccounts
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 32),
                    child: Column(
                      children: [
                        const Gap(16),
                        if (hasAccounts)
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
                                      AppLocalizations.of(context)!
                                          .scan_qr_code,
                                      context,
                                      expectedType:
                                          ReefQrCodeType.walletConnect),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .create_new_connection,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Styles.whiteColor),
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
                              child:
                                  ValueListenableBuilder<List<SessionData>>(
                                valueListenable: ReefAppState
                                    .instance.walletConnect.sessions,
                                builder: (context, sessionList, child) {
                                  if (sessionList.isEmpty) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Styles.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: Icon(
                                              Icons.error,
                                              color: Styles.errorColor,
                                            ),
                                          ),
                                          Gap(4.0),
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .no_active_sessions,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Styles.errorColor)),
                                        ],
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    itemCount: sessionList.length,
                                    separatorBuilder: (context, index) =>
                                        const Gap(10),
                                    itemBuilder: (context, index) {
                                      final session = sessionList[index];
                                      var wcIcon =
                                          "https://avatars.githubusercontent.com/u/37784886";
                                      var iconSrc = session.peer.metadata.icons
                                              .isNotEmpty
                                          ? session.peer.metadata.icons[0]
                                          : wcIcon;
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Styles.whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: CustomSessionTile(
                                          session: session,
                                          iconSrc: iconSrc,
                                          onDelete: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Disconnected ${session.peer.metadata.name} connection")));
                                            ReefAppState
                                                .instance.walletConnect
                                                .disconnectSession(
                                                    session.topic);
                                          },
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
              )
            : Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Gap(16.0),
                      Text(
                        "No Account currently available, create or import an account to create WalletConnect session.",
                        style: TextStyle(fontSize: 14.0),
                      ),
                      Gap(14.0),
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
                          showAddAccountModal(
                              AppLocalizations.of(context)!.add_account,
                              openModal,
                              context: context);
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Styles.whiteColor,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.add_account,
                                overflow: TextOverflow.ellipsis,
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
              );
      },
    );
  }
}

class CustomSessionTile extends StatelessWidget {
  final SessionData session;
  final String iconSrc;
  final VoidCallback onDelete;

  const CustomSessionTile({
    Key? key,
    required this.session,
    required this.iconSrc,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              iconSrc,
              height: 80,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return CircularProgressIndicator();
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(
                  Icons.error,
                  color: Styles.greyColor,
                );
              },
            ),
          ),
          const Gap(12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.peer.metadata.name,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(4.0),
                Text(session.peer.metadata.url),
                const Gap(4.0),
                Text(
                    "${AppLocalizations.of(context)!.address}: ${session.namespaces["reef"]?.accounts[0].substring(5).shorten() ?? "???"}"),
                const Gap(4.0),
                Text(
                    "Expiry: ${DateFormat('dd/MM/yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000).toLocal())}",
                    style: TextStyle(fontSize: 12.0)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
