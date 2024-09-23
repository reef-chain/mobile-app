import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/utils/account_box.dart';

class CreateAccountBox extends StatefulWidget {
  final Color? textColor;
  const CreateAccountBox({Key? key, this.textColor}) : super(key: key);

  @override
  State<CreateAccountBox> createState() => _CreateAccountBoxState();
}

class _CreateAccountBoxState extends State<CreateAccountBox> {
  @override
  Widget build(BuildContext context) {
    return Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.no_account_currently,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.textColor ?? Colors.black
            ),
          ),
          const SizedBox(height: 20),
          Builder(builder: (context) {
            return ElevatedButton.icon(
                style: ButtonStyle(
                  iconColor: MaterialStateProperty.resolveWith(
                        (states) => Styles.whiteColor),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Styles.purpleColor)),
                        
                onPressed: () {
                  showAddAccountModal(
                      AppLocalizations.of(context)!.add_account, openModal);
                },
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: Text(AppLocalizations.of(context)!.add_account,style: TextStyle(color: Styles.whiteColor),));
          }),
        ],
      );
  }
}