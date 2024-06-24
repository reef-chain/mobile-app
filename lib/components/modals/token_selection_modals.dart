import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/tokens/Token.dart';

class TokenSelection extends StatefulWidget {
  const TokenSelection(
      {Key? key,
      this.availableTokens = const [],
      required this.callback,
      required this.selectedToken})
      : super(key: key);

  final Function(TokenWithAmount token) callback;
  final String selectedToken;
  final List<dynamic> availableTokens;

  @override
  State<TokenSelection> createState() => TokenSelectionState();
}

class TokenSelectionState extends State<TokenSelection> {
  TextEditingController valueContainer = TextEditingController();
  String filterTokensBy = '';

  _changeState() {
    setState(() {
      bool isInputEmpty = valueContainer.text.isEmpty;
      filterTokensBy = isInputEmpty ? '' : valueContainer.text.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    valueContainer.addListener(_changeState);
  }

  @override
  void dispose() {
    valueContainer.removeListener(_changeState);
    valueContainer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          ViewBoxContainer(
            color: Colors.white,
            child: TextField(
              controller: valueContainer,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide:
                      BorderSide(color: Styles.secondaryAccentColor, width: 2),
                ),
                hintText: 'Search token name or address',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: 256, minWidth: double.infinity),
              child: Observer(builder: (_) {
                var displayTokens = ReefAppState
                    .instance.model.tokens.selectedErc20s.data
                    .toList();
                List<TokenWithAmount> newDisplayTokens = [];

                if (widget.availableTokens.isNotEmpty) {
                  try {
                    widget.availableTokens.forEach((element) {
                      var newTkn = TokenWithAmount.fromJson(element);
                      newDisplayTokens.add(newTkn);
                    });
                  } catch (e) {
                    print("error in available tokens=== $e");
                  }
                }

                if (filterTokensBy.isNotEmpty) {
                  newDisplayTokens = newDisplayTokens
                      .where((tkn) =>
                          tkn.name.toLowerCase().contains(filterTokensBy) ||
                          tkn.address.toLowerCase().contains(filterTokensBy))
                      .toList();
                  
                  if (newDisplayTokens.isEmpty &&
                      isEvmAddress(valueContainer.text)) {
                    ReefAppState.instance.tokensCtrl
                        .findToken(valueContainer.text)
                        .then((token) {
                          if (token != null) {
                            widget.callback(TokenWithAmount.fromJson(token));
                          }
                        });
                  }
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: newDisplayTokens.map((e) {
                    if (e.address == widget.selectedToken) {
                      return SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0x20000000),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x16000000),
                                  blurRadius: 24,
                                )
                              ],
                              borderRadius: BorderRadius.circular(8)),
                          child: MaterialButton(
                              splashColor: const Color(0x555531a9),
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.fromLTRB(12, 12, 12, 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                              onPressed: () {
                                widget.callback(e);
                                Navigator.of(context).pop();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    IconFromUrl(e.iconUrl),
                                    const Gap(12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(e.name,
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        Wrap(spacing: 8.0, children: [
                                          Text(toAmountDisplayBigInt(
                                              e.balance,
                                              decimals: e.decimals)),
                                          Text(e.symbol)
                                        ]),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              e.address.toString().shorten(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600]!),
                                            ),
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                    minimumSize:
                                                        const Size(0, 0),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: e.address));
                                                },
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const [
                                                    Icon(
                                                      Icons.copy,
                                                      size: 12,
                                                      color:
                                                          Styles.textLightColor,
                                                    ),
                                                    Gap(2),
                                                    Text(
                                                      "Copy Address",
                                                      style: TextStyle(
                                                          color:
                                                              Styles.textColor,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ]),
                                ],
                              )),
                        ),
                        if (e.address != newDisplayTokens.last.address)
                          const Gap(16),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

void showTokenSelectionModal(context,
    {required callback,
    required selectedToken,
    List<dynamic>? availableTokens}) {
  showModal(context,
      child: TokenSelection(
          callback: callback,
          selectedToken: selectedToken,
          availableTokens: availableTokens ?? []),
      headText: "Select Token");
}