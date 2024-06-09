import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/components/modals/reconnect_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/navigation/navigation_model.dart';
import '../model/network/NetworkCtrl.dart';
import '../utils/styles.dart';

Widget topBar(BuildContext context) {
  SizeConfig.init(context);

  return Container(
    color: Colors.transparent,
    child: Column(
      children: <Widget>[
        Gap(getProportionateScreenHeight(50)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                ReefAppState.instance.navigationCtrl
                    .navigate(NavigationPage.home);
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/images/reef-logo-light.svg',
                      semanticsLabel: "Reef Chain Logo",
                      height: 46,
                    ),
                    Observer(builder: (_) {
                      if (ReefAppState
                              .instance.model.network.selectedNetworkName ==
                          Network.testnet.name) {
                        return const Text(
                            style: TextStyle(
                                color: Colors.lightBlue, fontSize: 10),
                            'testnet');
                      }
                      return const SizedBox.shrink();
                    })
                  ]),
            ),
            Expanded(child: Observer(builder: (_) {
              var selAddr =
                  ReefAppState.instance.model.accounts.selectedAddress;

              var selSignerList = ReefAppState
                  .instance.model.accounts.accountsList
                  .where((element) => element.address == selAddr);

              return selSignerList.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 4, left: 8),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AccountPill(selSignerList.first.name),
                              Gap(2.0),
                             Material(
  elevation: 4,
  borderRadius: BorderRadius.circular(22.0),
  child: InkWell(
    onTap: () {
      ReefAppState.instance.navigationCtrl
                      .navigateToWalletConnectPage(context: context);
    },
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Styles.whiteColor,
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SvgPicture.asset('assets/images/walletconnect.svg', width: 30,),
      ),
    ),
  ),
),

                            ],
                          ),
                           
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            }))
          ],
        ),
        const Gap(16),
      ],
    ),
  );
}

class AccountPill extends StatefulWidget {
  final String title;
  const AccountPill(this.title,{super.key});

  @override
  State<AccountPill> createState() => _AccountPillState();
}

class _AccountPillState extends State<AccountPill> {
var color = Styles.textColor;
var indexerConn = false;
var providerConn = false;
var jsConn = false;
List<StreamSubscription> listeners=[];

  @override
  void initState() {
    listeners.add(ReefAppState.instance.networkCtrl.getProviderConnLogs().listen((event) {
      setState(() {
        this.providerConn = event != null && event.isConnected;
      });
    }));
    listeners.add(ReefAppState.instance.networkCtrl.getIndexerConnected().listen((event) {
      setState(() {
        this.indexerConn = event != null && event==true;
      });
    }));
    ReefAppState.instance.metadataCtrl.getJsConnStream().then((jsStream) {
      listeners.add(jsStream.listen((event) {
        setState(() {
          this.jsConn = event != null && event==true;
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

  @override
  Widget build(BuildContext context) {
    var isConnected = jsConn&&indexerConn&&providerConn;
    var icon = Icon(
      isConnected?Icons.wallet: Icons.error_outline,
      color: isConnected?Styles.textColor:Styles.primaryAccentColor,
    );
    var title = isConnected?widget.title:AppLocalizations.of(context)!.connecting;
    return ActionChip(
      avatar: icon,
      label: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
            color: Styles.purpleColor,
            fontSize: 18,
            fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
      ),
      backgroundColor: Styles.primaryBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      onPressed: () {
        if(isConnected){
        ReefAppState.instance.navigationCtrl.navigate(NavigationPage.accounts);
        }else{
         showReconnectProviderModal(AppLocalizations.of(context)!.connection_stats);
        }
      });
  }
}
