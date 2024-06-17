import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
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

  // searched pools
  List<dynamic>? searchedPools;
  String searchInput = "";

  // search input listeners
  bool _isSearchEditing = false;

  FocusNode _focusNodeSearch = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNodeSearch.addListener(_onFocusSearchChange);
    _searchController.text = searchInput;
    _searchController.addListener(() {
      setState(() {
        searchPools(_searchController.text);
        searchInput = _searchController.text;
      });
    });
    _fetchTokensAndPools();
  }

  void searchPools(String val)async{
    final searchedPoolsRes = await ReefAppState.instance.tokensCtrl.getPools(offset,val);
    setState(() { 
      searchedPools = searchedPoolsRes; 
    });
  }

  void _onFocusSearchChange() {
    setState(() {
      _isSearchEditing = !_isSearchEditing;
    });
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

    final pools = await ReefAppState.instance.tokensCtrl.getPools(offset,"");
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
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _focusNodeSearch.removeListener(_onFocusSearchChange);
    _focusNodeSearch.dispose();
  }

  Card getPoolCard(dynamic pool){
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
                                  preselectedTop: pool['token1'],preselectedBottom: pool['token2']);
                            },
                          ),
                        )
                    ],
                  ),
                );
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
      child: _pools.length>0?
          Positioned.fill(
            bottom: 14.0,
            child: Column(
              children: [
                Gap(12.0),
                Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                focusNode: _focusNodeSearch,
                controller: _searchController,
                decoration: const InputDecoration.collapsed(hintText: 'Search'),
                style: const TextStyle(
                  fontSize: 16,
                ),
              )),
              if(searchInput.isNotEmpty && searchedPools!.isEmpty)
              Container(child: Row(
                children: [
                  Icon(Icons.error,size: 18.0,color: Styles.errorColor,),
                  Gap(4.0),
                  Text("No pools found!",style: TextStyle(color: Styles.errorColor,fontWeight: FontWeight.w800),),
                ],
              ),),
                 Gap(8.0),
                searchedPools is List<dynamic> && searchedPools!.isNotEmpty?
          Positioned(child: 
          Expanded(
            child: ListView.builder(
                itemCount: searchedPools?.length,
                itemBuilder: (context, index) {
                  var pool = searchedPools![index];
                  return getPoolCard(pool);
                },
              ),
          ),
          )
          :
                Expanded(
                  child: ListView.builder(
                    itemCount: _pools.length,
                    itemBuilder: (context, index) {
                      var pool = _pools[index];
                      return getPoolCard(pool);
                    },
                  ),
                ),
                isLoading && _pools.length>0?
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ):Gap(36.0),
              ],
            ),
      ):Center(child: CircularProgressIndicator(color: Styles.primaryColor,),),
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
