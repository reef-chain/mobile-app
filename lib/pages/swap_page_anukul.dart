import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/CircularCountdown.dart';
import 'package:reef_mobile_app/components/MaxAmountButton.dart';
import 'package:reef_mobile_app/components/SliderStandAlone.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/components/send/custom_stepper.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../components/sign/SignatureContentToggle.dart';

class SwapPage extends StatefulWidget {
  final String preselected;
  const SwapPage(this.preselected, {Key? key}) : super(key: key);

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  // swap tokens with amount
  TokenWithAmount? selectedTopToken;
  TokenWithAmount? selectedBottomToken;

  // amount input fields
  TextEditingController amountTopController = TextEditingController();
  TextEditingController amountBottomController = TextEditingController();

  //slider
  double rating = 0;

  // focus
  FocusNode _focusTop = FocusNode();
  FocusNode _focusBottom = FocusNode();
  bool _isValueTopEditing = false;
  bool _isValueBottomEditing = false;

  //settings
  SwapSettings settings = SwapSettings(1, 0.8);

  //reserves
  String reserveTop = "";
  String reserveBottom = "";

  //summary
  String rate = "";
  String slippage = "0.8";
  String fee = "";

  //status reefstepper
  SendStatus statusValue = SendStatus.NO_ADDRESS;
  dynamic transactionData;

  //swap button label
  String btnLabel="";

  @override
  void initState() {
    _focusTop.addListener(_onFocusTopChange);
    _focusBottom.addListener(_onFocusBottomChange);
    setState(() {
      // set preselected token
      selectedTopToken = ReefAppState.instance.model.tokens.selectedErc20List
          .firstWhere((token) => token.address == widget.preselected);

      amountTopController.text = selectedTopToken?.amount.toString() ?? '0';
    });
    super.initState();
  }

  void _getPoolReserves() async {
    if (selectedTopToken == null || selectedBottomToken == null) {
      return;
    }

    setState(() {
      selectedTopToken = selectedTopToken!.setAmount("0");
      amountTopController.clear();
      selectedBottomToken = selectedBottomToken!.setAmount("0");
      amountBottomController.clear();
    });

    var res = await ReefAppState.instance.swapCtrl.getPoolReserves(
        selectedTopToken!.address, selectedBottomToken!.address);
    if (res is bool && res == false) {
      print("ERROR: Pool does not exist");
      setState(() {
        reserveTop = "";
        reserveBottom = "";
      });
      return;
    }
    setState(() {
      reserveTop = res["reserve1"];
      reserveBottom = res["reserve2"];
    });

setState(() {
    rate = getPoolRate(reserveBottom,reserveTop,selectedTopToken!.symbol,selectedBottomToken!.symbol);
});
    
    print("Pool reserves: ${res['reserve1']}, ${res['reserve1']}");
  }

 String getPoolRate(String reserveTop, String reserveBottom, String symbol1, String symbol2) {
  final BigInt bigIntReserveTop = BigInt.parse(reserveTop);
  final BigInt bigIntReserveBottom = BigInt.parse(reserveBottom);

  final BigInt quotient = bigIntReserveTop ~/ bigIntReserveBottom;
  final BigInt remainder = bigIntReserveTop % bigIntReserveBottom;

  const int precision = 4;
  final BigInt scaledRemainder = (remainder * BigInt.from(10).pow(precision));
  final BigInt fractionalPart = scaledRemainder ~/ bigIntReserveBottom;

  String result = quotient.toString();
  if (fractionalPart != BigInt.zero) {
    String fractionalString = fractionalPart.toString().padLeft(precision, '0');
    result += '.' + fractionalString.substring(0, precision);
  } else {
    result += '.0000';
  }

  return '1 $symbol1 = $result $symbol2';
}
  void _executeSwap() async {
    if (selectedTopToken == null || selectedBottomToken == null) {
      return;
    }

    if (selectedTopToken!.amount <= BigInt.zero) {
      return;
    }

    var signerAddress = await ReefAppState.instance.storageCtrl
        .getValue(StorageKey.selected_address.name);
    Stream<dynamic> executeTransactionFeedbackStream =
        await ReefAppState.instance.swapCtrl.swapTokens(
            signerAddress, selectedTopToken!, selectedBottomToken!, settings);
    executeTransactionFeedbackStream =
        executeTransactionFeedbackStream.asBroadcastStream();

    executeTransactionFeedbackStream.listen((txResponse) {
      print('TRANSACTION RESPONSE anukul=$txResponse');
      if(txResponse!=null){
        setState(() {
          if(txResponse['status']=="approving"){
            showModal(context,
            headText: "Swap in progress",
            child: Column(
              children: [
                Gap(16.0),
                CircularCountDown(
                    countdownMs: 4500,
                    width: 80,
                    height: 80,
                    fillColor: Styles.primaryAccentColor,
                    strokeWidth: 4,
                    child:IconFromUrl(selectedTopToken!.iconUrl),
                    close: ()=>Navigator.of(context).pop(),
                  ),  Gap(8.0),
                  Text("approving ${selectedTopToken?.name}...",style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Styles.textLightColor,
                ),)
              ],
            ));
          }
          if(txResponse['status']=="approve-started"){
            setState(() {
              btnLabel = "Approving";
            });
          }
          if(txResponse['status']=="approved"){
            setState(() {
              btnLabel = "";
            });
            showModal(context,
            headText: "Swap in progress",
            child: Column(
              children: [
                Gap(16.0),
                CircularCountDown(
                    countdownMs: 4500,
                    width: 110,
                    height: 110,
                    fillColor: Styles.primaryAccentColor,
                    strokeWidth: 4,
                    child:Center(
                      child: Row(
                        children: [
                          IconFromUrl(selectedTopToken!.iconUrl),
                          Gap(4.0),
                          IconFromUrl(selectedBottomToken!.iconUrl),
                        ],
                      ),
                    ),
                    close: ()=>Navigator.of(context).pop(),
                  ),  Gap(8.0),
                  Text("swapping ${selectedTopToken?.name} to ${selectedBottomToken?.name}",style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Styles.textLightColor,
                ),)
              ],
            ));
         
          }
        });
        handleEvmTransactionResponse(txResponse);
      }
    });
    _getPoolReserves();
    print("SWAP TOKEN RESPONSE === $executeTransactionFeedbackStream");
  }

  bool handleEvmTransactionResponse(txResponse) {
      if (txResponse['status'] == 'broadcast') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.SENT_TO_NETWORK;
        });
      }
      if (txResponse['status'] == 'included-in-block') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.INCLUDED_IN_BLOCK;
        });
      }
      if (txResponse['status'] == 'finalized') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.FINALIZED;
        });
      }
      if (txResponse['status'] == 'not-finalized') {
        print('block was not finalized');
        setState(() {
          statusValue = SendStatus.NOT_FINALIZED;
        });
      }
      return true;
  }
  Future<void> _amountTopUpdated(String value) async {
    if (selectedTopToken == null) {
      return;
    }

    var formattedValue =
        toStringWithoutDecimals(value, selectedTopToken!.decimals);

    if (value.isEmpty ||
        formattedValue.replaceAll(".", "").replaceAll("0", "").isEmpty) {
      print("ERROR: Invalid value for amount top");
      if (selectedBottomToken != null) {
        setState(() {
          selectedBottomToken = selectedBottomToken!.setAmount("0");
          amountBottomController.clear();
        });
      }
      setState(() {
        selectedTopToken = selectedTopToken!.setAmount("0");
        amountTopController.clear();
      });
      return;
    }
    setState(() {
      selectedTopToken = selectedTopToken!.setAmount(formattedValue);
    });
    setState(() {
      if (double.parse(formattedValue) <=
          double.parse(selectedTopToken!.balance.toString())) {
        rating = double.parse(formattedValue) /
            double.parse(selectedTopToken!.balance.toString());
      } else {
        rating = 0.0;
        selectedTopToken?.setAmount("0");
        amountTopController.clear();
      }
    });

    if (BigInt.parse(formattedValue) > selectedTopToken!.balance) {
      print("WARN: Insufficient ${selectedTopToken!.symbol} balance");
    }

    if (reserveTop.isEmpty) {
      return; // Pool does not exist
    }

    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    var res = (await ReefAppState.instance.swapCtrl
            .getSwapAmount(value, false, token1, token2))
        .replaceAll("\"", "");

    setState(() {
      selectedBottomToken = selectedBottomToken!.setAmount(res);
      amountBottomController.text = toAmountDisplayBigInt(
          selectedBottomToken!.amount,
          decimals: selectedBottomToken!.decimals);
    });
    print(
        "${selectedTopToken!.amount} - ${toAmountDisplayBigInt(selectedTopToken!.amount, decimals: selectedTopToken!.decimals)}");
    print(
        "${selectedBottomToken!.amount} - ${toAmountDisplayBigInt(selectedBottomToken!.amount, decimals: selectedBottomToken!.decimals)}");
  }

  Future<void> _amountBottomUpdated(String value) async {
    if (selectedBottomToken == null) {
      return;
    }

    var formattedValue =
        toStringWithoutDecimals(value, selectedBottomToken!.decimals);

    if (value.isEmpty ||
        formattedValue.replaceAll(".", "").replaceAll("0", "").isEmpty) {
      print("ERROR: Invalid value");
      if (selectedTopToken != null) {
        setState(() {
          selectedTopToken = selectedTopToken!.setAmount("0");
          amountTopController.clear();
        });
      }
      setState(() {
        selectedBottomToken = selectedBottomToken!.setAmount("0");
        amountBottomController.clear();
      });
      return;
    }
    setState(() {
      selectedBottomToken = selectedBottomToken!.setAmount(formattedValue);
    });
    if (reserveTop.isEmpty) {
      return; // Pool does not exist
    }

    if (BigInt.parse(formattedValue) > BigInt.parse(reserveBottom)) {
      print(
          "ERROR: Insufficient ${selectedBottomToken!.symbol} liquidity in pool");
      selectedTopToken = selectedTopToken!.setAmount("0");
      amountTopController.clear();
      return;
    }

    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    var res = (await ReefAppState.instance.swapCtrl
            .getSwapAmount(value, true, token1, token2))
        .replaceAll("\"", "");

    if (BigInt.parse(res) > selectedTopToken!.balance) {
      print("WARN: Insufficient ${selectedTopToken!.symbol} balance");
    }
    setState(() {
      selectedTopToken = selectedTopToken!.setAmount(res);
      amountTopController.text = toAmountDisplayBigInt(selectedTopToken!.amount,
          decimals: selectedTopToken!.decimals);
    });

    print(
        "${selectedTopToken!.amount} - ${toAmountDisplayBigInt(selectedTopToken!.amount, decimals: selectedTopToken!.decimals)}");
    print(
        "${selectedBottomToken!.amount} - ${toAmountDisplayBigInt(selectedBottomToken!.amount, decimals: selectedBottomToken!.decimals)}");
  }

  void _changeSelectedTopToken(TokenWithAmount token) {
    setState(() {
      selectedTopToken = token;
      _getPoolReserves();
    });
  }

  void _changeSelectedBottomToken(TokenWithAmount token) {
    setState(() {
      selectedBottomToken = token;
      _getPoolReserves();
    });
  }

  // listeners
  void _onFocusTopChange() {
    setState(() {
      _isValueTopEditing = !_isValueTopEditing;
    });
  }

  void _onFocusBottomChange() {
    setState(() {
      _isValueBottomEditing = !_isValueBottomEditing;
    });
  }

  // UI builders
  Container getPoolSummary() {
  return Container(
    decoration: BoxDecoration(
      color: Styles.boxBackgroundColor,
      borderRadius: BorderRadius.circular(10.0),
    ),
    margin: EdgeInsets.only(top: 8.0),
    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Rate: ",
              style: TextStyle(color: Styles.primaryAccentColor, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: Text(
                "${rate}",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Slippage: ",
              style: TextStyle(color: Styles.primaryAccentColor, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: Text(
                "${slippage}",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Fees: ",
              style: TextStyle(color: Styles.primaryAccentColor, fontWeight: FontWeight.w600),
            ),
            Expanded(
              //todo fix this logic anukul
              child: Text(
                "${max(selectedTopToken!.amount.toDouble()*selectedTopToken!.price!.toDouble()/1e18,0.001).toStringAsFixed(4)}\$",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  BoxBorder getBorder(value) {
    return value
        ? Border.all(color: const Color(0xffa328ab))
        : Border.all(color: const Color(0x00d7d1e9));
  }

  Color getColor(value) {
    return value ? const Color(0xffeeebf6) : const Color(0xffE7E2F2);
  }

  List<BoxShadow> getBoxShadow(value) {
    return [
      if (value)
        const BoxShadow(
            blurRadius: 15,
            spreadRadius: -8,
            offset: Offset(0, 10),
            color: Color(0x40a328ab))
    ];
  }

  InputDecoration getInputDecoration() {
    return InputDecoration(
        constraints: const BoxConstraints(maxHeight: 32),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        hintText: '0.0',
        hintStyle: TextStyle(color: Styles.textLightColor));
  }

  Container getToken(
      bool isEditing,
      dynamic callback,
      TokenWithAmount? selectedTokenWithAmount,
      FocusNode focusNode,
      TextEditingController amountController,
      dynamic amountUpdated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: getBorder(isEditing),
        borderRadius: BorderRadius.circular(12),
        boxShadow: getBoxShadow(isEditing),
        color: getColor(isEditing),
      ),
      child: Column(
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  showTokenSelectionModal(context,
                      callback: callback,
                      selectedToken: selectedTopToken?.address);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: 0,
                height: 36,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black26)),
                child: Row(
                  children: [
                    if (selectedTokenWithAmount == null)
                      const Text("Select token")
                    else ...[
                      IconFromUrl(selectedTokenWithAmount!.iconUrl),
                      const Gap(4),
                      Text(selectedTokenWithAmount!.symbol),
                    ],
                    const Gap(4),
                    Icon(CupertinoIcons.chevron_down,
                        size: 16, color: Styles.textLightColor)
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^(0|[1-9]\d*)(\.\d+)?$'))
                  ],
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  onChanged: (text) async {
                    await amountUpdated(amountController.text);
                  },
                  decoration: getInputDecoration(),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const Gap(8),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                if (selectedTokenWithAmount != null) ...[
                  Text(
                    "Balance: ${toAmountDisplayBigInt(selectedTokenWithAmount!.balance, decimals: selectedTokenWithAmount!.decimals)} ${selectedTokenWithAmount!.symbol}",
                    style:
                        TextStyle(color: Styles.textLightColor, fontSize: 12),
                  ),
                  MaxAmountButton(
                    onPressed: () async {
                      var tokenBalance = toAmountDisplayBigInt(
                          selectedTokenWithAmount!.balance,
                          decimals: selectedTokenWithAmount!.decimals,
                          fractionDigits: selectedTokenWithAmount!.decimals);
                      await amountUpdated(tokenBalance);
                      amountController.text = tokenBalance;
                    },
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  SizedBox getSwapBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor: (selectedTopToken == null ||
                  selectedTopToken!.amount <= BigInt.zero ||
                  selectedBottomToken == null ||
                  selectedBottomToken!.amount <= BigInt.zero)
              ? Color.fromARGB(255, 125, 125, 125)
              : Color.fromARGB(0, 215, 31, 31),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () {
          if (selectedTopToken == null ||
              selectedTopToken!.amount <= BigInt.zero ||
              selectedBottomToken == null ||
              selectedBottomToken!.amount <= BigInt.zero) {
            return;
          }
          _executeSwap();
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: (selectedTopToken == null ||
                    selectedTopToken!.amount <= BigInt.zero ||
                    selectedBottomToken == null ||
                    selectedBottomToken!.amount <= BigInt.zero)
                ? null
                : Styles.buttonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              (btnLabel!=""?btnLabel:selectedTopToken == null
                  ? "Select sell token"
                  : selectedBottomToken == null
                      ? "Select buy token"
                      : selectedTopToken!.amount <= BigInt.zero ||
                              selectedBottomToken!.amount <= BigInt.zero
                          ? "Insert amount"
                          :"Swap"),
              style: TextStyle(
                fontSize: 16,
                color: (selectedTopToken == null ||
                        selectedBottomToken == null ||
                        selectedTopToken!.amount <= BigInt.zero ||
                        selectedBottomToken!.amount <= BigInt.zero)
                    ? const Color(0x65898e9c)
                    : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container getReefTokenField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: _isValueTopEditing
            ? Border.all(color: const Color(0xffa328ab))
            : Border.all(color: const Color(0x00d7d1e9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isValueTopEditing)
            const BoxShadow(
                blurRadius: 15,
                spreadRadius: -8,
                offset: Offset(0, 10),
                color: Color(0x40a328ab))
        ],
        color: _isValueTopEditing
            ? const Color(0xffeeebf6)
            : const Color(0xffE7E2F2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  IconFromUrl(selectedTopToken?.iconUrl, size: 48),
                  const Gap(13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedTopToken != null
                            ? selectedTopToken!.name
                            : 'Select',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xff19233c)),
                      ),
                      Text(
                        "${toAmountDisplayBigInt(selectedTopToken!.balance)} ${selectedTopToken!.name.toUpperCase()}",
                        style: TextStyle(
                            color: Styles.textLightColor, fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
              Expanded(
                child: TextFormField(
                  focusNode: _focusTop,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\.0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  controller: amountTopController,
                  onChanged: (text) async {
                    setState(() {
                      _amountTopUpdated(amountTopController.text);
                    });
                  },
                  decoration: InputDecoration(
                      constraints: const BoxConstraints(maxHeight: 32),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      hintText: '0.0',
                      hintStyle: TextStyle(color: Styles.textLightColor)),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // dispose
  @override
  void dispose() {
    super.dispose();
    _focusTop.removeListener(_onFocusTopChange);
    _focusBottom.removeListener(_onFocusBottomChange);
    _focusTop.dispose();
    _focusBottom.dispose();
  }

  buildFeedbackUI(BuildContext context, SendStatus stat, void Function() onNew,
      void Function() onHome) {
    int? index;

    if (stat == SendStatus.ERROR) {
      //index = 'Transaction Error';
      print('send tx error');
    }
    if (stat == SendStatus.CANCELED) {
      //title = 'Transaction Canceled';
      print('send tx canceled');
    }
    if (stat == SendStatus.SENDING) {
      index = 0;
    }
    if (stat == SendStatus.SENT_TO_NETWORK) {
      index = 1;
    }
    if (stat == SendStatus.INCLUDED_IN_BLOCK) {
      index = 2;
    }
    if (stat == SendStatus.FINALIZED) {
      index = 3;
    }
    // index = 2;
    if (stat == SendStatus.NOT_FINALIZED) {
      // title = 'NOT finalized!';
    }

    if (index == null) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Container(
          margin: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: ReefStepper(
              currentStep: index,
              steps: steps(stat, index),
              displayStepProgressIndicator: true,
              controlsBuilder: (context, details) {
                if ((index ?? 0) >= 3) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Flex(
                        mainAxisAlignment: MainAxisAlignment.center,
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          shadowColor: const Color(0x559d6cff),
                          elevation: 5,
                          backgroundColor: Styles.primaryAccentColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                        ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Continue",style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Styles.whiteColor
                          ),),
                            ),
                          )
                        ],
                      ));
                }
                return const Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                        child: SizedBox(
                      height: 0,
                    ))
                  ],
                );
              },
            ),
          )),
    );
  }


  List<ReefStep> steps(SendStatus stat, int index) => [
        ReefStep(
            state: getStepState(stat, 0, index),
            title: Text(
              AppLocalizations.of(context)!.sending_transaction,
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),*/
                  Flexible(
                      child: Text(
                    AppLocalizations.of(context)!.sending_tx_to_nw,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  )),
                ],
              ),
            )),
        ReefStep(
            state: getStepState(stat, 1, index),
            title: Text(
              AppLocalizations.of(context)!.adding_to_chain,
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),*/
                  Flexible(
                      child: Text(
                    AppLocalizations.of(context)!.waiting_to_include_in_block,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  )),
                ],
              ),
            )),
        ReefStep(
            state: getStepState(stat, 2, index),
            title: Text(
              AppLocalizations.of(context)!.sealing_block,
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),*/
                  Flexible(
                      child: Text(
                    AppLocalizations.of(context)!.unreversible_finality,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  )),
                ],
              ),
            )),
        ReefStep(
            state: getStepState(stat, 3, index),
            title:  Text(
              AppLocalizations.of(context)!.transaction_finalized,
            ),
            content: const SizedBox(),
            icon: Icons.lock),
      ];

  @override
  Widget build(BuildContext context) {
    var transferStatusUI =
        buildFeedbackUI(context, statusValue, ()=>{}, () {
      final navigator = Navigator.of(context);
      navigator.pop();
      // ReefAppState.instance.navigationCtrl.navigate(NavigationPage.home);
    });
    return transferStatusUI?? SignatureContentToggle(
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Styles.primaryBackgroundColor,
            boxShadow: neumorphicShadow()),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (selectedTopToken?.address == Constants.REEF_TOKEN_ADDRESS)
              getReefTokenField(),
            if (selectedTopToken?.address != Constants.REEF_TOKEN_ADDRESS)
              getToken(
                  _isValueTopEditing,
                  _changeSelectedTopToken,
                  selectedTopToken,
                  _focusTop,
                  amountTopController,
                  _amountTopUpdated),
            Gap(16),
            getToken(
                _isValueBottomEditing,
                _changeSelectedBottomToken,
                selectedBottomToken,
                _focusBottom,
                amountBottomController,
                _amountBottomUpdated),
            Gap(16),
            SliderStandAlone(
                rating: rating,
                onChanged: (newRating) async {
                  setState(() {
                    rating = newRating;
                    String amountValue = (double.parse(toAmountDisplayBigInt(
                                selectedTopToken!.balance)) *
                            rating)
                        .toStringAsFixed(2);
                    amountTopController.text = amountValue;
                    _amountTopUpdated(amountValue);
                  });
                }),
            Gap(16),
            if(rate!="")getPoolSummary(),
            Gap(16),
            getSwapBtn(),
          ],
        ),
      ),
    );
  }
}


  ReefStepState getStepState(SendStatus stat, int stepIndex, int currentIndex) {
    switch (stat) {
      case SendStatus.FINALIZED:
        if (stepIndex == currentIndex) {
          return ReefStepState.complete;
        } else if (stepIndex < currentIndex) {
          return ReefStepState.complete;
        }
        break;
      case SendStatus.CANCELED:
        if (stepIndex == currentIndex) {
          return ReefStepState.error;
        }
        break;
      case SendStatus.ERROR:
        if (stepIndex == currentIndex) {
          return ReefStepState.error;
        }
        break;
      default:
        if (currentIndex == stepIndex) {
          return ReefStepState.editing;
        } else if (stepIndex < currentIndex) {
          return ReefStepState.complete;
        }
    }
    return ReefStepState.indexed;
  }


enum SendStatus {
  READY,
  NO_EVM_CONNECTED,
  NO_ADDRESS,
  NO_AMT,
  AMT_TOO_HIGH,
  ADDR_NOT_VALID,
  ADDR_NOT_EXIST,
  LOW_REEF_EVM,
  LOW_REEF_NATIVE,
  SIGNING,
  SENDING,
  CANCELED,
  ERROR,
  SENT_TO_NETWORK,
  INCLUDED_IN_BLOCK,
  FINALIZED,
  NOT_FINALIZED,
  EVM_NOT_BINDED,
  CONNECTING
}