import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/CircularCountdown.dart';
import 'package:reef_mobile_app/components/MaxAmountButton.dart';
import 'package:reef_mobile_app/components/SliderStandAlone.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/components/no_connection_button_wrap.dart';
import 'package:reef_mobile_app/components/send/custom_stepper.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/swap/swap_settings.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/sign/SignatureContentToggle.dart';

class SwapPage extends StatefulWidget {
  final String? preselectedTop;
  final String? preselectedBottom;
  const SwapPage({this.preselectedTop = "", this.preselectedBottom, super.key});

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
  SendStatus statusValue = SendStatus.noAddress;
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
  List<dynamic> availableTokens = [];

  // checking evm bind state of selected account
  ReefAccount? selectedAccount;
  bool isEvmBinded = false;

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
      // setting state of evm
      selectedAccount = ReefAppState.instance.model.accounts.accountsList
          .firstWhere((account) =>
              account.address ==
              ReefAppState.instance.model.accounts.selectedAddress);
      isEvmBinded = ReefAppState.instance.model.accounts.accountsList
          .firstWhere((account) =>
              account.address ==
              ReefAppState.instance.model.accounts.selectedAddress)
          .isEvmClaimed;

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
      if (widget.preselectedBottom != null &&
          widget.preselectedTop != null &&
          !checkPreselectionBottom) {
        // fetch token info
        ReefAppState.instance.tokensCtrl
            .getTokenInfo(widget.preselectedBottom!)
            .then((value) {
          selectedBottomToken = TokenWithAmount.fromJson(value);
          isPreselectedBottomExists = true;
          _getPoolReserves();
        });
      }

      // set bottom to reef if pair exists
      if (widget.preselectedBottom == null &&
          widget.preselectedTop != Constants.REEF_TOKEN_ADDRESS &&
          widget.preselectedTop != null) {
        _getPoolPairs(widget.preselectedTop!).then((value) {
          value.forEach((e) {
            if (e['address'] == Constants.REEF_TOKEN_ADDRESS) {
              selectedBottomToken = ReefAppState
                  .instance.model.tokens.selectedErc20List
                  .firstWhere(
                      (token) => token.address == Constants.REEF_TOKEN_ADDRESS);
              _getPoolReserves();
            }
          });
        });
      }

      _getPoolReserves();

      // Keep input empty initially
      amountTopController.text = "";
    });
    super.initState();
  }

  /// Helper to clean strings from commas before parsing to double
  String cleanAmountStr(String value) {
    return value.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  /// Resets slippage slider to default value
  void resetDefaultSlider() {
    ReefAppState.instance.model.swapSettings.setSlippageTolerance(0.008);
    setState(() {
      slippage = "0.008";
    });
  }

  /// Fetches and updates pool reserves
  void _getPoolReserves() async {
    if (selectedTopToken == null || selectedBottomToken == null) {
      return;
    }
    setState(() {
      selectedTopToken = selectedTopToken!.setAmount("0");
      amountTopController.clear();
      selectedBottomToken = selectedBottomToken!.setAmount("0");
      amountBottomController.clear();
      rating = 0.0;
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
  }

  /// Returns current swap rate from pool
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

  /// Executes token swap transaction
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
            if (!isError)
              CircularCountDown(
                countdownMs: 60000,
                width: 80,
                height: 80,
                fillColor: Styles.primaryAccentColor,
                strokeWidth: 4,
                child: preloaderChild,
              ),
            if (isError) preloaderChild!,
            Gap(8.0),
            Text(
              "${preloaderMessage}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Styles.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (isError)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 5,
                    backgroundColor: Styles.primaryAccentColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  ),
                  onPressed: () {
                    setState(() {
                      txInProgress = false;
                      isError = false;
                      preloader = false;
                      rating = 0.0;
                    });
                    if (!isEvmBinded) {
                      showBindEvmModal(context,
                          bindFor: selectedAccount, callback: () async {});
                    }
                  },
                  child: Text(isEvmBinded ? "Retry" : "Claim EVM",
                      style: TextStyle(fontSize: 12, color: Styles.whiteColor)))
          ],
        ),
      ),
    );
  }

  /// Executes token swap transaction
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
    SwapSettings settings = SwapSettings(deadline, slippage * 100);
    Stream<dynamic> executeTransactionFeedbackStream =
        await ReefAppState.instance.swapCtrl.swapTokens(
            signerAddress, selectedTopToken!, selectedBottomToken!, settings);
    executeTransactionFeedbackStream =
        executeTransactionFeedbackStream.asBroadcastStream();

    executeTransactionFeedbackStream.listen(
      (txResponse) {
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
                  "waiting for swap transaction\n(${selectedTopToken?.name} - ${selectedBottomToken?.name})";
              preloaderChild = IconFromUrl(selectedBottomToken!.iconUrl);
            }
            if (txResponse['status'] == "_canceled") {
              preloader = false;
              btnLabel = "Cancelled";
              txInProgress = false;
            }
            if (txResponse['status'].toString().contains("-32603")) {
              if (txResponse['status'] ==
                      "-32603: execution fatal: Module { index: 6, error: 3, message: None }" &&
                  !isEvmBinded) {
                btnLabel = "EVM not binded";
                preloaderMessage =
                    "Transaction Failed as EVM is not binded for account";
              } else if (selectedAccount!.balance < BigInt.from(1000).pow(18)) {
                btnLabel = "Balance too low for swap";
                preloaderMessage =
                    "Minimum 1000 REEFs required for Swap Transaction.";
              } else {
                btnLabel = "Encountered an error";
                preloaderMessage = "Encountered an error";
              }
              preloader = true;
              isError = true;
              preloaderChild = Icon(Icons.error_outline);
            }
          });
          handleEvmTransactionResponse(txResponse);
        }
      },
    );
    _getPoolReserves();
  }

  /// Handles EVM swap transaction status updates
  bool handleEvmTransactionResponse(txResponse) {
    if (txResponse['status'] == 'broadcast') {
      setState(() {
        transactionData = txResponse['data'];
        statusValue = SendStatus.sentToNetwork;
      });
    }
    if (txResponse['status'] == 'included-in-block') {
      setState(() {
        transactionData = txResponse['data'];
        statusValue = SendStatus.includedInBlock;
      });
    }
    if (txResponse['status'] == 'finalized') {
      setState(() {
        transactionData = txResponse['data'];
        statusValue = SendStatus.finalized;
      });
    }
    if (txResponse['status'] == 'not-finalized') {
      setState(() {
        statusValue = SendStatus.notFinalized;
      });
    }
    return true;
  }

  /// Handles top token amount input and calculates output
  Future<void> _amountTopUpdated(String value) async {
    if (selectedTopToken == null) {
      return;
    }

    if (value.isEmpty || value == "0" || value == "0.0" || value == ".") {
      setState(() {
        selectedTopToken = selectedTopToken!.setAmount("0");
        if (selectedBottomToken != null) {
          selectedBottomToken = selectedBottomToken!.setAmount("0");
          amountBottomController.clear();
        }
        rating = 0.0;
      });
      return;
    }

    // CLEAN: Remove commas from input value
    String cleanValue = cleanAmountStr(value);
    if (cleanValue.isEmpty || cleanValue == "0") return;

    var formattedValue =
        toStringWithoutDecimals(cleanValue, selectedTopToken!.decimals);

    setState(() {
      selectedTopToken = selectedTopToken!.setAmount(formattedValue);

      // CLEAN: Remove commas from balance before parsing
      String rawBalance = cleanAmountStr(toAmountDisplayBigInt(
          selectedTopToken!.balance,
          decimals: selectedTopToken!.decimals,
          fractionDigits: selectedTopToken!.decimals));

      double balanceStr = double.tryParse(rawBalance) ?? 0.0;
      double inputStr = double.tryParse(cleanValue) ?? 0.0;

      if (balanceStr > 0) {
        rating = (inputStr / balanceStr).clamp(0.0, 1.0);
      }
    });

    if (reserveTop.isEmpty || selectedBottomToken == null) {
      return;
    }

    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    try {
      var res = (await ReefAppState.instance.swapCtrl
              .getSwapAmount(cleanValue, false, token1, token2))
          .replaceAll("\"", "");

      setState(() {
        selectedBottomToken = selectedBottomToken!.setAmount(res);
        amountBottomController.text = toAmountDisplayBigInt(
            selectedBottomToken!.amount,
            decimals: selectedBottomToken!.decimals);
      });
    } catch (e) {
      print("Error calculating swap amount: $e");
    }
  }

  /// Handles bottom token amount input and calculates required input
  Future<void> _amountBottomUpdated(String value) async {
    if (selectedBottomToken == null) {
      return;
    }

    if (value.isEmpty || value == "0" || value == "0.0" || value == ".") {
      setState(() {
        selectedBottomToken = selectedBottomToken!.setAmount("0");
        if (selectedTopToken != null) {
          selectedTopToken = selectedTopToken!.setAmount("0");
          amountTopController.clear();
        }
        rating = 0.0;
      });
      return;
    }

    // CLEAN: Remove commas
    String cleanValue = cleanAmountStr(value);
    if (cleanValue.isEmpty) return;

    var formattedValue =
        toStringWithoutDecimals(cleanValue, selectedBottomToken!.decimals);

    setState(() {
      selectedBottomToken = selectedBottomToken!.setAmount(formattedValue);
    });

    if (reserveTop.isEmpty || selectedTopToken == null) {
      return;
    }

    var token1 = selectedTopToken!.setAmount(reserveTop);
    var token2 = selectedBottomToken!.setAmount(reserveBottom);

    try {
      var res = (await ReefAppState.instance.swapCtrl
              .getSwapAmount(cleanValue, true, token1, token2))
          .replaceAll("\"", "");

      setState(() {
        selectedTopToken = selectedTopToken!.setAmount(res);
        amountTopController.text = toAmountDisplayBigInt(
            selectedTopToken!.amount,
            decimals: selectedTopToken!.decimals);

        // CLEAN: Remove commas before parsing for rating update
        String rawBalance = cleanAmountStr(toAmountDisplayBigInt(
            selectedTopToken!.balance,
            decimals: selectedTopToken!.decimals,
            fractionDigits: selectedTopToken!.decimals));
        double balanceStr = double.tryParse(rawBalance) ?? 0.0;
        double calculatedTop =
            double.tryParse(cleanAmountStr(amountTopController.text)) ?? 0.0;

        if (balanceStr > 0) {
          rating = (calculatedTop / balanceStr).clamp(0.0, 1.0);
        }
      });
    } catch (e) {
      print("Error calculating reverse swap amount: $e");
    }
  }

  /// Fetches available pool pairs for a token
  Future<List<dynamic>> _getPoolPairs(String tokenAddress) async {
    var poolPairs =
        await ReefAppState.instance.tokensCtrl.getPoolPairs(tokenAddress);
    setState(() {
      availableTokens = poolPairs;
    });
    return poolPairs;
  }

  /// Updates selected top token and refreshes pools
  void _changeSelectedTopToken(TokenWithAmount token) {
    setState(() {
      selectedTopToken = token;
      amountTopController.clear();
      rating = 0.0;
      _getPoolReserves();
      _getPoolPairs(token.address);
    });
  }

  /// Updates selected bottom token and resets related settings
  void _changeSelectedBottomToken(TokenWithAmount token) {
    setState(() {
      selectedBottomToken = token;
      amountBottomController.clear();
      _getPoolReserves();
      resetDefaultSlider();
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

  // Check if button should be disabled
  bool isSwapButtonDisabled() {
    if (selectedTopToken == null || selectedBottomToken == null) return true;

    // Check amounts dynamically using text controllers with clean strings
    double topAmount =
        double.tryParse(cleanAmountStr(amountTopController.text)) ?? 0.0;
    double bottomAmount =
        double.tryParse(cleanAmountStr(amountBottomController.text)) ?? 0.0;

    if (topAmount <= 0.0 || bottomAmount <= 0.0) return true;

    return false;
  }

  String getBtnLabel() {
    if (txInProgress) {
      if (btnLabel == "Cancelled" || btnLabel == "Encountered an error")
        return btnLabel;
    }

    if (selectedTopToken == null) return "Select sell token";
    if (selectedBottomToken == null) return "Select buy token";

    double topAmount =
        double.tryParse(cleanAmountStr(amountTopController.text)) ?? 0.0;
    double bottomAmount =
        double.tryParse(cleanAmountStr(amountBottomController.text)) ?? 0.0;

    if (topAmount <= 0.0 || bottomAmount <= 0.0) return "Insert amount";

    return "Swap";
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
                  rate,
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
                  selectedTopToken != null &&
                          selectedTopToken!.amount > BigInt.zero
                      ? "${max(selectedTopToken!.amount.toDouble() * (selectedTopToken!.price?.toDouble() ?? 0) * 0.0003 / 1e18, 0.0000).toStringAsFixed(4)}\$"
                      : "0.0000\$",
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
                  "${(double.parse(slippage) * 100).toStringAsFixed(2)}%",
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
                          Constants.REEF_TOKEN_ADDRESS,
                      availableTokens: availableTokens);
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
                      IconFromUrl(selectedTokenWithAmount.iconUrl),
                      const Gap(4),
                      Text(selectedTokenWithAmount.symbol),
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
                    await amountUpdated(text);
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
                    "Balance: ${toAmountDisplayBigInt(selectedTokenWithAmount.balance, decimals: selectedTokenWithAmount.decimals)} ${selectedTokenWithAmount.symbol}",
                    style:
                        TextStyle(color: Styles.textLightColor, fontSize: 12),
                  ),
                  MaxAmountButton(
                    onPressed: () async {
                      var tokenBalance = toAmountDisplayBigInt(
                          selectedTokenWithAmount.balance,
                          decimals: selectedTokenWithAmount.decimals,
                          fractionDigits: selectedTokenWithAmount.decimals);

                      // Automatically clean balance for the input
                      String cleanBalance = cleanAmountStr(tokenBalance);
                      amountController.text = cleanBalance;
                      await amountUpdated(cleanBalance);
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

  ConnectWrapperButton getSwapBtn() {
    bool isDisabled = isSwapButtonDisabled();

    return ConnectWrapperButton(
        child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor: isDisabled
              ? Color.fromARGB(255, 125, 125, 125)
              : Color.fromARGB(0, 215, 31, 31),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: isDisabled
            ? null
            : () {
                _executeSwap();
              },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: isDisabled ? null : Styles.buttonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              getBtnLabel(),
              style: TextStyle(
                fontSize: 16,
                color: isDisabled ? const Color(0x65898e9c) : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ));
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
                  if (token != null) IconFromUrl(token.iconUrl, size: 48),
                  const Gap(13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 120),
                        child: Text(
                          token != null ? token.name : 'Select',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xff19233c),
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (token != null)
                        Container(
                          constraints: BoxConstraints(maxWidth: 120),
                          child: Text(
                            "${toAmountDisplayBigInt(token.balance)} ${token.name.toUpperCase()}",
                            style: TextStyle(
                              color: Styles.textLightColor,
                              fontSize: 12,
                            ),
                            softWrap: true,
                          ),
                        ),
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
                    await amountUpdated(text);
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

    if (stat == SendStatus.error) {
      print('send tx error');
    }
    if (stat == SendStatus.canceled) {
      print('send tx canceled');
    }
    if (stat == SendStatus.sending) {
      index = 0;
    }
    if (stat == SendStatus.sentToNetwork) {
      index = 1;
    }
    if (stat == SendStatus.includedInBlock) {
      index = 2;
    }
    if (stat == SendStatus.finalized) {
      index = 3;
    }
    if (stat == SendStatus.notFinalized) {}

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

      amountTopController.text = amountBottomController.text;
      amountBottomController.clear();
      rating = 0.0;
    });
    _getPoolReserves();

    // Call update logic safely
    String safeAmount = cleanAmountStr(amountTopController.text);
    if (safeAmount.isNotEmpty &&
        double.tryParse(safeAmount) != null &&
        double.parse(safeAmount) > 0) {
      _amountTopUpdated(safeAmount);
    }
  }

  Row getSlider() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (selectedBottomToken != null &&
                selectedBottomToken!.balance > BigInt.zero) {
              _reversePair();
            }
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xffe6e2f1),
                gradient: selectedBottomToken != null &&
                        selectedBottomToken!.balance > BigInt.zero
                    ? Styles.buttonGradient
                    : null),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.repeat,
                size: 18,
                color: selectedBottomToken != null &&
                        selectedBottomToken!.balance > BigInt.zero
                    ? Styles.whiteColor
                    : const Color(0x65898e9c),
              ),
            ),
          ),
        ),
        Gap(8.0),
        Expanded(
          child: SliderStandAlone(
              isDisabled: txInProgress || selectedTopToken == null,
              rating: rating,
              onChanged: (newRating) async {
                setState(() {
                  rating = newRating;

                  // CLEAN: Remove commas before calculating slider value
                  String rawBalance = cleanAmountStr(toAmountDisplayBigInt(
                      selectedTopToken!.balance,
                      decimals: selectedTopToken!.decimals,
                      fractionDigits: selectedTopToken!.decimals));

                  String amountValue =
                      (double.parse(rawBalance) * rating).toStringAsFixed(2);

                  if (amountValue.endsWith(".00"))
                    amountValue =
                        amountValue.substring(0, amountValue.length - 3);

                  amountTopController.text = amountValue;
                });
                await _amountTopUpdated(amountTopController.text);
              }),
        ),
      ],
    );
  }

  Row getSlippageSlider() {
    return Row(
      children: [
        Text(
          "Slippage :",
          style: TextStyle(
              color: Styles.textLightColor,
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
        Expanded(
          child: SliderStandAlone(
              isSlippageSlider: true,
              isDisabled: txInProgress,
              rating: double.parse(slippage),
              onChanged: (newRating) async {
                setState(() {
                  slippage = newRating.toString();
                });
                ReefAppState.instance.model.swapSettings
                    .setSlippageTolerance(newRating);
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
    case SendStatus.finalized:
      if (stepIndex == currentIndex) {
        return ReefStepState.complete;
      } else if (stepIndex < currentIndex) {
        return ReefStepState.complete;
      }
      break;
    case SendStatus.canceled:
      if (stepIndex == currentIndex) {
        return ReefStepState.error;
      }
      break;
    case SendStatus.error:
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
  ready,
  noEvmConnected,
  noAddress,
  noAmt,
  amtTooHigh,
  addrNotValid,
  addrNotExist,
  lowReefEvm,
  lowReefNative,
  signing,
  sending,
  canceled,
  error,
  sentToNetwork,
  includedInBlock,
  finalized,
  notFinalized,
  evmNotBinded,
  connecting
}
