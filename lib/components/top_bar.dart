import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/size_config.dart';

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
                          AccountPill(selSignerList.first.name)
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

  @override
  void initState() {
    ReefAppState.instance.networkCtrl.getProviderConnLogs().listen((event) {
      setState(() {
        this.providerConn = event != null && event.isConnected;
      });
    });
    ReefAppState.instance.networkCtrl.getIndexerConnected().listen((event) {
      setState(() {
        this.indexerConn = event != null && event==true;
      });
    });
    ReefAppState.instance.metadataCtrl.getJsConnStream().listen((event) {
      setState(() {
        this.jsConn = event != null && event==true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isConnected = jsConn&&indexerConn&&providerConn;
    var icon = Icon(
      isConnected?Icons.wallet: Icons.error_outline,
      color: isConnected?Styles.textColor:Styles.primaryAccentColor,
    );
    var title = isConnected?widget.title:"no connection";
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
        ReefAppState.instance.navigationCtrl.navigate(NavigationPage.accounts);
      });
  }
}
