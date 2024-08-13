import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class StealthexBuyPage extends StatefulWidget {
  const StealthexBuyPage({super.key});

  @override
  State<StealthexBuyPage> createState() => _StealthexBuyPageState();
}

class _StealthexBuyPageState extends State<StealthexBuyPage> {
  List<dynamic> currencies = [];
  String selectedCurrency = '';
  TextEditingController currencyController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool _isValueEditing = false;

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    super.initState();
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

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
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
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Column(
                              children: [
                                Expanded(
                                  child: currencies.isEmpty
                                      ? Center(
                                          child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(),
                                            Gap(8.0),
                                            Text("Fetching Currencies")
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
                                                title: Text(currency['name']),
                                                subtitle:
                                                    Text(currency['symbol']),
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
            ],
          ),
        ),
      ],
    );
  }
}
