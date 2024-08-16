import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/no_connection_button_wrap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class StealthexBuyPage extends StatefulWidget {
  const StealthexBuyPage({super.key});

  @override
  State<StealthexBuyPage> createState() => _StealthexBuyPageState();
}

class _StealthexBuyPageState extends State<StealthexBuyPage> {
  List<dynamic> currencies = [];
  Map<String, dynamic>? selectedCurrency;
  TextEditingController currencyController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool _isValueEditing = false;
  double estimatedReef = 0;
  bool isLoading = false;
  double inputAmount = 0.0;
  Map<String,dynamic>? purchaseResponse;
  bool isPurchaseResponse= false;

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);

    // Fetch the list of currencies
    ReefAppState.instance.stealthexCtrl.listCurrencies().then((val) {
      setState(() {
        currencies = val;
      });
    });
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
      amt = double.parse(amount.toString());
    } catch (e) {}

    setState(() {
      inputAmount=amt;
    });
    var res = await ReefAppState.instance.stealthexCtrl.getEstimatedExchange(
        selectedCurrency!["legacy_symbol"], selectedCurrency!["network"], amt);
    setState(() {
      estimatedReef = double.parse(res.toString());
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
  }

  void openDropdown() async {
    if (currencies.length > 0) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Styles.darkBackgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: currencies.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Gap(8.0),
                            Text(
                              "Fetching Currencies",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ))
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: currencies.length,
                            itemBuilder: (context, index) {
                              var currency = currencies[index];
                              return ListTile(
                                leading: SvgPicture.network(
                                    currency['icon_url'],
                                    width: 24,
                                    height: 24),
                                title: Text(
                                  currency['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  currency['symbol'].toString().toUpperCase(),
                                  style: TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedCurrency = currency;
                                    currencyController.text =
                                        currency['symbol'];
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      var res = await ReefAppState.instance.stealthexCtrl.listCurrencies();

      setState(() {
        currencies = res;
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
          backgroundColor: !(estimatedReef>0) ?Color.fromARGB(255, 125, 125, 125): Color.fromARGB(0, 215, 31, 31),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: ()async {
          if(estimatedReef>0.0){
            var res = await ReefAppState.instance.stealthexCtrl.createExchange(selectedCurrency!["legacy_symbol"], selectedCurrency!["network"], "reef","mainnet", inputAmount,ReefAppState.instance.model.accounts.selectedAddress!);
            setState(() {
              purchaseResponse = res;
              isPurchaseResponse=true;
            });
          }
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: !(estimatedReef>0)?null:Styles.buttonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              "Purchase",
              style: TextStyle(
                fontSize: 16,
                color:!(estimatedReef>0)?const Color(0x65898e9c): Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return isPurchaseResponse ? Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "To address:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "${purchaseResponse!["deposit"]["address"]}",
              style: TextStyle(color: Styles.textLightColor),
              softWrap: true,
            ),
          ),
        ],
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
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recipient Address:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "${purchaseResponse!["withdrawal"]["address"]}",
              style: TextStyle(color: Styles.textLightColor),
              softWrap: true,
            ),
          ),
        ],
      ),
    ],
  ),
): Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Purchase REEFs",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Styles.textLightColor),
              ),
              Gap(8.0),
              if (selectedCurrency != null)
                Container(
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        border: InputBorder.none,
                        hintText: "Select Currency",
                        hintStyle: TextStyle(color: Styles.textLightColor)),
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
                    await fetchEstimatedReef(val);
                  },
                  focusNode: _focusNode,
                  controller: amountController,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      border: InputBorder.none,
                      hintText: "Enter Amount",
                      hintStyle: TextStyle(color: Styles.textLightColor)),
                ),
              ),
              Gap(16.0),
              if (estimatedReef > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Estimated Reefs:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Styles.textLightColor,
                        ),
                      ),
                      Text(
                        "~${estimatedReef}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Styles.primaryAccentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isLoading) Text("Loading..."),
              Gap(8.0),
              getPurchaseBtn()
            ],
          ),
        ),
      ],
    );
  }
}
