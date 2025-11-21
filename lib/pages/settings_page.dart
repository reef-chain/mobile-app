import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/components/modals/language_selection_modal.dart';
import 'package:reef_mobile_app/components/switch_network.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';

// ===== CONSTANTS =====
const double kSettingsTitleFont = 32.0;
const double kSettingsIconSize = 22.0;
const double kSettingsGap4 = 4.0;


const double kSettingsGap8 = 8.0;
const double kSettingsGap9 = 9.0;
const double kSettingsGap12 = 12.0;
const double kSettingsGap24 = 24.0;

const double kSettingsPadding12 = 12.0;
const double kSettingsPadding2 = 2.0;

const double kDividerThickness = 1.0;

const int kDevUnlockTaps = 4;
const int kSnackShort = 650;
const int kSnackLong = 1500;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showDeveloperSettings = false;
  bool _isDevMenuHidden = false;
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
            providerConnState =
            event != null && event.isConnected ? 'connected' : event?.toString();
          });
        });
    indexerConnStateSubs =
        ReefAppState.instance.networkCtrl.getIndexerConnected().listen((event) {
          setState(() {
            indexerConnState = event != null && !!event ? 'connected' : event?.toString();
          });
        });
    ReefAppState.instance.metadataCtrl.getJsConnStream().then((jsStream) {
      jsConnStateSubs = jsStream.listen((event) {
        setState(() {
          jsConnState = !!event ? 'connected' : event.toString();
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
            padding: const EdgeInsets.symmetric(
                vertical: kSettingsPadding12, horizontal: kSettingsPadding12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return InkWell(
                    onTap: () {
                      if (_userTapsCount < kDevUnlockTaps) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "${AppLocalizations.of(context)!.tap} ${kDevUnlockTaps - _userTapsCount} ${AppLocalizations.of(context)!.more_times_to_enable}"),
                          duration: const Duration(milliseconds: kSnackShort),
                        ));
                        setState(() {
                          _userTapsCount++;
                        });
                      } else {
                        if (_isDevMenuHidden) {
                          setState(() {
                            _isDevMenuHidden = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                            Text(AppLocalizations.of(context)!.you_are_a_dev),
                            duration:
                            const Duration(milliseconds: kSnackLong),
                          ));
                        }
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.settings,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w500,
                        fontSize: kSettingsTitleFont,
                        color: Colors.grey[800],
                      ),
                    ),
                  );
                }),
                const Gap(kSettingsGap12),
                const Divider(
                  color: Styles.textLightColor,
                  thickness: kDividerThickness,
                ),
                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => ReefAppState.instance.navigationCtrl
                      .navigateToWalletConnectPage(context: context),
                  padding: const EdgeInsets.all(kSettingsPadding2),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.qrcode,
                        color: Styles.textLightColor,
                        size: kSettingsIconSize,
                      ),
                      const Gap(kSettingsGap8),
                      Text("WalletConnect",
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                const Divider(
                  color: Styles.textLightColor,
                  thickness: kDividerThickness,
                ),

                Observer(builder: (_) {
                  var navigateOnAccountSwitchVal =
                      ReefAppState.instance.model.appConfig.navigateOnAccountSwitch;

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(children: [
                      const Icon(
                        Icons.home,
                        color: Styles.textLightColor,
                        size: kSettingsIconSize,
                      ),
                      const Gap(kSettingsGap9),
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
                    fillColor:
                    MaterialStateProperty.all<Color>(Styles.whiteColor),
                    checkColor: Styles.purpleColor,
                    side: const BorderSide(color: Styles.textLightColor),
                  );
                }),

                Observer(builder: (_) {
                  var isBiometricAuthEnabled =
                      ReefAppState.instance.model.appConfig.isBiometricAuthEnabled;

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(children: [
                      const Icon(
                        Icons.fingerprint,
                        color: Styles.textLightColor,
                        size: kSettingsIconSize,
                      ),
                      const Gap(kSettingsGap9),
                      Text(AppLocalizations.of(context)!.biometric_auth,
                          style: Theme.of(context).textTheme.bodyLarge)
                    ]),
                    value: isBiometricAuthEnabled,
                    onChanged: (newValue) {
                      ReefAppState.instance.appConfigCtrl
                          .setBiometricAuth(newValue == true);
                    },
                    fillColor:
                    MaterialStateProperty.all<Color>(Styles.whiteColor),
                    checkColor: Styles.purpleColor,
                    side: const BorderSide(color: Styles.textLightColor),
                  );
                }),

                const Gap(kSettingsGap8),

                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => showChangePasswordModal(
                      AppLocalizations.of(context)!.change_password,
                      context: context),
                  padding: const EdgeInsets.all(kSettingsPadding2),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.lock_fill,
                        color: Styles.textLightColor,
                        size: kSettingsIconSize,
                      ),
                      const Gap(kSettingsGap8),
                      Text(AppLocalizations.of(context)!.change_password,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),

                const Gap(kSettingsGap24),

                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => showSelectLanguageModal(
                      AppLocalizations.of(context)!.select_language,
                      context: context),
                  padding: const EdgeInsets.all(kSettingsPadding2),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.globe,
                        color: Styles.textLightColor,
                        size: kSettingsIconSize,
                      ),
                      const Gap(kSettingsGap8),
                      Text(AppLocalizations.of(context)!.select_language,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),

                const Gap(kSettingsGap12),

                if (!_isDevMenuHidden)
                  Column(
                    children: [
                      const Gap(kSettingsGap12),
                      const Divider(
                        color: Styles.textLightColor,
                        thickness: kDividerThickness,
                      ),
                      const Gap(kSettingsGap24),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showDeveloperSettings =
                            !_showDeveloperSettings;
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.code,
                                color: Styles.textLightColor),
                            const Gap(kSettingsGap8),
                            Text(
                              AppLocalizations.of(context)!.developer_settings,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
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
                    padding:
                     EdgeInsets.only(left: kSettingsPadding12, bottom: kSettingsGap4),
                    child: Column(
                      children: [
                        const Gap(kSettingsGap12),
                        MaterialButton(
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onPressed: () => showSwitchNetworkModal(
                              AppLocalizations.of(context)!.switch_network,
                              context: context),
                          padding: const EdgeInsets.all(kSettingsPadding2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.network_wifi_1_bar_rounded,
                                color: Styles.textLightColor,
                                size: kSettingsIconSize,
                              ),
                              const Gap(kSettingsGap8),
                              Text(AppLocalizations.of(context)!.switch_network,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                        FutureBuilder<dynamic>(
                          future: ReefAppState.instance.metadataCtrl
                              .getJsVersions(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data);
                            }
                            return const Text('getting version...');
                          },
                        ),
                        const Gap(kSettingsGap12),
                        Text('JS conn: ${jsConnState ?? "getting status"}'),
                        const Gap(kSettingsGap12),
                        Text('Indexer conn: ${indexerConnState ?? "getting indexer status"}'),
                        const Gap(kSettingsGap12),
                        Text('Provider conn: ${providerConnState ?? "getting provider status"}'),
                      ],
                    ),
                  ),
              ],
            )));
  }
}
