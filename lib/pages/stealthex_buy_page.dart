import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/CircularCountdown.dart';
import 'package:reef_mobile_app/components/generateQrJsonValue.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/jumping_dots.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/show_qr_code.dart';
import 'package:reef_mobile_app/components/no_connection_button_wrap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class StealthexBuyPage extends StatefulWidget {
  const StealthexBuyPage({super.key});

  @override
  State<StealthexBuyPage> createState() => _StealthexBuyPageState();
}

class _StealthexBuyPageState extends State<StealthexBuyPage> {
  List<dynamic> currencies = ReefAppState.instance.model.stealthexModel.currencies;
  Map<String, dynamic>? selectedCurrency;
  TextEditingController currencyController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool _isValueEditing = false;
  double estimatedReef = 0;
  bool isLoading = false;
  double inputAmount = 0.0;
  Map<String, dynamic>? purchaseResponse;
  bool isPurchaseResponse = false;
  bool isCalculateBtn = false;
  bool isCalculating = false;
  String txHash = "";
  double minAmount = 0;
  bool isMinAmountLoading = true;
  TextEditingController searchController = TextEditingController();

  FocusNode _focusNode = FocusNode();

  ValueNotifier<List<dynamic>> _filteredCurrenciesNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);

     ReefAppState.instance.stealthexCtrl.cacheCurrencies().then((v)=>{
    // Fetch the list of currencies
    setState(() {
      currencies = ReefAppState.instance.model.stealthexModel.currencies;

       _filteredCurrenciesNotifier.value = currencies;
    })
    });
  }

  void _filterCurrencies() {
    String searchText = searchController.text.toLowerCase();
    _filteredCurrenciesNotifier.value = currencies
        .where((currency) =>
            currency['name'].toLowerCase().contains(searchText) ||
            currency['symbol'].toLowerCase().contains(searchText))
        .toList();
  }

  void _onFocusChange() {
    setState(() {
      _isValueEditing = !_isValueEditing;
    });
  }

  Future<void> fetchEstimatedReef(amount) async {
    if (amount == Null || selectedCurrency == null) return;
    double amt = 0.0;
    setState(() {
      isLoading = true;
    });
    try {
      amt = double.tryParse(amount.toString())??0.0;
    } catch (e) {
      print("encountered error in fetchingEstimatedReef");
    }

    setState(() {
      inputAmount = amt;
      isCalculating=true;
    });
    var res = await ReefAppState.instance.stealthexCtrl.getEstimatedExchange(
        selectedCurrency!["legacy_symbol"], selectedCurrency!["network"], amt);

    setState(() {
      estimatedReef = double.tryParse(res.toString())??0.0;
      isLoading = false;
      isCalculateBtn=false;
      isCalculating=false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    searchController.dispose();
  }

  void resetUi(currency) async {
    setState(() {
      isMinAmountLoading = true;
    });
    var res = await ReefAppState.instance.stealthexCtrl
        .getExchangeRange(currency!["symbol"], currency!["network"]);
    setState(() {
      minAmount = res["min_amount"];
      isMinAmountLoading=false;
      amountController.text="";
      inputAmount=0;
      estimatedReef=0;
    });
  }

  void openDropdown() async {
    if (currencies.length > 0) {
      showModal(context,
          headText: "Purchase using",
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) {
                      _filterCurrencies();
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Search tokens",
                      hintStyle: TextStyle(color: Styles.textLightColor),
                    ),
                  ),
                ),
                ValueListenableBuilder<List<dynamic>>(
                    valueListenable: _filteredCurrenciesNotifier,
                    builder: (context, filteredCurrencies, child) {
                      return SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            var currency = filteredCurrencies[index];
                            return ListTile(
                              iconColor: Styles.whiteColor,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Styles.boxBackgroundColor,
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        193, 255, 255, 255),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.network(
                                    currency['icon_url'],
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              title: Text(
                                currency['name'],
                                style: TextStyle(color: Styles.textColor),
                              ),
                              subtitle: Text(
                                currency['symbol'].toString().toUpperCase(),
                                style: TextStyle(color: Styles.textLightColor),
                              ),
                              onTap: () async {
                                setState(() {
                                  selectedCurrency = currency;
                                  currencyController.text = currency['symbol'];
                                });

                                Navigator.pop(context);

                                // preloader here
                                resetUi(currency);
                              },
                            );
                          },
                        ),
                      );
                    }),
              ],
            ),
          ));
    } else {
      await ReefAppState.instance.stealthexCtrl.cacheCurrencies();

      var res = ReefAppState.instance.model.stealthexModel.currencies;

      setState(() {
        currencies = res;
        _filteredCurrenciesNotifier.value = currencies;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fetching currencies, Please try again!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  ConnectWrapperButton getPurchaseBtn() {
    return ConnectWrapperButton(
        child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor: !((estimatedReef > 0 || isCalculateBtn)&& inputAmount>minAmount)
              ? Color.fromARGB(255, 125, 125, 125)
              : Color.fromARGB(0, 215, 31, 31),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () async {
          if(inputAmount>minAmount){

          if(isCalculateBtn){
            await fetchEstimatedReef(inputAmount);
          }
          else if (estimatedReef > 0.0) {
            var res = await ReefAppState.instance.stealthexCtrl.createExchange(
                selectedCurrency!["legacy_symbol"],
                selectedCurrency!["network"],
                "reef",
                "mainnet",
                inputAmount,
                ReefAppState.instance.model.accounts.selectedAddress!);
            setState(() {
              purchaseResponse = res;
              isPurchaseResponse = true;
            });
          }else{ }
          }
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: !((estimatedReef > 0 || isCalculateBtn)&& inputAmount>minAmount) ? null : Styles.buttonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              isCalculateBtn? inputAmount>minAmount?"Calculate":"Minimum amount is ${minAmount}":"Purchase",
              style: TextStyle(
                fontSize: 16,
                color: !((estimatedReef > 0 || isCalculateBtn)&& inputAmount>minAmount)
                    ? const Color(0x65898e9c)
                    : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  SizedBox setTxHashStealthex() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0x559d6cff),
          elevation: 0,
          backgroundColor: !(txHash.length > 8)
              ? Color.fromARGB(255, 125, 125, 125)
              : Color.fromARGB(0, 215, 31, 31),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () async {
          if (txHash.length > 8) {
            var res = await ReefAppState.instance.stealthexCtrl
                .setTransactionHash(purchaseResponse!["id"], txHash);
            ReefAppState.instance.navigationCtrl
                .navigate(NavigationPage.accounts);
          }
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: !(txHash.length > 8) ? null : Styles.buttonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              !(txHash.length > 8) ? "Invalid Transaction Hash" : "Submit",
              style: TextStyle(
                fontSize: 16,
                color: !(txHash.length > 8)
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

  @override
  Widget build(BuildContext context) {
    return isPurchaseResponse
        ? Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        purchaseResponse!["status"] == "waiting"
                            ? "Awaiting deposit"
                            : purchaseResponse!["status"],
                        style: TextStyle(color: Styles.primaryAccentColor),
                      ),
                    ],
                  ),
                  Gap(8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "You Send:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${purchaseResponse!["deposit"]["amount"]} ${purchaseResponse!["deposit"]["symbol"].toString().toUpperCase()}",
                        style: TextStyle(color: Styles.textLightColor),
                      ),
                    ],
                  ),
                  Gap(8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Network:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${selectedCurrency!["name"]} (${purchaseResponse!["deposit"]["network"].toString().toUpperCase()})",
                        style: TextStyle(color: Styles.textLightColor),
                      ),
                    ],
                  ),
                  Gap(8.0),
                  Text(
                    "To address:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${purchaseResponse!["deposit"]["address"]}",
                    style: TextStyle(color: Styles.textLightColor),
                    softWrap: true,
                  ),
                  Center(
                    child: GenerateQrJsonValue(
                      data: purchaseResponse!["deposit"]["address"],
                      type: ReefQrCodeType.address,
                      shouldDisplayValueOnly: true,
                      isStealthexQr: true,
                    ),
                  ),
                  Gap(16.0),
                  Divider(color: Colors.grey[300], thickness: 1.0),
                  Gap(16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "You Receive:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${purchaseResponse!["withdrawal"]["amount"]} ${purchaseResponse!["withdrawal"]["symbol"].toString().toUpperCase()}",
                        style: TextStyle(color: Styles.textLightColor),
                      ),
                    ],
                  ),
                  Gap(8.0),
                  Text(
                    "Recipient Address:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${purchaseResponse!["withdrawal"]["address"]}",
                    style: TextStyle(color: Styles.textLightColor),
                    softWrap: true,
                  ),
                  Gap(16.0),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Styles.primaryAccentColor),
                      borderRadius: BorderRadius.circular(12),
                      color: Styles.whiteColor,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          border: InputBorder.none,
                          hintText: "Paste Transaction Hash",
                          hintStyle: TextStyle(color: Styles.textLightColor)),
                      onChanged: (val) {
                        setState(() {
                          txHash = val;
                        });
                      },
                    ),
                  ),
                  Gap(8.0),
                  setTxHashStealthex()
                ],
              ),
            ),
          )
        : currencies.isEmpty ?Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Gap(12.0),
              Text("Fetching Currencies",style: GoogleFonts.poppins(
                          color: Styles.textLightColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),),
            ],
          ),
        ):Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Purchase REEFs",
                        style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w500,
                            fontSize: 32,
                            color: Styles.textColor),
                      ),
                    ),
                    Gap(8.0),
                    if (selectedCurrency != null)
                      GestureDetector(
                        onTap: openDropdown,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x00d7d1e9)),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xffE7E2F2),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.network(
                                selectedCurrency!["icon_url"],
                                width: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${selectedCurrency!["name"].toString().toUpperCase()} (${selectedCurrency!["symbol"].toString().toUpperCase()})',
                                style: TextStyle(color: Styles.textLightColor),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: openDropdown,
                                child: const RotatedBox(
                                    quarterTurns: 1,
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: Styles.textColor,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (selectedCurrency == null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0x00d7d1e9)),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xffE7E2F2),
                        ),
                        child: TextField(
                          controller: currencyController,
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              border: InputBorder.none,
                              hintText: "Select Currency",
                              hintStyle:
                                  TextStyle(color: Styles.textLightColor)),
                          onTap: openDropdown,
                        ),
                      ),
                    SizedBox(height: 8.0),
                    Container(
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
                      child: TextField(
                        onChanged: (val) async {
                          setState(() {
                            inputAmount = double.tryParse(val.toString())??0.0;
                            isCalculateBtn = true;
                          });
                        },
                        focusNode: _focusNode,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                        ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        readOnly: isCalculating,
                        controller: amountController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            border: InputBorder.none,
                            hintText: "Enter Amount",
                            hintStyle: TextStyle(color: Styles.textLightColor)),
                      ),
                    ),
                    Gap(16.0),
                    if(minAmount==0 && selectedCurrency!=null)
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Currency Threshold",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.textLightColor,
                                  ),
                                ),
                                  JumpingDots(
                                    animationDuration:
                                        const Duration(milliseconds: 200),
                                    verticalOffset: 5,
                                    radius: 5,
                                    color: Styles.purpleColor,
                                    innerPadding: 2,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (estimatedReef > 0 || minAmount > 0)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Minimum Purchase:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.textLightColor,
                                  ),
                                ),
                                if(!isMinAmountLoading)
                                Text(
                                  "${minAmount.toDouble().toStringAsFixed(4)} ${selectedCurrency!["symbol"].toString().toUpperCase()}s",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryAccentColor,
                                  ),
                                ),
                                if(isMinAmountLoading)
                                Row(
                                  children: [
                                    JumpingDots(
                                        animationDuration:
                                            const Duration(milliseconds: 200),
                                        verticalOffset: 5,
                                        radius: 5,
                                        color: Styles.purpleColor,
                                        innerPadding: 2,
                                      ),
                                      Gap(2.0),
                                       Text(
                                  "${selectedCurrency!["symbol"].toString().toUpperCase()}s",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryAccentColor,
                                  ),
                                ),
                                  ],
                                ),
                              ],
                            ),
                            Gap(4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Estimated Amount:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.textLightColor,
                                  ),
                                ),
                                if (isLoading)
                                  JumpingDots(
                                    animationDuration:
                                        const Duration(milliseconds: 200),
                                    verticalOffset: 5,
                                    radius: 5,
                                    color: Styles.purpleColor,
                                    innerPadding: 2,
                                  ),
                                if (!isLoading)
                                  Text(
                                    "${estimatedReef} REEFs",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Styles.primaryAccentColor,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Gap(8.0),
                    getPurchaseBtn()
                  ],
                ),
              ),
            ],
          );
  }
}
