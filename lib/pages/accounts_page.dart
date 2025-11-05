
import 'package:flutter/material.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/CreateAccount.dart';
import 'package:reef_mobile_app/components/InsufficientBalance.dart';
import 'package:reef_mobile_app/components/accounts/accounts_list.dart';

import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/AccountCtrl.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/account_profile.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/utils/account_box.dart';
import 'package:restart_app/restart_app.dart';

import '../components/sign/SignatureContentToggle.dart';

class AccountsPage extends StatefulWidget {
  AccountsPage({super.key});
  final ReefAppState reefState = ReefAppState.instance;
  final AccountCtrl accountCtrl = ReefAppState.instance.accountCtrl;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final svgData = AccountProfile.iconSvg;

  // TODO replace strings with enum

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Styles.darkBackgroundColor,
      child: Column(
        children: <Widget>[
          buildHeader(context),
          const Gap(16),
          Observer(builder: (_) {
            var accsFeedbackDataModel =
                ReefAppState.instance.model.accounts.accountsFDM;
            if (accsFeedbackDataModel.hasStatus(StatusCode.completeData)) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                SizedBox(
                    child: Text(
                  accsFeedbackDataModel.statusList[0].message ?? '',
                  style: TextStyle(fontSize: 16, color: Styles.textLightColor),
                )),
                if(accsFeedbackDataModel.statusList[0].message == "Request failed with status code 404")ElevatedButton(onPressed: (){Restart.restartApp();}, child: Text("Restart App"))
              ],
            );
          }),
          Observer(builder: (_) {
            final accsFeedbackDataModel =
                ReefAppState.instance.model.accounts.accountsFDM;
            if (accsFeedbackDataModel.data.isEmpty) {
              return const SizedBox.shrink();
            }
            return Flexible(
                child: AccountsList(
                    ReefAppState.instance.model.accounts.accountsFDM.data,
                    ReefAppState.instance.model.accounts.selectedAddress,
                    (addr) async {
              await ReefAppState.instance.accountCtrl.setSelectedAddress(addr);
              ReefAppState.instance.navigationCtrl.navigateHomePage(0);

              var navigateOnAccountSwitch =
                  ReefAppState.instance.model.appConfig.navigateOnAccountSwitch;
              if (navigateOnAccountSwitch)
                ReefAppState.instance.navigationCtrl
                    .navigate(NavigationPage.home);
            }));
          }),
        ],
      ),
    ));
  }

  Padding buildHeader(BuildContext context) {
    final accsFeedbackDataModel = ReefAppState.instance.model.accounts.accountsFDM;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [

                  const Gap(8),
                  Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.my_account,
                      style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w500,
                          fontSize: 32,
                          color: Colors.grey.shade100),
                    );
                  }),
                ],
              ),
              Row(
                children: [
                  MaterialButton(
                    onPressed: () => showAddAccountModal(
                        AppLocalizations.of(context)!.add_account, openModal,
                        context: context),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: 0,
                    height: 36,
                    elevation: 0,
                    color: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Styles.purpleColor)),
                    child: Row(children: [
                      Icon(
                        Icons.add_circle_rounded,
                        color: Styles.purpleColor,
                        size: 22,
                      ),
                      const Gap(4),
                      Builder(builder: (context) {
                        return Text(
                          AppLocalizations.of(context)!.add,
                          style: GoogleFonts.roboto(
                              color: Colors.grey.shade100,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        );
                      })
                    ]),
                  ),
                  const Gap(8)
                ],
              ),
            ],
          ),
          if (accsFeedbackDataModel.data.isNotEmpty)
          InsufficientBalance(),
          if(accsFeedbackDataModel.data.isEmpty)
          CreateAccountBox(textColor: Styles.whiteColor,)
        ],
      ),
    );
  }
}
