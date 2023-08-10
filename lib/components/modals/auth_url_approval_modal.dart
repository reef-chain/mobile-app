import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthUrlApproval extends StatefulWidget {
  final String origin;
  final String url;
  const AuthUrlApproval({Key? key, required this.origin, required this.url})
      : super(key: key);

  @override
  State<AuthUrlApproval> createState() => _AuthUrlApprovalState();
}

class _AuthUrlApprovalState extends State<AuthUrlApproval> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          Text(
            "An application, self-identifying as ${widget.origin} is requesting access from ${widget.url}.",
            style: const TextStyle(fontSize: 16),
          ),
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
                    Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      size: 16,
                      color: Styles.primaryAccentColorDark,
                    ),
                    const Gap(6),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .approve_domain_message,
                                style: TextStyle(
                                    fontSize: 16, color: Styles.textColor),
                                textAlign: TextAlign.justify,
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
                      AppLocalizations.of(context)!.auth_allow,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
                          color: Styles.primaryAccentColorDark,
                          decoration: TextDecoration.underline,
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

Future<dynamic> showAuthUrlApprovalModal({required origin, required url}) {
  return showModal(navigatorKey.currentContext,
      child: AuthUrlApproval(
        origin: origin,
        url: url,
      ),
      dismissible: false,
      headText: "Authorize");
}
