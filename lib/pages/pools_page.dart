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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ========== CONSTANTS ==========

// Header / Titles
const double kHeaderFontSize = 32.0;

// Search & spacing
const double kSearchGap = 4.0;
const double kSearchGapLarge = 16.0;
const double kSearchFieldPaddingV = 14.0;
const double kSearchFieldRadius = 12.0;

// Pool card
const double kPoolMargin = 4.0;
const double kTokenOverlap = 14.0;
const double kPoolIconSize = 30.0;

// Fonts
const double kSubtitleFont = 12.0;
const double kSwapIconSize = 16.0;

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
  /// Triggered when search focus changes
  void _onFocusSearchChange() {}

  /// Checks if selected account has REEF balance
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

  /// Fetches tokens & pools with pagination
  Future<void> _fetchTokensAndPools({bool initial = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final selectedTokens = ReefAppState.instance.model.tokens.selectedErc20List;
    for (final token in selectedTokens) {
      tokenBalances[token.address] = token.balance;
    }

    try {
      final pools = await ReefAppState.instance.poolsCtrl.getPools(offset, "");
      if (pools is List<dynamic>) {
        if (initial && _pools.isEmpty) {
          _pools = pools;
        } else {
          ReefAppState.instance.poolsCtrl.appendPools(pools);
          _pools = ReefAppState.instance.poolsCtrl.getCachedPools();
        }
        setState(() => offset += 10);
      }
    } catch (e) {
      debugPrint('getPools error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Clears search input and resets state
  void clearSearch() {
    setState(() {
      searchInput = "";
      _searchController.text = "";
      searched = false;
      searchedPools = null;
    });
    searchPools("");
  }

  /// Searches pools based on input value
  Future<void> searchPools(String val) async {
    try {
      final res = await ReefAppState.instance.poolsCtrl.getPools(0, val);
      if (!mounted) return;
      setState(() => searchedPools = res is List ? res : const []);
    } catch (e) {
      debugPrint('searchPools error: $e');
      if (!mounted) return;
      setState(() => searchedPools = const []);
    }
  }

  /// Checks if token has balance
  bool hasBalance(String addr) {
    return tokenBalances.containsKey(addr) &&
        (tokenBalances[addr] as BigInt) > BigInt.zero;
  }

  // ========== UI HELPERS ==========

  String _normalizeIpfsUrl(String url) {
    if (url.startsWith('https://cloudflare-ipfs.com/ipfs/')) {
      return url.replaceFirst(
          'https://cloudflare-ipfs.com/ipfs/', 'https://ipfs.io/ipfs/');
    }
    return url;
  }

  Widget _tokenIcon(String? dataUrl, {double size = kPoolIconSize}) {
    if (dataUrl == null || dataUrl.isEmpty) {
      return _fallbackTokenCircle(size);
    }
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

    final url = _normalizeIpfsUrl(dataUrl);
    return ClipOval(
      child: Image.network(
        cacheWidth: 600,

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
      child: Icon(Icons.image_not_supported,
          size: kSubtitleFont, color: Colors.grey),
    );
  }

  Widget getPoolCard(dynamic pool) {
    return Container(
      margin: const EdgeInsets.only(bottom: kPoolMargin),
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
                    Positioned(
                        left: kTokenOverlap,
                        child: _tokenIcon(pool['iconUrl2'])),
                  ],
                ),
              ),
              title: Text('${pool['name1']} - ${pool['name2']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${pool['symbol1']}/${pool['symbol2']}'),
                  const SizedBox(width: kSearchGap),
                  Tooltip(
                    message: '${pool['token1']}/\n${pool['token2']}',
                    textStyle:
                    const TextStyle(fontSize: kSubtitleFont, color: Colors.white),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.help_outline,
                        size: 18.0, color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('TVL : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: kSubtitleFont)),
                    Text('\$${pool["tvl"]}',
                        style: const TextStyle(fontSize: kSubtitleFont)),
                  ]),
                  Row(children: [
                    const Text('24h Vol. : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: kSubtitleFont)),
                    Text('\$ ${pool['volume24h']}',
                        style: const TextStyle(fontSize: kSubtitleFont)),
                    Text(' ${pool['volumeChange24h']} %',
                        style: TextStyle(
                            fontSize: kSubtitleFont,
                            color: Styles.greenColor,
                            fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),

            // Swap button when user has balance
            if (hasBalance(pool['token1']) || hasBalance(pool['token2']))
              Container(
                margin: const EdgeInsets.only(
                    top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Styles.secondaryAccentColorDark,
                      spreadRadius: -10,
                      offset: const Offset(0, 5),
                      blurRadius: 20,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(80),
                  gradient: LinearGradient(
                    colors: [Styles.purpleColorLight, Styles.secondaryAccentColorDark],
                    begin: const Alignment(-1, -1),
                    end: const Alignment(1, 1),
                  ),
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.repeat,
                      color: Colors.white, size: kSwapIconSize),
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  label: const Text('Swap',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
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
      margin: const EdgeInsets.only(top: kSearchGap),
      padding: const EdgeInsets.all(kSearchGap + 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (searchedPools == null)
            Text(
              "Search pools for $searchInput ...",
              style: const TextStyle(
                  color: Styles.textLightColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800),
            )
          else if (searchedPools!.isEmpty)
            const Row(
              children: [
                Icon(Icons.error, size: 14.0, color: Styles.errorColor),
                Gap(kSearchGap),
                Text(
                  "No pools found!",
                  style: TextStyle(
                      color: Styles.errorColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ],
            )
          else
            Text(
              "Search Results for $searchInput ( ${searchedPools!.length} )",
              style: const TextStyle(
                  color: Styles.textLightColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800),
            ),

          GestureDetector(
            onTap: clearSearch,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Styles.buttonColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
        const Gap(kSearchGapLarge),
        Row(
          children: [
            const Gap(kSearchGap),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: kSearchFieldPaddingV),
                decoration: BoxDecoration(
                  color: Styles.whiteColor,
                  borderRadius: BorderRadius.circular(kSearchFieldRadius),
                  border: Border.all(color: const Color(0x20000000), width: 1),
                ),
                child: TextField(
                  focusNode: _focusNodeSearch,
                  controller: _searchController,
                  decoration:
                  const InputDecoration.collapsed(hintText: 'Search'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        const Gap(kSearchGap),
        if (searched) buildSearchAcknowledge(),
        const Gap(kSearchGap),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(
      Stack(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        fontSize: kHeaderFontSize,
                        color: Colors.grey.shade100,
                      ),
                    ),
                    const Row(children: []),
                  ],
                ),

                if (hasReef) ...[
                  const Gap(kSearchGapLarge),
                  buildSearchContainer(),
                  const Gap(kSearchGapLarge),
                ] else
                  const Column(
                    children: [
                      Gap(16.0),
                    ],
                  ),

                // List
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
                        : Center(
                      child: CircularProgressIndicator(
                          color: Styles.primaryColor),
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
    return dataUrl != null &&
        dataUrl.contains("data:image/svg+xml;base64,");
  }
}


