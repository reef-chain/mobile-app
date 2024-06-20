import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/sign/SignatureContentToggle.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage({super.key});

  @override
  State<PoolsPage> createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> {
  List<dynamic> _pools = ReefAppState.instance.poolsCtrl.getCachedPools();
  Map<String, dynamic> tokenBalances = {};
  int offset = 0;
  bool isLoading = false;

  // searched pools
  List<dynamic> searchedPools = [];
  String searchInput = "";
  bool searched = false;

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
        searchInput = _searchController.text;
      });
    });
    _fetchTokensAndPools();
  }

  void clearSearch() {
    setState(() {
      searchInput = "";
      _searchController.text = "";
      searched = false;
    });
    searchPools("");
  }

  void searchPools(String val) async {
    final searchedPoolsRes =
        await ReefAppState.instance.poolsCtrl.getPools(offset, val);
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
    final pools = offset == 0
        ? []
        : await ReefAppState.instance.poolsCtrl.getPools(offset, "");
    if (pools is List<dynamic>) {
      ReefAppState.instance.poolsCtrl.appendPools(pools);
      setState(() {
        offset += 10;
        isLoading = false;
      });
    }
  }

  bool hasBalance(String addr) {
    return tokenBalances.containsKey(addr) &&
        tokenBalances[addr] > BigInt.from(0);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _focusNodeSearch.removeListener(_onFocusSearchChange);
    _focusNodeSearch.dispose();
  }

  Card getPoolCard(dynamic pool) {
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
            trailing: Text('${pool['symbol1']}/${pool['symbol2']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('TVL : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12.0)),
                    Text('\$${pool["tvl"]}', style: TextStyle(fontSize: 12.0)),
                  ],
                ),
                Row(
                  children: [
                    Text('24h Vol. : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12.0)),
                    Text('\$ ${pool['volume24h']}',
                        style: TextStyle(fontSize: 12.0)),
                    Text(' ${pool['volumeChange24h']} %',
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Styles.greenColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          if (hasBalance(pool['token1']) || hasBalance(pool['token2']))
            Container(
              margin: EdgeInsets.only(
                  top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
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
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                onPressed: () async {
                  ReefAppState.instance.navigationCtrl.navigateToSwapPage(
                      context: context,
                      preselectedTop: pool['token1'],
                      preselectedBottom: pool['token2']);
                },
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Styles.darkBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.pools,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                    color: Colors.grey.shade100,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModal(context,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
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
                                decoration: const InputDecoration.collapsed(
                                    hintText: 'Search'),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Gap(12),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 8.0,
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 8.0),
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
                              child: ElevatedButton(
                                onPressed: () {
                                  searchPools(searchInput);
                                  setState(() {
                                    searched = true;
                                  });
                                },
                                child: Text(
                                  "Search",
                                  style: TextStyle(color: Styles.whiteColor),
                                ),
                                style: ElevatedButton.styleFrom(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: Colors.transparent,
                                    shape: const StadiumBorder(),
                                    elevation: 0),
                              ),
                            )
                          ],
                        ),
                        headText: "Search Pools");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: Styles.buttonGradient),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        size: 18,
                        color: Styles.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (searched)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   searchedPools.isEmpty? Row(
                      children: [
                        Icon(Icons.error, size: 24.0, color: Styles.errorColor),
                        const Gap(4.0),
                        Text(
                          "No pools found for ${searchInput}!",
                          style: TextStyle(
                              color: Styles.errorColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                      ],
                    ):Text("Search Results for ${searchInput}",style: TextStyle(color: Styles.textLightColor,fontSize: 18.0,fontWeight: FontWeight.w800),),
                   GestureDetector(
                    onTap: (){clearSearch();},
                     child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Styles.buttonColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: Styles.whiteColor,
                        ),
                      ),
                                       ),
                   ),
                  ],
                ),
              ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    _fetchTokensAndPools();
                  }
                  return true;
                },
                child: searchedPools.isNotEmpty
                    ? ListView.builder(
                        itemCount: searchedPools.length,
                        itemBuilder: (context, index) {
                          var pool = searchedPools[index];
                          return getPoolCard(pool);
                        },
                      )
                    : _pools.isNotEmpty
                        ? ListView.builder(
                            itemCount: _pools.length,
                            itemBuilder: (context, index) {
                              var pool = _pools[index];
                              return getPoolCard(pool);
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(
                                color: Styles.primaryColor)),
              ),
            ),
            if (isLoading && _pools.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!isLoading && _pools.isNotEmpty)
              SizedBox(
                height: 40.0,
              )
          ],
        ),
      ),
    );
  }

  Widget buildIcon(String dataUrl, double positionOffset) {
    return ClipOval(
      child: isValidSVG(dataUrl)
          ? SvgPicture.string(
              utf8.decode(base64
                  .decode(dataUrl.split('data:image/svg+xml;base64,')[1])),
              width: 30,
              height: 30)
          : Image.network(dataUrl, width: 30, height: 30, fit: BoxFit.cover),
    );
  }

  bool isValidSVG(String? dataUrl) {
    return dataUrl != null && dataUrl.contains("data:image/svg+xml;base64,");
  }
}
