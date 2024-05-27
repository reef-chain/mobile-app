import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletConnectSession extends StatefulWidget {
  final String address;
  final String name;
  final String url;
  final String? icon;
  final bool? sessionExists;

  const WalletConnectSession(
      {Key? key, required this.address, required this.name, required this.url, this.icon,this.sessionExists})
      : super(key: key);

  @override
  State<WalletConnectSession> createState() => _WalletConnectSessionState();
}

class _WalletConnectSessionState extends State<WalletConnectSession> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          if (widget.icon != null) Image.network(widget.icon!, height: 80),
          Text(
            "${widget.name} wants to connect to your Reef wallet",
            style: const TextStyle(fontSize: 20),
          ),
          if(widget.sessionExists!)
          Column(children: [

          Gap(4.0),
          Text(
            "A session is already active, connecting this will disconnect old session!",
            style: const TextStyle(fontSize: 16,color: Styles.errorColor),
          ),
          ],),
          const Gap(16),
          ViewBoxContainer(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Styles.boxBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Gap(4.0),
                                      Text('URL: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text(
                                        '${widget.url}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Styles.textColor),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Account: ${widget.address}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                const Gap(12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      shadowColor: const Color(0x559d6cff),
                      elevation: 5,
                      backgroundColor: Styles.primaryAccentColorDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      "Approve",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Styles.whiteColor
                      ),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(AppLocalizations.of(context)!.auth_reject,
                        style: TextStyle(
                          color: Styles.errorColor,
                          fontSize: 16,
                        ))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> showWalletConnectSessionModal({
  required address, required name, required url, icon,sessionExists}
) {
  return showModal(navigatorKey.currentContext,
      child: WalletConnectSession(
        address: address,
        name: name,
        url: url,
        icon: icon,
        sessionExists:sessionExists,
      ),
      dismissible: false,
      headText: "WalletConnect Session");
}
