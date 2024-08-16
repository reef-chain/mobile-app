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
      amt = double.parse(amount);
    } catch (e) {}
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
          backgroundColor: Color.fromARGB(0, 215, 31, 31),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () {
          //anukulpandey
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe6e2f1),
            gradient: Styles.buttonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          ),
          child: Center(
            child: Text(
              "Purchase",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
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
    return Column(
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
                  keyboardType: TextInputType.number,
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
