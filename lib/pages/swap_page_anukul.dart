import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
  final String? preselectedTop;
  final String? preselectedBottom;
  const SwapPage({this.preselectedTop = "", this.preselectedBottom, Key? key})
      : super(key: key);

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  //preselected
  bool isPreselectedTopExists = false;
  bool isPreselectedBottomExists = false;

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

  //reserves
  String reserveTop = "";
  String reserveBottom = "";

  //summary
  String rate = "";
  String slippage =
      ReefAppState.instance.model.swapSettings.slippageTolerance.toString();
  String fee = "";

  //status reefstepper
  SendStatus statusValue = SendStatus.NO_ADDRESS;
  dynamic transactionData;

  //swap button label
  String btnLabel = "";
  bool txInProgress = false;

  //preloaders
  bool preloader = false;
  String? preloaderMessage;
  Widget? preloaderChild;
  bool isError = false;

  //available swap pairs
  List<dynamic> availableTokens=[];

  @override
  void initState() {
    _focusTop.addListener(_onFocusTopChange);
    _focusBottom.addListener(_onFocusBottomChange);

    bool checkPreselection = ReefAppState
        .instance.model.tokens.selectedErc20List
        .any((token) => token.address == widget.preselectedTop);
    bool checkPreselectionBottom = ReefAppState
        .instance.model.tokens.selectedErc20List
        .any((token) => token.address == widget.preselectedBottom);

    setState(() {
      // setting fixed component
      isPreselectedTopExists = checkPreselection;
      isPreselectedBottomExists = checkPreselectionBottom;

      // set default slider to 0.8%
      resetDefaultSlider();

      if (checkPreselection) {
        selectedTopToken = ReefAppState.instance.model.tokens.selectedErc20List
            .firstWhere((token) => token.address == widget.preselectedTop);
      _getPoolPairs(selectedTopToken!.address);
      }
      if (checkPreselectionBottom) {
        selectedBottomToken = ReefAppState
            .instance.model.tokens.selectedErc20List
            .firstWhere((token) => token.address == widget.preselectedBottom);
      }
      
      // if both set
      if(widget.preselectedBottom !=null && widget.preselectedTop!=null){
        // fetch token info
        ReefAppState.instance.tokensCtrl.getTokenInfo(widget.preselectedBottom!).then((value) {
          selectedBottomToken=TokenWithAmount.fromJson(value);
          isPreselectedBottomExists=true;
          _getPoolReserves();
        });
        
      }
      _getPoolReserves();
      

      amountTopController.text = selectedTopToken?.amount.toString() ?? '0';

    });
    super.initState();
  }

  void resetDefaultSlider(){
      ReefAppState.instance.model.swapSettings.setSlippageTolerance(0.008);
      setState(() {
        slippage="0.008";
      });
  }

  void _getPoolReserves() async {
    print("here i am ${selectedTopToken} ${selectedBottomToken}");
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

    var _rate = await getPoolRate();
    setState(() {
      rate = _rate;
    });

    print("Pool reserves: ${res['reserve1']}, ${res['reserve1']}");
  }

  Future<String> getPoolRate() async {
    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    var res = (await ReefAppState.instance.swapCtrl
            .getSwapAmount("1", false, token1, token2))
        .replaceAll("\"", "");
    var formattedRes =
        (BigInt.parse(res) / BigInt.from(10).pow(18)).toStringAsFixed(4);

    return '1 ${token1.symbol} = $formattedRes ${token2.symbol}';
  }

  Widget buildPreloader() {
    return Align(
      alignment: Alignment(0, 0.64),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Styles.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(!isError)
            CircularCountDown(
              countdownMs: 60000,
              width: 80,
              height: 80,
              fillColor: Styles.primaryAccentColor,
              strokeWidth: 4,
              child: preloaderChild,
            ),
            if(isError)preloaderChild!,
            Gap(8.0),
            Text(
              "${preloaderMessage}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Styles.textLightColor,
              ),
            ),
            if(isError)ElevatedButton(
              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                shadowColor: const Color(0x559d6cff),
                                elevation: 5,
                                backgroundColor: Styles.primaryAccentColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 32),
                              ),
              onPressed: (){
              setState(() {
                txInProgress=false;
                isError=false;
                preloader=false;
                rating=0.0;
              });
            }, child: Text("Retry",style: TextStyle(fontSize: 12,color: Styles.whiteColor)))
          ],
        ),
      ),
    );
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
        var deadline = ReefAppState.instance.model.swapSettings.deadline;
        var slippage = ReefAppState.instance.model.swapSettings.slippageTolerance;
        SwapSettings settings = SwapSettings(deadline, slippage*100);
    Stream<dynamic> executeTransactionFeedbackStream =
        await ReefAppState.instance.swapCtrl.swapTokens(
            signerAddress, selectedTopToken!, selectedBottomToken!,settings );
    executeTransactionFeedbackStream =
        executeTransactionFeedbackStream.asBroadcastStream();

    executeTransactionFeedbackStream.listen(
      (txResponse) {
        print('TRANSACTION RESPONSE anukul=$txResponse');
        if (txResponse != null) {
          setState(() {
            txInProgress = true;
            if (txResponse['status'] == "approving") {
              btnLabel = "Waiting to Approve";
              preloader = true;
              preloaderMessage =
                  "waiting for ${selectedTopToken?.name} approval";
              preloaderChild = IconFromUrl(selectedTopToken!.iconUrl);
            }
            if (txResponse['status'] == "approve-started") {
              btnLabel = "Approving";
            }
            if (txResponse['status'] == "approved") {
              btnLabel = "Waiting to Swap";
              preloaderMessage =
                  "waiting for swap transaction (${selectedTopToken?.name} - ${selectedBottomToken?.name})";
              preloaderChild = IconFromUrl(selectedBottomToken!.iconUrl);
            }
            if (txResponse['status'] == "_canceled") {
              preloader = false;
              btnLabel = "Cancelled";
              txInProgress = false;
            }
            if (txResponse['status'].toString().contains("-32603")) {
              preloader = true;
              btnLabel = "Encountered an error";
              isError=true;
              preloaderChild=Icon(Icons.error_outline);
              preloaderMessage="Encountered an error";
            }
          });
          handleEvmTransactionResponse(txResponse);
        }
      },
    );
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
  
  Future<List<dynamic>> _getPoolPairs(String tokenAddress)async{
    var poolPairs = await ReefAppState.instance.tokensCtrl.getPoolPairs(tokenAddress);
    setState(() {
      availableTokens=poolPairs;
    });
    return poolPairs;
  }

  void _changeSelectedTopToken(TokenWithAmount token) {
    setState(() {
      selectedTopToken = token;
      _getPoolReserves();
      _getPoolPairs(token.address);
    });
  }

  void _changeSelectedBottomToken(TokenWithAmount token) {
    print("==== ${token.address}");
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

  String getBtnLabel() {
    if (txInProgress) {
      if (btnLabel == "Cancelled" || btnLabel == "Encountered an error")
        return btnLabel;
    }
    return selectedTopToken == null
        ? "Select sell token"
        : selectedBottomToken == null
            ? "Select buy token"
            : selectedTopToken!.amount <= BigInt.zero ||
                    selectedBottomToken!.amount <= BigInt.zero
                ? "Insert amount"
                : "Swap";
  }

  // UI builders
  Container getPoolSummary() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffE7E2F2),
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
                style: TextStyle(
                    color: Styles.primaryAccentColor,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  "${rate}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Fee: ",
                style: TextStyle(
                    color: Styles.primaryAccentColor,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  "${max(selectedTopToken!.amount.toDouble() * selectedTopToken!.price!.toDouble() * 0.0003 / 1e18, 0.0000).toStringAsFixed(4)}\$",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Slippage: ",
                style: TextStyle(
                    color: Styles.primaryAccentColor,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  "${(double.parse(slippage)*100).toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, letterSpacing: 1.0),
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
                      selectedToken: selectedTopToken?.address ??
                          Constants.REEF_TOKEN_ADDRESS,availableTokens: availableTokens);
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
                  readOnly: txInProgress,
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
              getBtnLabel(),
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

  Container getFixedTokenField(
      bool isEditing,
      TokenWithAmount? token,
      FocusNode isFocus,
      TextEditingController amountController,
      dynamic amountUpdated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: isEditing
            ? Border.all(color: const Color(0xffa328ab))
            : Border.all(color: const Color(0x00d7d1e9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isEditing)
            const BoxShadow(
                blurRadius: 15,
                spreadRadius: -8,
                offset: Offset(0, 10),
                color: Color(0x40a328ab))
        ],
        color: isEditing ? const Color(0xffeeebf6) : const Color(0xffE7E2F2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  IconFromUrl(token!.iconUrl, size: 48),
                  const Gap(13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token != null ? token!.name : 'Select',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xff19233c)),
                      ),
                      Text(
                        "${toAmountDisplayBigInt(token!.balance)} ${token!.name.toUpperCase()}",
                        style: TextStyle(
                            color: Styles.textLightColor, fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
              Expanded(
                child: TextFormField(
                  focusNode: isFocus,
                  readOnly: txInProgress,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\.0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  onChanged: (text) async {
                    setState(() {
                      amountUpdated(amountController.text);
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
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Styles.whiteColor),
                              ),
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
            title: Text(
              AppLocalizations.of(context)!.transaction_finalized,
            ),
            content: const SizedBox(),
            icon: Icons.lock),
      ];

  void _reversePair() {
    if (selectedTopToken == null || selectedBottomToken == null) return;
    var topToken = selectedTopToken;
    setState(() {
      selectedTopToken = selectedBottomToken;
      selectedBottomToken = topToken;
    });
    _getPoolReserves();
  }

  Row getSlider() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _reversePair();
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: Styles.buttonGradient),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.repeat,
                size: 18,
                color: Styles.whiteColor,
              ),
            ),
          ),
        ),
        Gap(8.0),
        Expanded(
          child: SliderStandAlone(
              isDisabled: txInProgress,
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
        ),
      ],
    );
  }

  Row getSlippageSlider() {
    return Row(
      children: [
        Text("Slippage :",style: TextStyle(color: Styles.textLightColor,fontWeight: FontWeight.w600,fontSize: 12),),
        Expanded(
          child: SliderStandAlone(
              isSlippageSlider: true,
              isDisabled: txInProgress,
              rating: double.parse(slippage),
              onChanged: (newRating) async {
                setState(() {
                  slippage = newRating.toString();
                });
                ReefAppState.instance.model.swapSettings.setSlippageTolerance(newRating);
              }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var transferStatusUI = buildFeedbackUI(context, statusValue, () => {}, () {
      final navigator = Navigator.of(context);
      navigator.pop();
    });
    return transferStatusUI ??
        SignatureContentToggle(
          Stack(children: [
            Column(
              children: [
                Gap(24),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Styles.primaryBackgroundColor,
                      boxShadow: neumorphicShadow()),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      isPreselectedTopExists
                          ? getFixedTokenField(
                              _isValueTopEditing,
                              selectedTopToken,
                              _focusTop,
                              amountTopController,
                              _amountTopUpdated)
                          : getToken(
                              _isValueTopEditing,
                              _changeSelectedTopToken,
                              selectedTopToken,
                              _focusTop,
                              amountTopController,
                              _amountTopUpdated),
                      Gap(16),
                      getSlider(),
                      Gap(16),
                      isPreselectedBottomExists
                          ? getFixedTokenField(
                              _isValueBottomEditing,
                              selectedBottomToken,
                              _focusBottom,
                              amountBottomController,
                              _amountBottomUpdated)
                          : getToken(
                              _isValueBottomEditing,
                              _changeSelectedBottomToken,
                              selectedBottomToken,
                              _focusBottom,
                              amountBottomController,
                              _amountBottomUpdated),
                      Gap(16),
                      getSlippageSlider(),
                      Gap(16),
                      if (rate != "") getPoolSummary(),
                      Gap(16),
                      getSwapBtn(),
                    ],
                  ),
                ),
              ],
            ),
            if (preloader) buildPreloader(),
          ]),
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
