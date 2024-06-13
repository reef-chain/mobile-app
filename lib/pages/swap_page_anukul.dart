import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/MaxAmountButton.dart';
import 'package:reef_mobile_app/components/SliderStandAlone.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
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

  // focus
  FocusNode _focusTop = FocusNode();
  FocusNode _focusBottom = FocusNode();
  bool _isValueTopEditing = false;
  bool _isValueBottomEditing = false;

  @override
  void initState() {
    _focusTop.addListener(_onFocusTopChange);
    _focusBottom.addListener(_onFocusBottomChange);
    setState(() {
      // set preselected token
      selectedTopToken = ReefAppState.instance.model.tokens.selectedErc20List
          .firstWhere((token) => token.address == widget.preselected);

      // Initialize the controller with the current amount of the selected token
      amountTopController.text = selectedTopToken?.amount.toString() ?? '0';
    });
    super.initState();
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

    if (BigInt.parse(formattedValue) > selectedTopToken!.balance) {
      print("WARN: Insufficient ${selectedTopToken!.symbol} balance");
    }

    // if (reserveTop.isEmpty) {
    //   return; // Pool does not exist
    // }

    // var token1 = selectedTopToken!.setAmount(reserveTop);
    // var token2 = selectedBottomToken!.setAmount(reserveBottom);

    // var res = (await ReefAppState.instance.swapCtrl
    //         .getSwapAmount(value, false, token1, token2))
    //     .replaceAll("\"", "");

    // selectedBottomToken = selectedBottomToken!.setAmount(res);
    // amountBottomController.text = toAmountDisplayBigInt(
    //     selectedBottomToken!.amount,
    //     decimals: selectedBottomToken!.decimals);

    // print(
    //     "${selectedTopToken!.amount} - ${toAmountDisplayBigInt(selectedTopToken!.amount, decimals: selectedTopToken!.decimals)}");
    // print(
    //     "${selectedBottomToken!.amount} - ${toAmountDisplayBigInt(selectedBottomToken!.amount, decimals: selectedBottomToken!.decimals)}");
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
    // if (reserveTop.isEmpty) {
    //   return; // Pool does not exist
    // }

    // if (BigInt.parse(formattedValue) > BigInt.parse(reserveBottom)) {
    //   print(
    //       "ERROR: Insufficient ${selectedBottomToken!.symbol} liquidity in pool");
    //   selectedTopToken = selectedTopToken!.setAmount("0");
    //   amountTopController.clear();
    //   return;
    // }

    // var token1 = selectedTopToken!.setAmount(reserveTop);
    // var token2 = selectedBottomToken!.setAmount(reserveBottom);

    // var res = (await ReefAppState.instance.swapCtrl
    //         .getSwapAmount(value, true, token1, token2))
    //     .replaceAll("\"", "");

    // if (BigInt.parse(res) > selectedTopToken!.balance) {
    //   print("WARN: Insufficient ${selectedTopToken!.symbol} balance");
    // }

    // selectedTopToken = selectedTopToken!.setAmount(res);
    // amountTopController.text = toAmountDisplayBigInt(selectedTopToken!.amount,
    //     decimals: selectedTopToken!.decimals);

    // print(
    //     "${selectedTopToken!.amount} - ${toAmountDisplayBigInt(selectedTopToken!.amount, decimals: selectedTopToken!.decimals)}");
    // print(
    //     "${selectedBottomToken!.amount} - ${toAmountDisplayBigInt(selectedBottomToken!.amount, decimals: selectedBottomToken!.decimals)}");
  }

  void _changeSelectedTopToken(TokenWithAmount token) {
    setState(() {
      selectedTopToken = token;
      // _getPoolReserves();
    });
  }

  void _changeSelectedBottomToken(TokenWithAmount token) {
    setState(() {
      selectedBottomToken = token;
      // _getPoolReserves();
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

  InputDecoration getInputDecoration(){
    return InputDecoration(
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
                      hintStyle: TextStyle(color: Styles.textLightColor));
  }

  Container getTopToken() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: getBorder(_isValueTopEditing),
        borderRadius: BorderRadius.circular(12),
        boxShadow: getBoxShadow(_isValueTopEditing),
        color: getColor(_isValueTopEditing),
      ),
      child: Column(
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  showTokenSelectionModal(context,
                      callback: _changeSelectedTopToken,
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
                    if (selectedTopToken == null)
                      const Text("Select token")
                    else ...[
                      IconFromUrl(selectedTopToken!.iconUrl),
                      const Gap(4),
                      Text(selectedTopToken!.symbol),
                    ],
                    const Gap(4),
                    Icon(CupertinoIcons.chevron_down,
                        size: 16, color: Styles.textLightColor)
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  focusNode: _focusTop,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\.0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  controller: amountTopController,
                  onChanged: (text) async {
                    await _amountTopUpdated(amountTopController.text);
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
                if (selectedTopToken != null) ...[
                  Text(
                    "Balance: ${toAmountDisplayBigInt(selectedTopToken!.balance, decimals: selectedTopToken!.decimals)} ${selectedTopToken!.symbol}",
                    style:
                        TextStyle(color: Styles.textLightColor, fontSize: 12),
                  ),
                  MaxAmountButton(
                    onPressed: () async {
                      //TODO: anukul -  set slider to max
                      var topTokenBalance = toAmountDisplayBigInt(
                          selectedTopToken!.balance,
                          decimals: selectedTopToken!.decimals,
                          fractionDigits: selectedTopToken!.decimals);
                      await _amountTopUpdated(topTokenBalance);
                      amountTopController.text = topTokenBalance;
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

  Container getBottomToken() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: getBorder(_isValueBottomEditing),
        borderRadius: BorderRadius.circular(12),
        boxShadow: getBoxShadow(_isValueBottomEditing),
        color: getColor(_isValueBottomEditing),
      ),
      child: Column(
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  showTokenSelectionModal(context,
                      callback: _changeSelectedBottomToken,
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
                    if (selectedBottomToken == null)
                      const Text("Select token")
                    else ...[
                      IconFromUrl(selectedBottomToken!.iconUrl),
                      const Gap(4),
                      Text(selectedBottomToken!.symbol),
                    ],
                    const Gap(4),
                    Icon(CupertinoIcons.chevron_down,
                        size: 16, color: Styles.textLightColor)
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  focusNode: _focusBottom,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\.0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  controller: amountBottomController,
                  onChanged: (text) async {
                    await _amountBottomUpdated(amountBottomController.text);
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
                if (selectedBottomToken != null) ...[
                  Text(
                    "Balance: ${toAmountDisplayBigInt(selectedBottomToken!.balance, decimals: selectedBottomToken!.decimals)} ${selectedBottomToken!.symbol}",
                    style:
                        TextStyle(color: Styles.textLightColor, fontSize: 12),
                  ),
                  MaxAmountButton(
                    onPressed: () async {
                      //TODO: anukul -  set slider to max
                      var bottomTokenBalance = toAmountDisplayBigInt(
                          selectedBottomToken!.balance,
                          decimals: selectedBottomToken!.decimals,
                          fractionDigits: selectedBottomToken!.decimals);
                      await _amountBottomUpdated(bottomTokenBalance);
                      amountBottomController.text = bottomTokenBalance;
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

  // dispose
  @override
  void dispose() {
    super.dispose();
    _focusTop.removeListener(_onFocusTopChange);
    _focusBottom.removeListener(_onFocusBottomChange);
    _focusTop.dispose();
    _focusBottom.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Styles.primaryBackgroundColor,
            boxShadow: neumorphicShadow()),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [getTopToken(),Gap(16), getBottomToken(),Text("${selectedTopToken?.amount}-${selectedBottomToken?.amount}")],
        ),
      ),
    );
  }
}
