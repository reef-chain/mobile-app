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
  bool displaySearchModal = false;
  bool filterSwappable = false;

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
        searched = searchInput.isNotEmpty;
        searchPools(searchInput);
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

  Widget getPoolCard(dynamic pool) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      child: Card(
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
                    Positioned(
                        left: 14, child: buildIcon(pool['iconUrl2'], 14)),
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
                      Text('\$${pool["tvl"]}',
                          style: TextStyle(fontSize: 12.0)),
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
      ),
    );
  }

  Widget buildLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildSearchAcknowledge() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          searchedPools.isEmpty
              ? Row(
                  children: [
                    Icon(Icons.error, size: 14.0, color: Styles.errorColor),
                    const Gap(4.0),
                    Text(
                      "No pools found for ${searchInput}!",
                      style: TextStyle(
                          color: Styles.errorColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                    ),
                  ],
                )
              : Text(
                  "Search Results for ${searchInput}",
                  style: TextStyle(
                      color: Styles.textLightColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w800),
                ),
          GestureDetector(
            onTap: () {
              clearSearch();
            },
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(
      Stack(
        children: [
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filterSwappable = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Styles.boxBackgroundColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.sort,
                                size: 18,
                                color: Styles.textLightColor,
                              ),
                            ),
                          ),
                        ),
                        Gap(8.0),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              displaySearchModal = true;
                            });
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
                  ],
                ),
                if(filterSwappable)
                Container(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Text(
                        "Filter applied ",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                        decoration: BoxDecoration(
                          color: Styles.whiteColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "can swap",
                              style: TextStyle(
                                  color: Styles.textLightColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                            Gap(8.0),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  filterSwappable=false;
                                });
                              },
                                child: Container(
                              decoration: BoxDecoration(
                                  color: Styles.greyColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(CupertinoIcons.xmark,
                                    color: Colors.black87, size: 12),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
               
                Flexible(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!isLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        _fetchTokensAndPools();
                      }
                      return true;
                    },
                    child: _pools.isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _pools.length,
                            itemBuilder: (context, index) {
                              var pool = _pools[index];
                                if(filterSwappable){
      if(hasBalance(pool['token1']) || hasBalance(pool['token2']))return getPoolCard(pool);
      else return Container();
    }else{
                              return getPoolCard(pool);
    }
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(
                                color: Styles.primaryColor)),
                  ),
                ),
                if (isLoading && _pools.isNotEmpty) buildLoader()
              ],
            ),
          ),
          // blur effect and detect tap outside modal
          if (displaySearchModal)
            GestureDetector(
              onTap: () {
                setState(() {
                  displaySearchModal = false;
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          // search overlay
          if (displaySearchModal)
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: searchedPools.length > 0 ? 400 : 200,
                  margin: EdgeInsets.only(right: 18.0, left: 18.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Styles.boxBackgroundColor,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Search Pools",
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  color: Styles.textColor,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                            )),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    displaySearchModal = false;
                                  });
                                },
                                child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(99)),
                                      color: Colors.white,
                                    ),
                                    child: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(CupertinoIcons.xmark,
                                            color: Colors.black87, size: 12))))
                          ],
                        ),
                        Gap(16),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
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
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: searchInput.isNotEmpty ? 48 : 0,
                              margin: EdgeInsets.only(left: 16.0),
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: searchInput.isNotEmpty ? 1.0 : 0.0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Styles.secondaryAccentColorDark,
                                          spreadRadius: -10,
                                          offset: Offset(0, 5),
                                          blurRadius: 20,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(80),
                                      gradient: LinearGradient(
                                        colors: [
                                          Styles.purpleColorLight,
                                          Styles.secondaryAccentColorDark,
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
                                      child: Icon(
                                        Icons.search,
                                        color: Styles.whiteColor,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.transparent,
                                        shape: const StadiumBorder(),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(4.0),
                        if (searched) buildSearchAcknowledge(),
                        Gap(4.0),
                        if (searchedPools.isNotEmpty)
                          Flexible(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: searchedPools.length,
                              itemBuilder: (context, index) {
                                var pool = searchedPools[index];
                                return getPoolCard(pool);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
