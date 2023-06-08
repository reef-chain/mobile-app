import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/components/NFT_videoplayer.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modals/select_account_modal.dart';
import 'package:reef_mobile_app/components/send/custom_stepper.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SendNFT extends StatefulWidget {
  final String nftUrl;
  final String name;
  final int balance;
  final String nftId;
  final String mimetype;

  SendNFT(this.nftUrl, this.name, this.balance, this.nftId, this.mimetype,
      {Key? key})
      : super(key: key);

  @override
  State<SendNFT> createState() => _SendNFTState();
}

class _SendNFTState extends State<SendNFT> {
  TextEditingController? _amountController;
  bool _isValueEditing = false;
  int amountToSend = 0;
  bool isFormDisabled = false;
  bool isMinBtnEnabled = false;
  bool isMaxBtnEnabled = true;
  bool _showNFTinfo = false;
  dynamic transactionData;
  String contractAddress = "";

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountController!.text = amountToSend.toString();
    getContractAddress();
  }

  @override
  void dispose() {
    _amountController!.dispose();
    super.dispose();
  }

  void getContractAddress() async {
    String? ownerAddress = ReefAppState.instance.model.accounts.selectedAddress;
    var fetchedContractAddress = await ReefAppState.instance.tokensCtrl
        .getNftInfo(widget.nftId, ownerAddress!);
    setState(() {
      contractAddress = fetchedContractAddress["contractAddress"];
    });
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

  void setStatusOnSignatureClosed() {
    when(
        (p0) =>
            ReefAppState.instance.signingCtrl.signatureRequests.list.isNotEmpty,
        () {
      // NEW SIGNATURE DISPLAYED
      when(
          (p0) =>
              ReefAppState.instance.signingCtrl.signatureRequests.list.isEmpty,
          () {
        print('REMOVED SIGN DISPLAY');
        setState(() {
          statusValue = SendStatus.SENDING;
        });
      });
    });
  }

  String address = "";
  TextEditingController valueController = TextEditingController();
  SendStatus statusValue = SendStatus.NO_ADDRESS;

  void setAmountState() async {
    bool isValidAddr = await _isValidAddress(address);
    setState(() {
      if (amountToSend <= widget.balance && amountToSend > 0) {
        if (isValidAddr) {
          statusValue = SendStatus.READY;
        } else {
          statusValue = SendStatus.ADDR_NOT_VALID;
        }
      } else {
        statusValue = SendStatus.NO_AMT;
      }
    });
  }

  Future<Stream<dynamic>> executeTransferTransaction(
      String unresolvedFrom, String evmFrom, String evmTo) async {
    return await ReefAppState.instance.signingCtrl.sendNFT(
        unresolvedFrom,
        contractAddress,
        evmFrom,
        evmTo,
        amountToSend,
        int.tryParse(widget.nftId)!);
  }

  Future<bool> _isValidAddress(String address) async {
    //checking if selected address is not evm
    if (address.startsWith("5")) {
      return await ReefAppState.instance.accountCtrl
          .isValidSubstrateAddress(address);
    } else if (address.startsWith("0x")) {
      return await ReefAppState.instance.accountCtrl.isValidEvmAddress(address);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buildInputElements() {
      void onSelectAccount(String selectedAddress) async {
        bool isValidAddr = await _isValidAddress(selectedAddress);
        setState(() {
          address = selectedAddress.trim();
          valueController.text = address;
          if (isValidAddr) {
            statusValue = SendStatus.NO_AMT;
            setAmountState();
          } else {
            statusValue = SendStatus.ADDR_NOT_VALID;
          }
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
                    onChanged: (value) async {
                      setState(() {
                        address = value;
                      });
                      bool isValidAddr = await _isValidAddress(address);
                      setState(() {
                        if (isValidAddr) {
                          statusValue = SendStatus.NO_AMT;
                        } else {
                          statusValue = SendStatus.ADDR_NOT_VALID;
                        }
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
                onPressed: () async {
                  print(await ReefAppState
                      .instance.signingCtrl.signatureRequests.list);
                  setStatusOnSignatureClosed();
                  String? unresolvedFrom =
                      ReefAppState.instance.model.accounts.selectedAddress;
                  String evmFrom = await ReefAppState.instance.accountCtrl
                      .resolveEvmAddress(unresolvedFrom!);
                  String evmTo = await ReefAppState.instance.accountCtrl
                      .resolveEvmAddress(address);

                  Stream<dynamic> transferTransactionFeedbackStream =
                      await executeTransferTransaction(
                          unresolvedFrom, evmFrom, evmTo);

                  transferTransactionFeedbackStream =
                      transferTransactionFeedbackStream.asBroadcastStream();

                  transferTransactionFeedbackStream.listen((txResponse) {
                    print('TRANSACTION RESPONSE=$txResponse');
                    if (txResponse['data']['status'] == 'broadcast') {
                      setState(() {
                        transactionData = txResponse['data'];
                        statusValue = SendStatus.SENT_TO_NETWORK;
                      });
                    }
                    if (txResponse['data']['status'] == 'included-in-block') {
                      setState(() {
                        transactionData = txResponse['data'];
                        statusValue = SendStatus.INCLUDED_IN_BLOCK;
                      });
                    }
                    if (txResponse['data']['status'] == 'finalized') {
                      setState(() {
                        transactionData = txResponse['data'];
                        statusValue = SendStatus.FINALIZED;
                      });
                    }
                  });
                },
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

    void resetState() {
      valueController.clear();
      setState(() {
        transactionData = null;
        address = '';
        isFormDisabled = false;
        statusValue = SendStatus.NO_ADDRESS;
        transactionData = null;
      });
    }

    var transferStatusUI =
        buildFeedbackUI(context, statusValue, resetState, () {
      final navigator = Navigator.of(context);
      navigator.pop();
      // ReefAppState.instance.navigationCtrl.navigate(NavigationPage.home);
    });
    return SingleChildScrollView(
      child: transferStatusUI ?? contractAddress == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Styles.primaryAccentColor,
                  ),
                  Gap(24.0),
                  Text("Fetching NFT details...")
                ],
              ),
            )
          : Container(
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
                    if (widget.mimetype != "video/mp4")
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
                    if (widget.mimetype == "video/mp4")
                      NFTsVideoPlayer(
                        widget.nftUrl,
                        displayChild: false,
                      ),
                    Gap(18.0),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showNFTinfo = !_showNFTinfo;
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Styles.textLightColor),
                          const Gap(8),
                          Builder(builder: (context) {
                            return Text(
                              "Show NFT info",
                              style: Theme.of(context).textTheme.bodyLarge,
                            );
                          }),
                          Expanded(child: Container()),
                          Icon(_showNFTinfo
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                    if (_showNFTinfo)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                        child: Column(
                          children: [
                            Gap(4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Balance : ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.textLightColor,
                                  ),
                                ),
                                Text(
                                  "${widget.balance}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryAccentColor,
                                  ),
                                ),
                              ],
                            ),
                            Gap(4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "NFT ID : ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.textLightColor,
                                  ),
                                ),
                                Text(
                                  "${widget.nftId}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryAccentColor,
                                  ),
                                ),
                              ],
                            ),
                            Gap(4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Contract Address ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.textLightColor,
                                  ),
                                ),
                                Expanded(
                                  child: contractAddress == ""
                                      ? Column(
                                          children: [
                                            Gap(8.0),
                                            Center(
                                              child: LinearProgressIndicator(
                                                color:
                                                    Styles.primaryAccentColor,
                                                backgroundColor:
                                                    Styles.greyColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "${contractAddress}",
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Styles.primaryAccentColor,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Gap(18.0),
                    Column(
                      children: buildInputElements(),
                    ),
                    Gap(18.0),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffe6e2f1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14.0)),
                      ),
                      padding: EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 32,
                            width: 32,
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
                                gradient: isMinBtnEnabled
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xffae27a5),
                                          Color(0xff742cb2)
                                        ],
                                        begin: Alignment(-1, -1),
                                        end: Alignment(1, 1),
                                      )
                                    : const LinearGradient(colors: [
                                        Color.fromARGB(76, 174, 174, 174),
                                        Color.fromARGB(86, 136, 144, 171),
                                      ])),
                            child: IconButton(
                              icon: Icon(
                                Icons.remove,
                                color: isMinBtnEnabled
                                    ? Colors.white
                                    : Colors.black,
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
                                    _amountController!.text =
                                        amountToSend.toString();
                                    isMaxBtnEnabled = true;
                                  }
                                  if (amountToSend == 0) {
                                    isMinBtnEnabled = false;
                                    isMaxBtnEnabled = true;
                                  }
                                });
                                setAmountState();
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
                                      _amountController!.text =
                                          amountToSend.toString();
                                      isMinBtnEnabled = false;
                                      isMaxBtnEnabled = true;
                                    });
                                    setAmountState();
                                  },
                                  child: Text(
                                    'Min',
                                    style: TextStyle(
                                        color: isMinBtnEnabled
                                            ? Styles.primaryAccentColor
                                            : Styles.textLightColor),
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
                                      isMinBtnEnabled = false;
                                      isMaxBtnEnabled = true;
                                    } else {
                                      int enteredValue =
                                          int.tryParse(value) ?? 0;
                                      if (enteredValue < 0) {
                                        statusValue = SendStatus.NO_AMT;
                                        _amountController!.text =
                                            enteredValue.toString();
                                        amountToSend = enteredValue;
                                        isMinBtnEnabled = false;
                                        isMaxBtnEnabled = true;
                                      } else if (enteredValue >
                                          widget.balance) {
                                        statusValue = SendStatus.AMT_TOO_HIGH;
                                        _amountController!.text =
                                            enteredValue.toString();
                                        amountToSend = enteredValue;
                                        isMinBtnEnabled = true;
                                        isMaxBtnEnabled = false;
                                      } else {
                                        amountToSend = enteredValue;
                                        isMinBtnEnabled = true;
                                        if (enteredValue == widget.balance) {
                                          isMaxBtnEnabled = false;
                                        }
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
                                      _amountController!.text =
                                          amountToSend.toString();
                                      isMinBtnEnabled = true;
                                      isMaxBtnEnabled = false;
                                    });
                                    setAmountState();
                                  },
                                  child: Text(
                                    'Max',
                                    style: TextStyle(
                                        color: isMaxBtnEnabled
                                            ? Styles.primaryAccentColor
                                            : Styles.textLightColor),
                                  )),
                            ],
                          ),
                          Gap(8.0),
                          Container(
                            height: 32,
                            width: 32,
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
                              gradient: isMaxBtnEnabled
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xffae27a5),
                                        Color(0xff742cb2)
                                      ],
                                      begin: Alignment(-1, -1),
                                      end: Alignment(1, 1),
                                    )
                                  : const LinearGradient(colors: [
                                      Color.fromARGB(76, 174, 174, 174),
                                      Color.fromARGB(86, 136, 144, 171),
                                    ]),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: isMaxBtnEnabled
                                    ? Colors.white
                                    : Colors.black,
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
                                    _amountController!.text =
                                        amountToSend.toString();
                                    isMaxBtnEnabled = true;
                                    isMinBtnEnabled = true;
                                  }
                                  if (amountToSend == widget.balance) {
                                    isMaxBtnEnabled = false;
                                    isMinBtnEnabled = true;
                                  }
                                  setAmountState();
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

  return Container(
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
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.deepPurple)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Go Back to Homepage"),
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
      ));
}

List<ReefStep> steps(SendStatus stat, int index) => [
      ReefStep(
          state: getStepState(stat, 0, index),
          title: const Text(
            'Sending Transaction',
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
                  "Sending Transaction to the network ...",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                )),
              ],
            ),
          )),
      ReefStep(
          state: getStepState(stat, 1, index),
          title: const Text(
            'Adding to Chain',
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
                  "Waiting to be included in next Block...",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                )),
              ],
            ),
          )),
      ReefStep(
          state: getStepState(stat, 2, index),
          title: const Text(
            'Sealing the Block',
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
                  "After this transaction has unreversible finality.",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                )),
              ],
            ),
          )),
      ReefStep(
          state: getStepState(stat, 3, index),
          title: const Text(
            'Transaction Finalized',
          ),
          content: const SizedBox(),
          icon: Icons.lock),
    ];

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