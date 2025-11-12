import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/components/modals/reconnect_modal.dart';
import 'package:reef_mobile_app/components/modals/select_account_modal.dart';
import 'package:reef_mobile_app/components/no_connection_button_wrap.dart';
import 'package:reef_mobile_app/components/send/custom_stepper.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/bind_evm.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';





const int MIN_EVM_TX_BALANCE = 80; // REEF required for EVM tx fees

enum SendStatus {
  NO_ADDRESS,
  NO_AMT,
  AMT_TOO_HIGH,
  NO_EVM_CONNECTED,
  ADDR_NOT_VALID,
  ADDR_NOT_EXIST,
  SIGNING,
  SENDING,
  SENT_TO_NETWORK,
  INCLUDED_IN_BLOCK,
  FINALIZED,
  NOT_FINALIZED,
  LOW_REEF_EVM,
  LOW_REEF_NATIVE,
  EVM_NOT_BINDED,
  RECIPIENT_NOT_BINDED, // ✅ added
  CANCELED,
  ERROR,
  CONNECTING,
  READY,
}

// -----------------------------------------------

class SendPage extends StatefulWidget {
  final String preselected;
  final String? preSelectedTransferAddress;

  const SendPage(
      this.preselected, {
        Key? key,
        this.preSelectedTransferAddress,
      }) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  // UI / State
  bool isTokenReef = false;
  SendStatus statusValue = SendStatus.NO_ADDRESS;

  final TextEditingController valueController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String address = "";
  String? resolvedEvmAddress;
  String amount = "";
  bool isValidAddress = false;

  late String selectedTokenAddress;
  bool _isValueEditing = false;
  bool _isValueSecondEditing = false;
  double rating = 0.0;

  final FocusNode _focus = FocusNode();
  final FocusNode _focusSecond = FocusNode();

  bool isFormDisabled = false;

  dynamic transactionData;

  // connections
  bool jsConn = false;
  bool indexerConn = false;
  bool providerConn = false;

  // subscriptions / disposers
  StreamSubscription? jsConnStateSubs;
  StreamSubscription? providerConnStateSubs;
  StreamSubscription? indexerConnStateSubs;
  StreamSubscription<dynamic>? _txSub;
  ReactionDisposer? _sigAppearDisposer;
  ReactionDisposer? _sigGoneDisposer;

  // accounts
  ReefAccount? selectedAccount;

  @override
  void initState() {
    super.initState();

    // ✅ resolve selectedAccount safely without returning null from a non-null closure
    final accounts = ReefAppState.instance.model.accounts.accountsList;
    final selAddr = ReefAppState.instance.model.accounts.selectedAddress;
    if (accounts.isEmpty) {
      selectedAccount = null;
    } else {
      selectedAccount = accounts.firstWhere(
            (e) => e.address == selAddr,
        orElse: () => accounts.first,
      );
    }

    // set selected token address
    selectedTokenAddress = widget.preselected;

    // prefill destination if provided
    if (widget.preSelectedTransferAddress != null) {
      final v = widget.preSelectedTransferAddress!.trim();
      address = v;
      valueController.text = v;
      statusValue = SendStatus.NO_AMT;
      isValidAddress = true;
    }

    // check if REEF token selected
    if (selectedTokenAddress == Constants.REEF_TOKEN_ADDRESS) {
      isTokenReef = true;
    }

    // listeners: provider
    providerConnStateSubs =
        ReefAppState.instance.networkCtrl.getProviderConnLogs().listen(
              (event) {
            if (!mounted) return;
            setState(() {
              providerConn = event?.isConnected == true;
            });
          },
          onError: (e, st) => debugPrint('providerConn error: $e'),
        );

    // listeners: indexer
    indexerConnStateSubs =
        ReefAppState.instance.networkCtrl.getIndexerConnected().listen(
              (event) {
            if (!mounted) return;
            setState(() {
              indexerConn = (event == true);
            });
          },
          onError: (e, st) => debugPrint('indexerConn error: $e'),
        );

    // listeners: jsConn (via future -> stream)
    ReefAppState.instance.metadataCtrl.getJsConnStream().then((jsStream) {
      if (!mounted) return;
      jsConnStateSubs = jsStream.listen(
            (event) {
          if (!mounted) return;
          setState(() {
            jsConn = (event == true);
          });
        },
        onError: (e, st) {
          if (!mounted) return;
          debugPrint('jsConn error: $e');
        },
      );
    }).catchError((e) {
      debugPrint('getJsConnStream error: $e');
    });

    // focus listeners
    _focus.addListener(_onFocusChange);
    _focusSecond.addListener(_onFocusSecondChange);

    // initial form disable check
    _disableInput();
  }

  @override
  void dispose() {
    valueController.dispose();
    amountController.dispose();
    _focus.removeListener(_onFocusChange);
    _focusSecond.removeListener(_onFocusSecondChange);
    _focus.dispose();
    _focusSecond.dispose();
    jsConnStateSubs?.cancel();
    providerConnStateSubs?.cancel();
    indexerConnStateSubs?.cancel();
    _txSub?.cancel();
    _sigAppearDisposer?.call();
    _sigGoneDisposer?.call();
    super.dispose();
  }

  // ---- listeners helpers ----
  void _onFocusChange() {
    if (!mounted) return;
    setState(() => _isValueEditing = !_isValueEditing);
  }

  void _onFocusSecondChange() {
    if (!mounted) return;
    setState(() => _isValueSecondEditing = !_isValueSecondEditing);
  }

  // ---- logic ----
  Future<void> _disableInput() async {
    final tokens = ReefAppState.instance.model.tokens.selectedErc20List;
    if (tokens.isEmpty) return;

    final selectedToken = tokens.firstWhere(
          (tkn) => tkn.address == selectedTokenAddress,
      orElse: () => tokens.first,
    );

    final balance = getSelectedTokenBalance(selectedToken);
    final hasEnoughForEvmTx = hasBalanceForEvmTx(selectedAccount);

    if (getMaxTransferAmount(selectedToken, balance) < 5 &&
        selectedTokenAddress == Constants.REEF_TOKEN_ADDRESS) {
      if (!mounted) return;
      setState(() {
        statusValue = SendStatus.LOW_REEF_NATIVE;
        isFormDisabled = true;
      });
    } else if (selectedToken.address != Constants.REEF_TOKEN_ADDRESS &&
        !hasEnoughForEvmTx) {
      if (!mounted) return;
      setState(() {
        statusValue = SendStatus.LOW_REEF_EVM;
        isFormDisabled = true;
      });
    }
  }

  Future<bool> _isValidAddress(String addr) async {
    if (addr.startsWith("5")) {
      return ReefAppState.instance.accountCtrl.isValidSubstrateAddress(addr);
    } else if (addr.startsWith("0x")) {
      return ReefAppState.instance.accountCtrl.isValidEvmAddress(addr);
    }
    return false;
  }

  bool hasBalanceForEvmTx(ReefAccount? reefSigner) {
    if (reefSigner == null) return false;
    return reefSigner.balance >= BigInt.from(MIN_EVM_TX_BALANCE * 1e18);
  }

  Future<SendStatus> _validate(
      String addr,
      TokenWithAmount token,
      String amt, [
        bool skipAsync = false,
      ]) async {
    final isValidAddr = await _isValidAddress(addr);
    final balance = getSelectedTokenBalance(token);
    final hasEnoughForEvmTx = hasBalanceForEvmTx(selectedAccount);

    if (amt.isEmpty) amt = '0';
    final amtVal = double.tryParse(amt) ?? 0;

    if (!mounted) return SendStatus.ERROR;
    setState(() => isValidAddress = isValidAddr);

    if (addr.isEmpty) {
      return SendStatus.NO_ADDRESS;
    } else if (amtVal > getMaxTransferAmount(token, balance)) {
      if (getMaxTransferAmount(token, balance) < 5 &&
          selectedTokenAddress == Constants.REEF_TOKEN_ADDRESS) {
        return SendStatus.LOW_REEF_NATIVE;
      }
      return SendStatus.AMT_TOO_HIGH;
    } else if (amtVal <= 0) {
      return SendStatus.NO_AMT;
    } else if (token.address != Constants.REEF_TOKEN_ADDRESS &&
        !hasEnoughForEvmTx) {
      return SendStatus.LOW_REEF_EVM;
    } else if (isValidAddr &&
        token.address != Constants.REEF_TOKEN_ADDRESS &&
        !addr.startsWith('0x')) {
      try {
        if (!skipAsync) {
          resolvedEvmAddress =
          await ReefAppState.instance.accountCtrl.resolveEvmAddress(addr);
        }
      } catch (_) {
        resolvedEvmAddress = null;
      }
      if (resolvedEvmAddress == null) {
        return SendStatus.NO_EVM_CONNECTED;
      }
    } else if (!isValidAddr) {
      return SendStatus.ADDR_NOT_VALID;
    } else if (!skipAsync && addr.startsWith('0x')) {
      if (!(await ReefAppState.instance.accountCtrl.isEvmAddressExist(addr))) {
        return SendStatus.ADDR_NOT_EXIST;
      } else if (selectedAccount != null &&
          !selectedAccount!.isEvmClaimed &&
          !(await ReefAppState.instance.accountCtrl.isEvmAddressExist(
            await ReefAppState.instance.accountCtrl
                .resolveEvmAddress(selectedAccount!.address),
          ))) {
        return SendStatus.EVM_NOT_BINDED;
      }
    }
    return SendStatus.READY;
  }

  Future<void> _onConfirmSend(TokenWithAmount sendToken) async {
    if (address.isEmpty ||
        sendToken.balance <= BigInt.zero ||
        statusValue != SendStatus.READY) {
      return;
    }
    if (!(jsConn && indexerConn && providerConn)) {
      if (!mounted) return;
      setState(() => statusValue = SendStatus.CONNECTING);
      await _waitForConnections(sendToken);
      return;
    }

    if (!mounted) return;
    setState(() {
      isFormDisabled = true;
      statusValue = SendStatus.SIGNING;
    });

    setStatusOnSignatureClosed();

    final transferStream = await executeTransferTransaction(sendToken);
    final broadcast = transferStream.asBroadcastStream();

    _txSub?.cancel();
    _txSub = broadcast.listen(
          (txResponse) {
        if (!mounted) return;

        if (handleExceptionResponse(txResponse)) {
          ReefAppState.instance.firebaseAnalyticsCtrl
              .logAnalytics("send-tx-error");
          return;
        }
        if (handleNativeTransferResponse(txResponse)) {
          ReefAppState.instance.firebaseAnalyticsCtrl
              .logAnalytics("native-send-tx-success");
          return;
        }
        if (handleEvmTransactionResponse(txResponse)) {
          ReefAppState.instance.firebaseAnalyticsCtrl
              .logAnalytics("evm-send-tx-success");
          return;
        }
      },
      onError: (e, st) {
        debugPrint('tx stream error: $e');
        if (!mounted) return;
        setState(() {
          isFormDisabled = false;
          statusValue = SendStatus.ERROR;
        });
      },
    );
  }

  Future<void> _waitForConnections(TokenWithAmount sendToken) async {
    const maxWait = Duration(seconds: 30);
    final start = DateTime.now();

    while (!(jsConn && indexerConn && providerConn)) {
      if (!mounted) return;
      setState(() => statusValue = SendStatus.CONNECTING);
      await Future.delayed(const Duration(seconds: 1));
      if (DateTime.now().difference(start) > maxWait) {
        if (!mounted) return;
        setState(() {
          isFormDisabled = false;
          statusValue = SendStatus.ERROR;
        });
        return;
      }
    }
    await _onConfirmSend(sendToken);
  }

  Future<Stream<dynamic>> executeTransferTransaction(
      TokenWithAmount sendToken,
      ) async {
    final signerAddress = await ReefAppState.instance.storageCtrl
        .getValue(StorageKey.selected_address.name);

    final tokenToTransfer = TokenWithAmount(
      name: sendToken.name,
      address: sendToken.address,
      iconUrl: sendToken.iconUrl,
      symbol: sendToken.name,
      balance: sendToken.balance,
      decimals: sendToken.decimals,
      amount: BigInt.parse(
        toStringWithoutDecimals(amount, sendToken.decimals),
      ),
      price: 0,
    );

    final toAddress = resolvedEvmAddress ?? address;
    return ReefAppState.instance.transferCtrl
        .transferTokensStream(signerAddress, toAddress, tokenToTransfer);
  }

  // MobX reactions for signature UI lifecycle
  void setStatusOnSignatureClosed() {
    _sigAppearDisposer?.call();
    _sigGoneDisposer?.call();

    _sigAppearDisposer = when(
          (_) =>
      ReefAppState.instance.signingCtrl.signatureRequests.list.isNotEmpty,
          () {
        _sigGoneDisposer?.call();
        _sigGoneDisposer = when(
              (_) => ReefAppState
              .instance.signingCtrl.signatureRequests.list.isEmpty,
              () {
            if (!mounted) return;
            setState(() => statusValue = SendStatus.SENDING);
          },
        );
      },
    );
  }

  SendStatus handleErrorResponse(String response) {
    if (response == "-32603: execution fatal: Module { index: 6, error: 3, message: None }") {
      return SendStatus.EVM_NOT_BINDED;
    }
    if (response == 'invalid address (argument="address", value="", code=INVALID_ARGUMENT, version=address/5.7.0) (argument="recipient", value="", code=INVALID_ARGUMENT, version=abi/5.7.0)') {
      // If you added a RECIPIENT_NOT_BINDED enum, map to it; else generic error/not valid.
      return SendStatus.ADDR_NOT_VALID;
    }

    // New cases:
    if (response == "timeout") {
      return SendStatus.ERROR; // or a specific TIMEOUT state if you have it
    }
    if (response == "provider_disconnected") {
      return SendStatus.ERROR;
    }
    if (response == "_canceled") {
      return SendStatus.READY; // user canceled: allow retry immediately
    }
    if (response == "signer_not_found") {
      return SendStatus.ERROR;
    }

    return SendStatus.ERROR;
  }

  bool handleExceptionResponse(dynamic txResponse) {
    if (txResponse == null || txResponse['success'] != true) {
      if (!mounted) return true;
      setState(() {
        isFormDisabled = false;
        statusValue = txResponse['data'] == '_canceled'
            ? SendStatus.READY
            : handleErrorResponse(txResponse['data']?.toString() ?? '');
      });
      return true;
    }
    return false;
  }

  bool handleEvmTransactionResponse(dynamic txResponse) {
    if (txResponse['type'] == 'reef20') {
      final status = txResponse['data']['status'];
      if (status == 'broadcast') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.SENT_TO_NETWORK;
        });
      } else if (status == 'included-in-block') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.INCLUDED_IN_BLOCK;
        });
      } else if (status == 'finalized') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.FINALIZED;
        });
      } else if (status == 'not-finalized') {
        setState(() => statusValue = SendStatus.NOT_FINALIZED);
      }
      return true;
    }
    return false;
  }

  bool handleNativeTransferResponse(dynamic txResponse) {
    if (txResponse['type'] == 'native') {
      final status = txResponse['data']['status'];
      if (status == 'broadcast') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.SENT_TO_NETWORK;
        });
      } else if (status == 'included-in-block') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.INCLUDED_IN_BLOCK;
        });
      } else if (status == 'finalized') {
        setState(() {
          transactionData = txResponse['data'];
          statusValue = SendStatus.FINALIZED;
        });
      }
      return true;
    }
    return false;
  }

  void resetState() {
    amountController.clear();
    valueController.clear();
    setState(() {
      amount = '';
      resolvedEvmAddress = null;
      transactionData = null;
      address = '';
      rating = 0;
      isFormDisabled = false;
      statusValue = SendStatus.NO_ADDRESS;
    });
  }

  String getSendBtnLabel(SendStatus validation) {
    switch (validation) {
      case SendStatus.NO_ADDRESS:
        return AppLocalizations.of(context)!.missing_destination;
      case SendStatus.NO_AMT:
        return AppLocalizations.of(context)!.insert_amount;
      case SendStatus.AMT_TOO_HIGH:
        return AppLocalizations.of(context)!.amount_too_high;
      case SendStatus.NO_EVM_CONNECTED:
        return AppLocalizations.of(context)!.target_not_evm;
      case SendStatus.ADDR_NOT_VALID:
        return AppLocalizations.of(context)!.enter_valid_address;
      case SendStatus.ADDR_NOT_EXIST:
        return AppLocalizations.of(context)!.unknown_address;
      case SendStatus.SIGNING:
        return AppLocalizations.of(context)!.sending_tx;
      case SendStatus.SENDING:
        return AppLocalizations.of(context)!.sending;
      case SendStatus.LOW_REEF_EVM:
        return AppLocalizations.of(context)!.minimum_80_reef;
      case SendStatus.LOW_REEF_NATIVE:
        return AppLocalizations.of(context)!.minimum_5_reef;
      case SendStatus.EVM_NOT_BINDED:
        return AppLocalizations.of(context)!.evm_not_connected;
      case SendStatus.CONNECTING:
        return AppLocalizations.of(context)!.connecting.capitalize();
      case SendStatus.RECIPIENT_NOT_BINDED: // ✅ now exists
        return AppLocalizations.of(context)!.recipient_not_binded;
      case SendStatus.READY:
        return AppLocalizations.of(context)!.confirm_send;
      default:
        return AppLocalizations.of(context)!.not_valid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferStatusUI =
    buildFeedbackUI(context, statusValue, resetState, () {
      Navigator.of(context).pop();
    });

    return transferStatusUI ??
        Column(
          children: [
            if (!(jsConn && indexerConn && providerConn))
              GestureDetector(
                onTap: () => showReconnectProviderModal(
                    AppLocalizations.of(context)!.connection_stats),
                child: Text(
                  AppLocalizations.of(context)!.connecting,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: Column(
                children: [
                  Observer(builder: (_) {
                    final tokens = ReefAppState
                        .instance.model.tokens.selectedErc20List;
                    if (tokens.isEmpty) {
                      return Text(
                        AppLocalizations.of(context)!.no_token_selected,
                      );
                    }
                    final selectedToken = tokens.firstWhere(
                          (t) => t.address == selectedTokenAddress,
                      orElse: () => tokens.first,
                    );
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Styles.primaryBackgroundColor,
                        boxShadow: neumorphicShadow(),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: <Widget>[
                          ...buildInputElements(selectedToken),
                          const Gap(36),
                          ...buildSliderWidgets(selectedToken),
                          const Gap(36),
                          buildSendStatusButton(selectedToken),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
  }

  // ---------- UI Parts ----------

  List<Widget> buildInputElements(TokenWithAmount selectedToken) {
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
                color: Color(0x40a328ab),
              ),
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
                onPressed: isFormDisabled
                    ? null
                    : () {
                  showSelectAccountModal(
                    AppLocalizations.of(context)!.select_address,
                        (selectedAddress) async {
                      if (!mounted) return;
                      setState(() {
                        address = selectedAddress.trim();
                        valueController.text = address;
                      });
                      final state = await _validate(
                          address, selectedToken, amount);
                      if (!mounted) return;
                      setState(() => statusValue = state);
                    },
                    isTokenReef,
                  );
                },
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isFormDisabled
                        ? Styles.textLightColor
                        : Styles.textColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                focusNode: _focus,
                readOnly: isFormDisabled,
                controller: valueController,
                onChanged: (text) async {
                  final sanitizedAddress = await ReefAppState
                      .instance.accountCtrl
                      .sanitizeEvmAddress(text.trim());

                  if (!mounted) return;
                  setState(() {
                    address = sanitizedAddress;
                    valueController.text = sanitizedAddress;
                    valueController.selection = TextSelection.fromPosition(
                      TextPosition(offset: valueController.text.length),
                    );
                  });

                  final state =
                  await _validate(address, selectedToken, amount);
                  if (!mounted) return;
                  setState(() => statusValue = state);
                },
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isFormDisabled
                      ? Styles.textLightColor
                      : Styles.textColor,
                ),
                decoration: InputDecoration(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.send_to_address,
                  hintStyle: const TextStyle(color: Styles.textLightColor),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .address_can_not_be_empty;
                  }
                  return null;
                },
              ),
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
                onPressed: isFormDisabled
                    ? null
                    : () {
                  showQrTypeDataModal(
                    AppLocalizations.of(context)!.scan_address,
                    context,
                    expectedType: ReefQrCodeType.address,
                    preselectedTokenAddress: selectedToken.address,
                  );
                },
                child: const Icon(
                  Icons.qr_code_scanner_sharp,
                  color: Styles.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
      const Gap(10),
      if (isValidAddress)
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    color: Styles.greenColor, size: 16),
                const Gap(5),
                Text(
                  address.shorten(),
                  style: const TextStyle(
                    color: Styles.textLightColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Gap(10),
          ],
        ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: _isValueSecondEditing
              ? Border.all(color: const Color(0xffa328ab))
              : Border.all(color: const Color(0x00d7d1e9)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (_isValueSecondEditing)
              const BoxShadow(
                blurRadius: 15,
                spreadRadius: -8,
                offset: Offset(0, 10),
                color: Color(0x40a328ab),
              ),
          ],
          color: _isValueSecondEditing
              ? const Color(0xffeeebf6)
              : const Color(0xffE7E2F2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconFromUrl(selectedToken.iconUrl, size: 48),
                const Gap(13),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedToken.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: isFormDisabled
                            ? Styles.textLightColor
                            : Styles.darkBackgroundColor,
                      ),
                    ),
                    Text(
                      "${selectedToken.balance > BigInt.zero ? NumberFormat.compact().format((selectedToken.balance) / BigInt.from(10).pow(18)).toString() : 0} ${selectedToken.name.toUpperCase()}",
                      style: const TextStyle(
                        color: Styles.textLightColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TextFormField(
                    focusNode: _focusSecond,
                    readOnly: isFormDisabled,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$'),
                      ),
                    ],
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    controller: amountController,
                    onChanged: (text) async {
                      amount = amountController.text;
                      final status =
                      await _validate(address, selectedToken, amount);
                      if (!mounted) return;
                      setState(() {
                        statusValue = status;

                        final balance = getSelectedTokenBalance(selectedToken);
                        final amt = double.tryParse(amount) ?? 0;
                        var calcRating =
                            amt / getMaxTransferAmount(selectedToken, balance);

                        if (calcRating < 0 ||
                            calcRating.isInfinite ||
                            calcRating.isNaN) {
                          calcRating = 0;
                        }
                        rating = calcRating > 1 ? 1 : calcRating;
                      });
                    },
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isFormDisabled
                          ? Styles.textLightColor
                          : Styles.textColor,
                    ),
                    decoration: const InputDecoration(
                      constraints: BoxConstraints(maxHeight: 32),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.transparent),
                      ),
                      hintText: '0.0',
                      hintStyle: TextStyle(color: Styles.textLightColor),
                    ),
                    textAlign: TextAlign.right,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .address_can_not_be_empty;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> buildSliderWidgets(TokenWithAmount selectedToken) {
    // decide precision based on token decimals (cap at 8 for UI sanity)
    final int uiDecimals = (selectedToken.decimals > 0)
        ? (selectedToken.decimals > 8 ? 8 : selectedToken.decimals)
        : 6;

    double balance = getSelectedTokenBalance(selectedToken);
    final double maxTransfer = getMaxTransferAmount(selectedToken, balance);

    // keep rating within 0..1 (in case previous state got weird)
    final double safeRating = rating.isNaN || rating.isInfinite
        ? 0.0
        : rating.clamp(0.0, 1.0);

    String formatAmount(double v) => v.toStringAsFixed(uiDecimals);

    return [
      SliderTheme(
        data: SliderThemeData(
          showValueIndicator: ShowValueIndicator.never,
          overlayShape: SliderComponentShape.noOverlay,
          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: Styles.secondaryAccentColorDark,
          thumbColor: Styles.secondaryAccentColorDark,
          inactiveTickMarkColor: const Color(0xffc0b8dc),
          trackShape: GradientRectSliderTrackShape(
            gradient: Styles.buttonGradient,
            darkenInactive: true,
          ),
          activeTickMarkColor: const Color(0xffffffff),
          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
          thumbShape: const ThumbShape(),
        ),
        child: Slider(
          // keep the internal 0..1 “rating” model
          value: safeRating,
          onChanged: isFormDisabled
              ? null
              : (newRating) async {
            // compute amount from rating with better precision
            final double rawAmt = (maxTransfer * newRating);
            final String amountStr = formatAmount(
              rawAmt.isNaN || rawAmt.isInfinite ? 0 : rawAmt.clamp(0, maxTransfer),
            );

            final status = await _validate(
              address,
              selectedToken,
              amountStr,
              true, // skipAsync for smoothness while dragging
            );
            if (!mounted) return;
            setState(() {
              rating = newRating.clamp(0.0, 1.0);
              amount = amountStr;
              amountController.text = amountStr;
              statusValue = status;
            });
          },
          onChangeEnd: (newRating) async {
            final double rawAmt = (maxTransfer * newRating);
            final String amountStr = formatAmount(
              rawAmt.isNaN || rawAmt.isInfinite ? 0 : rawAmt.clamp(0, maxTransfer),
            );
            amount = amountStr;
            amountController.text = amountStr;

            final status = await _validate(address, selectedToken, amount);
            if (!mounted) return;
            setState(() => statusValue = status);
          },
          inactiveColor: Colors.white24,
          // 👇 increase precision a lot
          divisions: 1000,
          label: "${(safeRating * 100).toStringAsFixed(0)}%",
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "0%",
              style: TextStyle(
                color: Styles.textLightColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              "50%",
              style: TextStyle(
                color: Styles.textLightColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              "100%",
              style: TextStyle(
                color: Styles.textLightColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  ConnectWrapperButton buildSendStatusButton(TokenWithAmount selectedToken) {
    return ConnectWrapperButton(
      child: Column(
        children: [
          SizedBox(
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
              onPressed: () => _onConfirmSend(selectedToken),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 15, horizontal: 22),
                decoration: BoxDecoration(
                  color: const Color(0xffe6e2f1),
                  gradient: (statusValue == SendStatus.READY)
                      ? Styles.buttonGradient
                      : null,
                  borderRadius: const BorderRadius.all(
                      Radius.circular(14.0)),
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
                Text(AppLocalizations.of(context)!.generating_signature),
                const Gap(12),
                const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Styles.primaryAccentColor),
                  backgroundColor: Styles.greyColor,
                ),
              ],
            ),
          ),
          const Gap(8.0),
          if (statusValue == SendStatus.EVM_NOT_BINDED &&
              anyAccountHasBalance(BigInt.from(MIN_BALANCE * 1e18)) &&
              selectedAccount != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  shadowColor: const Color(0x559d6cff),
                  elevation: 0,
                  backgroundColor: const Color(0xffe6e2f1),
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  showBindEvmModal(
                    context,
                    bindFor: selectedAccount!,
                    callback: () async {
                      final _statusValue =
                      await _validate(address, selectedToken, amount);
                      if (!mounted) return;
                      setState(() => statusValue = _statusValue);
                    },
                  );
                },
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xffe6e2f1),
                    gradient: Styles.buttonGradient,
                    borderRadius:
                    const BorderRadius.all(Radius.circular(14.0)),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.connect_evm,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String getSliderValues(double newRating, TokenWithAmount selectedToken) {
    // Clamp rating within valid bounds
    rating = newRating.clamp(0.0, 1.0);

    // Get user token balance
    final balance = getSelectedTokenBalance(selectedToken);
    final maxTransferAmount = getMaxTransferAmount(selectedToken, balance);

    // Calculate new amount value
    double amountValue = balance * rating;

    // Fix invalid or out-of-range values
    if (amountValue.isNaN || amountValue.isInfinite || amountValue < 0) {
      amountValue = 0;
    }
    if (amountValue > maxTransferAmount) {
      amountValue = maxTransferAmount >= 0 ? maxTransferAmount : 0;
    }

    // Use token decimals for precision — up to 8 for UX neatness
    final int uiDecimals = (selectedToken.decimals > 0)
        ? (selectedToken.decimals > 8 ? 8 : selectedToken.decimals)
        : 6;

    // Return properly formatted string
    return amountValue.toStringAsFixed(uiDecimals);
  }

  double getMaxTransferAmount(TokenWithAmount token, double balance) =>
      token.address == Constants.REEF_TOKEN_ADDRESS ? balance - 3 : balance;

  double getSelectedTokenBalance(TokenWithAmount selectedToken) {
    return double.parse(toAmountDisplayBigInt(selectedToken.balance));
  }

  // ---------- TX Feedback UI ----------
  Widget? buildFeedbackUI(
      BuildContext context,
      SendStatus stat,
      void Function() onNew,
      void Function() onHome,
      ) {
    int? index;

    if (stat == SendStatus.SENDING) index = 0;
    if (stat == SendStatus.SENT_TO_NETWORK) index = 1;
    if (stat == SendStatus.INCLUDED_IN_BLOCK) index = 2;
    if (stat == SendStatus.FINALIZED) index = 3;

    if (index == null) return null;

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
              if ((index)! >= 3) {
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
                              vertical: 16,
                              horizontal: 32,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            AppLocalizations.of(context)!.continue_,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Styles.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  List<ReefStep> steps(SendStatus stat, int index) => [
    ReefStep(
      state: getStepState(stat, 0, index),
      title: Text(AppLocalizations.of(context)!.sending_transaction),
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.sending_tx_to_nw,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ReefStep(
      state: getStepState(stat, 1, index),
      title: Text(AppLocalizations.of(context)!.adding_to_chain),
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!
                    .waiting_to_include_in_block,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ReefStep(
      state: getStepState(stat, 2, index),
      title: Text(AppLocalizations.of(context)!.sealing_block),
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.unreversible_finality,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ReefStep(
      state: getStepState(stat, 3, index),
      title: Text(AppLocalizations.of(context)!.transaction_finalized),
      content: const SizedBox(),
      icon: Icons.lock,
    ),
  ];

  ReefStepState getStepState(
      SendStatus stat, int stepIndex, int currentIndex) {
    switch (stat) {
      case SendStatus.FINALIZED:
        if (stepIndex <= currentIndex) return ReefStepState.complete;
        break;
      case SendStatus.CANCELED:
      case SendStatus.ERROR:
        if (stepIndex == currentIndex) return ReefStepState.error;
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
}

