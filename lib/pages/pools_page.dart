import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import '../components/sign/SignatureContentToggle.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage({super.key});

  @override
  State<PoolsPage> createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> {
  List<dynamic> _pools = ReefAppState.instance.poolsCtrl.getCachedPools();
  final Map<String, dynamic> tokenBalances = {};
  int offset = 0;
  bool isLoading = false;

  // search
  List<dynamic>? searchedPools;
  String searchInput = "";
  bool searched = false;
  bool hasReef = false;

  final FocusNode _focusNodeSearch = FocusNode();
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
      });
      searchPools(searchInput);
    });
    _fetchUserBalance();
    _fetchTokensAndPools(initial: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNodeSearch.removeListener(_onFocusSearchChange);
    _focusNodeSearch.dispose();
    super.dispose();
  }

  void _onFocusSearchChange() {
    // optional visual effect toggle; keep if you use it in the UI
    // setState(() {});
  }

  void _fetchUserBalance() {
    try {
      final selectedAccount = ReefAppState
          .instance.model.accounts.accountsList
          .firstWhere((account) =>
      account.address ==
          ReefAppState.instance.model.accounts.selectedAddress);
      if (selectedAccount.balance > BigInt.zero) {
        setState(() => hasReef = true);
      }
    } catch (e) {
      debugPrint("error fetching selected account $e");
    }
  }

  Future<void> _fetchTokensAndPools({bool initial = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    // gather balances
    final selectedTokens = ReefAppState.instance.model.tokens.selectedErc20List;
    for (final token in selectedTokens) {
      tokenBalances[token.address] = token.balance;
    }

    // fetch pools page
    try {
      final pools = await ReefAppState.instance.poolsCtrl.getPools(offset, "");
      if (pools is List<dynamic>) {
        if (initial && _pools.isEmpty) {
          _pools = pools;
        } else {
          ReefAppState.instance.poolsCtrl.appendPools(pools);
          _pools = ReefAppState.instance.poolsCtrl.getCachedPools();
        }
        setState(() {
          offset += 10;
        });
      }
    } catch (e) {
      debugPrint('getPools error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void clearSearch() {
    setState(() {
      searchInput = "";
      _searchController.text = "";
      searched = false;
      searchedPools = null;
    });
    searchPools("");
  }

  Future<void> searchPools(String val) async {
    try {
      final res = await ReefAppState.instance.poolsCtrl.getPools(0, val);
      if (!mounted) return;
      setState(() {
        searchedPools = res is List<dynamic> ? res : const [];
      });
    } catch (e) {
      debugPrint('searchPools error: $e');
      if (!mounted) return;
      setState(() => searchedPools = const []);
    }
  }

  bool hasBalance(String addr) {
    return tokenBalances.containsKey(addr) &&
        (tokenBalances[addr] as BigInt) > BigInt.zero;
  }

  // ---- UI helpers ----

  String _normalizeIpfsUrl(String url) {
    // some gateways can be blocked or flaky; fall back to ipfs.io
    if (url.startsWith('https://cloudflare-ipfs.com/ipfs/')) {
      return url.replaceFirst('https://cloudflare-ipfs.com/ipfs/', 'https://ipfs.io/ipfs/');
    }
    return url;
  }

  Widget _tokenIcon(String? dataUrl, {double size = 30}) {
    if (dataUrl == null || dataUrl.isEmpty) {
      return _fallbackTokenCircle(size);
    }
    // base64 svg inline
    if (isValidSVG(dataUrl)) {
      try {
        final base64Str = dataUrl.split('data:image/svg+xml;base64,')[1];
        return ClipOval(
          child: SvgPicture.string(
            utf8.decode(base64.decode(base64Str)),
            width: size,
            height: size,
          ),
        );
      } catch (_) {
        return _fallbackTokenCircle(size);
      }
    }
    // network image with gateway normalization + safe fallback
    final url = _normalizeIpfsUrl(dataUrl);
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackTokenCircle(size),
      ),
    );
  }

  Widget _fallbackTokenCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFECECF1),
      ),
      child: const Icon(Icons.image_not_supported, size: 16, color: Colors.grey),
    );
  }

  Widget getPoolCard(dynamic pool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: SizedBox(
                width: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    _tokenIcon(pool['iconUrl1']),
                    Positioned(left: 14, child: _tokenIcon(pool['iconUrl2'])),
                  ],
                ),
              ),
              title: Text('${pool['name1']} - ${pool['name2']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${pool['symbol1']}/${pool['symbol2']}'),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: '${pool['token1']}/\n${pool['token2']}',
                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.help_outline, size: 18.0, color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('TVL : ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    Text('\$${pool["tvl"]}', style: const TextStyle(fontSize: 12.0)),
                  ]),
                  Row(children: [
                    const Text('24h Vol. : ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    Text('\$ ${pool['volume24h']}', style: const TextStyle(fontSize: 12.0)),
                    Text(' ${pool['volumeChange24h']} %',
                        style:  TextStyle(
                            fontSize: 12.0, color: Styles.greenColor, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
            if (hasBalance(pool['token1']) || hasBalance(pool['token2']))
              Container(
                margin: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                decoration: BoxDecoration(
                  boxShadow:  [
                    BoxShadow(
                      color: Styles.secondaryAccentColorDark,
                      spreadRadius: -10,
                      offset: Offset(0, 5),
                      blurRadius: 20,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(80),
                  gradient:  LinearGradient(
                    colors: [Styles.purpleColorLight, Styles.secondaryAccentColorDark],
                    begin: Alignment(-1, -1),
                    end: Alignment(1, 1),
                  ),
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.repeat, color: Colors.white, size: 16.0),
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  label: const Text('Swap',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    ReefAppState.instance.navigationCtrl.navigateToSwapPage(
                      context: context,
                      preselectedTop: pool['token1'],
                      preselectedBottom: pool['token2'],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchAcknowledge() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (searchedPools == null)
            Text(
              "Search pools for $searchInput ...",
              style: const TextStyle(
                color: Styles.textLightColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
              ),
            )
          else if (searchedPools!.isEmpty)
            Row(
              children: const [
                Icon(Icons.error, size: 14.0, color: Styles.errorColor),
                Gap(4.0),
                Text(
                  "No pools found!",
                  style: TextStyle(
                    color: Styles.errorColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            Text(
              "Search Results for $searchInput ( ${searchedPools!.length} )",
              style: const TextStyle(
                color: Styles.textLightColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          GestureDetector(
            onTap: clearSearch,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Styles.buttonColor,
              ),
              child:  Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close, size: 12, color: Styles.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchContainer() {
    return Column(
      children: [
        const Gap(16),
        Row(
          children: [
            const Gap(4.0),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Styles.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x20000000), width: 1),
                ),
                child: TextField(
                  focusNode: _focusNodeSearch,
                  controller: _searchController,
                  decoration: const InputDecoration.collapsed(hintText: 'Search'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        const Gap(4.0),
        if (searched) buildSearchAcknowledge(),
        const Gap(4.0),
      ],
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
                // Header
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
                    const Row(children: [
                      // action icons (kept commented intentionally)
                    ]),
                  ],
                ),

                if (hasReef) ...[
                  const Gap(8.0),
                  buildSearchContainer(),
                  const Gap(8.0),
                ] else
                  Column(
                    children: const [
                      // Replace with your own “insufficient balance” widget if needed
                      Gap(16.0),
                    ],
                  ),

                // List area
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!isLoading &&
                          scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 24) {
                        _fetchTokensAndPools();
                      }
                      return false;
                    },
                    child: (searched && searchedPools != null)
                        ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: searchedPools!.length,
                      itemBuilder: (context, index) {
                        final pool = searchedPools![index];
                        if (hasReef) {
                          if (hasBalance(pool['token1']) ||
                              hasBalance(pool['token2'])) {
                            return getPoolCard(pool);
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        return getPoolCard(pool);
                      },
                    )
                        : (_pools.isNotEmpty)
                        ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _pools.length,
                      itemBuilder: (context, index) {
                        final pool = _pools[index];
                        if (hasReef) {
                          if (hasBalance(pool['token1']) ||
                              hasBalance(pool['token2'])) {
                            return getPoolCard(pool);
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        return getPoolCard(pool);
                      },
                    )
                        :  Center(
                      child: CircularProgressIndicator(color: Styles.primaryColor),
                    ),
                  ),
                ),

                if (isLoading && _pools.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isValidSVG(String? dataUrl) {
    return dataUrl != null && dataUrl.contains("data:image/svg+xml;base64,");
  }
}

