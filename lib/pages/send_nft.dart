import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modals/select_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SendNFT extends StatefulWidget {
  final String nftUrl;
  final String name;
  final int balance;

  SendNFT(this.nftUrl, this.name, this.balance, {Key? key}) : super(key: key);

  @override
  State<SendNFT> createState() => _SendNFTState();
}

class _SendNFTState extends State<SendNFT> {
  TextEditingController? _amountController;
  bool _isValueEditing = false;
  int amountToSend = 0;
  bool isFormDisabled = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountController!.text = amountToSend.toString();
  }

  @override
  void dispose() {
    _amountController!.dispose();
    super.dispose();
  }

  getSendBtnLabel(SendStatus validation) {
    switch (validation) {
      case SendStatus.NO_ADDRESS:
        return "Missing destination address";
      case SendStatus.NO_AMT:
        return "Insert amount";
      case SendStatus.AMT_TOO_HIGH:
        return "Amount too high";
      case SendStatus.NO_EVM_CONNECTED:
        return "Target not EVM";
      case SendStatus.ADDR_NOT_VALID:
        return "Enter a valid address";
      case SendStatus.ADDR_NOT_EXIST:
        return "Unknown address";
      case SendStatus.SIGNING:
        return "Signing transaction ...";
      case SendStatus.SENDING:
        return "Sending ...";
      case SendStatus.READY:
        return "Confirm Send";
      default:
        return "Not Valid";
    }
  }

  String address = "";
  TextEditingController valueController = TextEditingController();
  final FocusNode _focus = FocusNode();
  SendStatus statusValue = SendStatus.NO_ADDRESS;

  @override
  Widget build(BuildContext context) {
    List<Widget> buildInputElements() {
      void onSelectAccount(String selectedAddress) async {
        setState(() {
          address = selectedAddress.trim();
          valueController.text = address;
        });
      }

      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: _isValueEditing
                ? Border.all(color: const Color(0xffa328ab))
                : Border.all(color: const Color(0x00d7d1e9)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (_isValueEditing)
                const BoxShadow(
                    blurRadius: 15,
                    spreadRadius: -8,
                    offset: Offset(0, 10),
                    color: Color(0x40a328ab))
            ],
            color: _isValueEditing
                ? const Color(0xffeeebf6)
                : const Color(0xffE7E2F2),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: MaterialButton(
                  elevation: 0,
                  height: 48,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    if (isFormDisabled) {
                      return;
                    }
                    showSelectAccountModal(
                      AppLocalizations.of(context)!.select_address,
                      onSelectAccount,
                      true,
                    );
                  },
                  //color: const Color(0xffDFDAED),
                  child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: isFormDisabled
                            ? Styles.textLightColor
                            : Styles.textColor,
                      )),
                ),
              ),
              Expanded(
                child: TextField(
                    controller: valueController,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isFormDisabled
                            ? Styles.textLightColor
                            : Styles.textColor),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        border: InputBorder.none,
                        hintText: AppLocalizations.of(context)!.send_to_address,
                        hintStyle: TextStyle(color: Styles.textLightColor)),
                    onChanged: (value) {
                      print("anuna ${value} $address");
                      setState(() {
                        address = value;
                      });
                    }),
              ),
              SizedBox(
                width: 48,
                child: MaterialButton(
                    elevation: 0,
                    height: 48,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () {
                      showQrTypeDataModal(
                          AppLocalizations.of(context)!.scan_address, context,
                          expectedType: ReefQrCodeType.address);
                    },
                    child: const Icon(
                      Icons.qr_code_scanner_sharp,
                      color: Styles.textColor,
                    )),
              ),
            ],
          ),
        ),
      ];
    }

    SizedBox buildSendStatusButton() {
      return SizedBox(
        width: double.infinity,
        child: statusValue != SendStatus.SIGNING
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  shadowColor: const Color(0x559d6cff),
                  elevation: 0,
                  backgroundColor: (statusValue == SendStatus.READY)
                      ? const Color(0xffe6e2f1)
                      : Colors.transparent,
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () => {},
                child: Ink(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xffe6e2f1),
                    gradient: (statusValue == SendStatus.READY)
                        ? const LinearGradient(colors: [
                            Color(0xffae27a5),
                            Color(0xff742cb2),
                          ])
                        : null,
                    borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                  ),
                  child: Center(
                    child: Text(
                      getSendBtnLabel(statusValue),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: (statusValue != SendStatus.READY)
                            ? const Color(0x65898e9c)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Text('Generating Signature'),
                  Gap(12),
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Styles.primaryAccentColor),
                    backgroundColor: Styles.greyColor,
                  )
                ],
              ),
      );
    }

    void _onFocusChange() {
      setState(() {
        _isValueEditing = !_isValueEditing;
      });
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Styles.primaryBackgroundColor,
        boxShadow: neumorphicShadow(),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Styles.textColor,
              ),
            ),
            Gap(16.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Styles.primaryBackgroundColor,
                boxShadow: neumorphicShadow(),
              ),
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: IconFromUrl(
                  widget.nftUrl,
                  size: 320,
                ),
              ),
            ),
            Gap(18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Balance : ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Styles.textLightColor,
                  ),
                ),
                Text(
                  "${widget.balance}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Styles.primaryAccentColor,
                  ),
                ),
              ],
            ),
            Gap(18.0),
            Column(
              children: buildInputElements(),
            ),
            Gap(18.0),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffe6e2f1),
                gradient: (statusValue == SendStatus.READY)
                    ? const LinearGradient(colors: [
                        Color(0xffae27a5),
                        Color(0xff742cb2),
                      ])
                    : null,
                borderRadius: const BorderRadius.all(Radius.circular(14.0)),
              ),
              padding: EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xff742cb2),
                          spreadRadius: -10,
                          offset: Offset(0, 5),
                          blurRadius: 20,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(80),
                      gradient: const LinearGradient(
                        colors: [Color(0xffae27a5), Color(0xff742cb2)],
                        begin: Alignment(-1, -1),
                        end: Alignment(1, 1),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16.0,
                      ),
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.transparent,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          if (amountToSend > 0) {
                            amountToSend -= 1;
                            _amountController!.text = amountToSend.toString();
                          }
                        });
                      },
                    ),
                  ),
                  Gap(8.0),
                  Column(
                    children: [
                      Gap(8.0),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              amountToSend = 0;
                              _amountController!.text = amountToSend.toString();
                            });
                          },
                          child: Text(
                            'Min',
                            style: TextStyle(color: Styles.primaryAccentColor),
                          )),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Styles.primaryAccentColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              amountToSend = 0;
                            } else {
                              int enteredValue = int.tryParse(value) ?? 0;
                              if (enteredValue < 0 ||
                                  enteredValue > widget.balance) {
                                _amountController!.text = '0';
                                amountToSend = 0;
                              } else {
                                amountToSend = enteredValue;
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Gap(8.0),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              amountToSend = widget.balance;
                              _amountController!.text = amountToSend.toString();
                            });
                          },
                          child: Text(
                            'Max',
                            style: TextStyle(color: Styles.primaryAccentColor),
                          )),
                    ],
                  ),
                  Gap(8.0),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xff742cb2),
                          spreadRadius: -10,
                          offset: Offset(0, 5),
                          blurRadius: 20,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(80),
                      gradient: const LinearGradient(
                        colors: [Color(0xffae27a5), Color(0xff742cb2)],
                        begin: Alignment(-1, -1),
                        end: Alignment(1, 1),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16.0,
                      ),
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.transparent,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          if (amountToSend < widget.balance) {
                            amountToSend += 1;
                            _amountController!.text = amountToSend.toString();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Gap(24.0),
            buildSendStatusButton()
          ],
        ),
      ),
    );
  }
}

enum SendStatus {
  READY,
  NO_EVM_CONNECTED,
  NO_ADDRESS,
  NO_AMT,
  AMT_TOO_HIGH,
  ADDR_NOT_VALID,
  ADDR_NOT_EXIST,
  SIGNING,
  SENDING,
  CANCELED,
  ERROR,
  SENT_TO_NETWORK,
  INCLUDED_IN_BLOCK,
  FINALIZED,
  NOT_FINALIZED,
}
