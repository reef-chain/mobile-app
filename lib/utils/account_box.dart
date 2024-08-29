import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/components/modals/restore_json_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';

// TODO convert modal name to Enum vlaue
void openModal(String modalName) {
    var context = navigatorKey.currentContext!;
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