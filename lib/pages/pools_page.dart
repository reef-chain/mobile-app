import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage({super.key});

  @override
  State<PoolsPage> createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> {
  List<dynamic> _pools = [];
  Map<String, dynamic> tokenBalances = {};
  int offset = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTokensAndPools();
  }

  void _fetchTokensAndPools() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    var selectedTokens = ReefAppState.instance.model.tokens.selectedErc20List;
    for (var token in selectedTokens) {
      tokenBalances[token.address] = token.balance;
    }

    final pools = await ReefAppState.instance.tokensCtrl.getPools(offset);
    if (pools is List<dynamic>) {
      setState(() {
        _pools.addAll(pools);
        offset += 10;
        isLoading = false;
      });
    }
  }

  bool hasBalance(String addr) {
    return tokenBalances.containsKey(addr) && tokenBalances[addr] > BigInt.from(0);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchTokensAndPools();
        }
        return true;
      },
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 14.0,
            child: ListView.builder(
              itemCount: _pools.length,
              itemBuilder: (context, index) {
                var pool = _pools[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        leading: Container(
                          width: 44,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              buildIcon(pool['iconUrl1'], 0),
                              Positioned(left: 14, child: buildIcon(pool['iconUrl2'], 14)),
                            ],
                          ),
                        ),
                        title: Text('${pool['name1']} - ${pool['name2']}'),
                        trailing:Text('${pool['symbol1']}/${pool['symbol2']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('TVL : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                                Text('\$${pool["tvl"]}', style: TextStyle(fontSize: 12.0)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('24h Vol. : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                                Text('\$ ${pool['volume24h']}', style: TextStyle(fontSize: 12.0)),
                                Text(' ${pool['volumeChange24h']} %', style: TextStyle(fontSize: 12.0, color: Styles.greenColor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (hasBalance(pool['token1']) || hasBalance(pool['token2']))
                        Container(
                          margin: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Styles.secondaryAccentColorDark,
                                  spreadRadius: -10,
                                  offset: Offset(0, 5),
                                  blurRadius: 20),
                            ],
                            borderRadius: BorderRadius.circular(80),
                            gradient: LinearGradient(
                              colors: [
                                Styles.purpleColorLight,
                                Styles.secondaryAccentColorDark
                              ],
                              begin: Alignment(-1, -1),
                              end: Alignment(1, 1),
                            ),
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              CupertinoIcons.repeat,
                              color: Colors.white,
                              size: 16.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: Colors.transparent,
                                shape: const StadiumBorder(),
                                elevation: 0),
                            label: Text(
                              "Swap",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            onPressed: () async {
                              ReefAppState.instance.navigationCtrl.navigateToSwapPage(
                                  context: context,
                                  preselected: pool['token1']); //anukulpandey also preselect token2 
                            },
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
          if (isLoading && _pools.length>0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            if (isLoading && !(_pools.length>0))
            Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }

  Widget buildIcon(String dataUrl, double positionOffset) {
    return ClipOval(
      child: isValidSVG(dataUrl)
          ? SvgPicture.string(
              utf8.decode(base64.decode(dataUrl.split('data:image/svg+xml;base64,')[1])),
              width: 30, height: 30)
          : Image.network(dataUrl, width: 30, height: 30, fit: BoxFit.cover),
    );
  }

  bool isValidSVG(String? dataUrl) {
    return dataUrl != null && dataUrl.contains("data:image/svg+xml;base64,");
  }
}
