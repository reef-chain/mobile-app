import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class StealthexBuyPage extends StatefulWidget {
  const StealthexBuyPage({super.key});

  @override
  State<StealthexBuyPage> createState() => _StealthexBuyPageState();
}

class _StealthexBuyPageState extends State<StealthexBuyPage> {
  List<dynamic> currencies = [];
  List<dynamic> filteredCurrencies = [];
  String selectedCurrency = '';
  TextEditingController currencyController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ReefAppState.instance.stealthexCtrl.listCurrencies().then((val) {
      setState(() {
        currencies = val;
        filteredCurrencies = val;
      });
    });
  }

  void filterCurrencies(String query) {
    setState(() {
      filteredCurrencies = currencies.where((currency) {
        final nameLower = currency['name'].toLowerCase();
        final symbolLower = currency['symbol'].toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) ||
            symbolLower.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: currencyController,
              readOnly: true,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  border: InputBorder.none,
                  hintText: "Select Currency",
                  hintStyle: TextStyle(color: Styles.textLightColor)),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          children: [
                            Expanded(
                              child: currencies.isEmpty
                                  ? CircularProgressIndicator()
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
                                            title: Text(currency['name']),
                                            subtitle: Text(currency['symbol']),
                                            onTap: () {
                                              setState(() {
                                                selectedCurrency =
                                                    currency['symbol'];
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
                        );
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  border: InputBorder.none,
                  hintText: "Enter Amount",
                  hintStyle: TextStyle(color: Styles.textLightColor)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ],
    );
  }
}
