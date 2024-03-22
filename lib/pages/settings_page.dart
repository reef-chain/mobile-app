import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/components/modals/language_selection_modal.dart';
import 'package:reef_mobile_app/components/switch_network.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showDeveloperSettings = false;
  bool _isDevMenuHidden = true;
  int _userTapsCount = 0;

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
    ReefAppState.instance.metadataCtrl.getJsConnStream().then((jsStream) {
      jsConnStateSubs =
          jsStream.listen((event) {
            setState(() {
              jsConnState = event!=null && !!event
                  ? 'connected'
                  : event?.toString();
            });
          });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
            height: MediaQuery.of(context).size.height,
            color: Styles.primaryBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return InkWell(
                    onTap: (){
                      if(_userTapsCount<4){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tap ${4-_userTapsCount} more times to enable developer settings"),duration: Duration(milliseconds: 650),));
                        setState(() {
                          _userTapsCount++;
                        });
                      }else{
                      if(_isDevMenuHidden){
                        setState(() {
                          _isDevMenuHidden=false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are a developer now"),duration: Duration(milliseconds: 1500),));
                      }
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.settings,
                      style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w500,
                          fontSize: 32,
                          color: Colors.grey[800]),
                    ),
                  );
                }),
                const Gap(24),
                Observer(builder: (_) {
                  var navigateOnAccountSwitchVal = ReefAppState
                      .instance.model.appConfig.navigateOnAccountSwitch;

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(children: [
                      const Icon(
                        Icons.home,
                        color: Styles.textLightColor,
                        size: 22,
                      ),
                      const Gap(9),
                      Text(
                          AppLocalizations.of(context)!
                              .go_to_home_on_account_switch,
                          style: Theme.of(context).textTheme.bodyLarge)
                    ]),
                    value: navigateOnAccountSwitchVal,
                    onChanged: (newValue) {
                      ReefAppState.instance.appConfigCtrl
                          .setNavigateOnAccountSwitch(newValue == true);
                    },
                    fillColor: MaterialStateProperty.all<Color>(
                          Styles.whiteColor),
                    checkColor: Styles.purpleColor,
                    side: BorderSide(color: Styles.textLightColor)
                  );
                }),
                Observer(builder: (_) {
                  var isBiometricAuthEnabled = ReefAppState
                      .instance.model.appConfig.isBiometricAuthEnabled;

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(children: [
                      const Icon(
                        Icons.fingerprint,
                        color: Styles.textLightColor,
                        size: 22,
                      ),
                      const Gap(9),
                      Text(AppLocalizations.of(context)!.biometric_auth,
                          style: Theme.of(context).textTheme.bodyLarge)
                    ]),
                    value: isBiometricAuthEnabled,
                    onChanged: (newValue) {
                      ReefAppState.instance.appConfigCtrl
                          .setBiometricAuth(newValue == true);
                    },
                    fillColor: MaterialStateProperty.all<Color>(
                          Styles.whiteColor),
                    checkColor: Styles.purpleColor,
                     side: BorderSide(color: Styles.textLightColor),
                  );
                }),
                const Gap(8),
                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => showChangePasswordModal(
                      AppLocalizations.of(context)!.change_password,
                      context: context),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.lock_fill,
                        color: Styles.textLightColor,
                        size: 22,
                      ),
                      const Gap(8),
                      Builder(builder: (context) {
                        return Text(
                            AppLocalizations.of(context)!.change_password,
                            style: Theme.of(context).textTheme.bodyLarge);
                      }),
                    ],
                  ),
                ),
                const Gap(24),
                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => showSelectLanguageModal(
                      AppLocalizations.of(context)!.select_language,
                      context: context),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.globe,
                        color: Styles.textLightColor,
                        size: 22,
                      ),
                      const Gap(8),
                      Builder(builder: (context) {
                        return Text(
                            AppLocalizations.of(context)!.select_language,
                            style: Theme.of(context).textTheme.bodyLarge);
                      }),
                    ],
                  ),
                ),
                if(!_isDevMenuHidden)
                Column(
                  children: [
                    const Gap(12),
                const Divider(
                  color: Styles.textLightColor,
                  thickness: 1,
                ),
                const Gap(24),
                 InkWell(
                  onTap: () {
                    setState(() {
                      _showDeveloperSettings = !_showDeveloperSettings;
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.code, color: Styles.textLightColor),
                      const Gap(8),
                      Builder(builder: (context) {
                        return Text(
                          AppLocalizations.of(context)!.developer_settings,
                          style: Theme.of(context).textTheme.bodyLarge,
                        );
                      }),
                      Expanded(child: Container()),
                      Icon(_showDeveloperSettings
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
                  ],
                ),
               if (_showDeveloperSettings)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                    child: Column(
                      children: [
                        const Gap(12),
                        MaterialButton(
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onPressed: () => showSwitchNetworkModal(
                              AppLocalizations.of(context)!.switch_network,
                              context: context),
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.network_wifi_1_bar_rounded,
                                color: Styles.textLightColor,
                                size: 22,
                              ),
                              const Gap(8),
                              Text(AppLocalizations.of(context)!.switch_network,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                        FutureBuilder<dynamic>(
                            future: ReefAppState.instance.metadataCtrl
                                .getJsVersions(),
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data);
                              }
                              return const Text('getting version...');
                            }),
                        const Gap(12),
                        Text(
                            'JS conn: ${jsConnState ?? "getting status"}'),
                        const Gap(12),
                        Text(
                            'Indexer conn: ${indexerConnState ?? "getting indexer status"}'),
                        const Gap(12),
                        Text(
                            'Provider conn: ${providerConnState ?? "getting provider status"}'),
                      ],
                    ),
                  ),
              ],
            )));
  }
}
