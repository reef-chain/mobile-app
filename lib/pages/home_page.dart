import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reef_chain_flutter/network/ws-conn-state.dart';
import 'package:reef_mobile_app/components/CreateAccount.dart';
import 'package:reef_mobile_app/components/home/NFT_view.dart';
import 'package:reef_mobile_app/components/home/token_view.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/components/sign/SignatureContentToggle.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../components/BlurableContent.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WsConnState? providerConn;
  WsConnState? gqlConn;
  StreamSubscription? providerConnStateSubs;

  @override
  void initState() {
    super.initState();

    try {
      providerConnStateSubs = ReefAppState.instance.networkCtrl
          .getProviderConnLogs()
          .listen(
            (event) {
          if (!mounted) return;
          setState(() {
            providerConn = event;
            debugPrint('providerConn event  ----> ${event?.isConnected}');
          });
        },
        onError: (e, st) {
          debugPrint('providerConn listen error ----> $e');
          if (!mounted) return;
          setState(() {
            providerConn = null;
          });
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('providerConn subscribe error ----> $e');
    }
  }

  @override
  void dispose() {
    try {
      providerConnStateSubs?.cancel();
    } catch (_) {}
    super.dispose();
  }

  // Tabs for Tokens / NFTs (same as your earlier map)
  final List<Map<String, dynamic>> _viewsMap = const [
    {"key": 0, "name": "Tokens", "component": TokenView()},
    {"key": 1, "name": "NFTs", "component": NFTView()},
  ];

  Widget _rowMember(Map member) {
    return InkWell(
      onTap: member['function'] ??
              () {
            HapticFeedback.selectionClick();
            ReefAppState.instance.navigationCtrl
                .navigateHomePage(member["key"] as int);
          },
      child: Observer(builder: (_) {
        final index =
            ReefAppState.instance.model.homeNavigationModel.currentIndex;
        final bool isActive = member["key"] == index;

        Color color = isActive ? Styles.whiteColor : Styles.primaryBackgroundColor;
        List<BoxShadow> boxShadow =
        isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2.5))] : [];
        double opacity = isActive ? 1.0 : 0.5;

        TextStyle textStyle = const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Styles.textColor,
        );

        // Special "Reload" tile (member["key"] == null)
        if (member["key"] == null) {
          color = Styles.purpleColor;
          boxShadow = [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2.5),
            )
          ];
          opacity = 1.0;
          textStyle = textStyle.copyWith(color: Styles.whiteColor);
        }

        return AnimatedContainer(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: color,
            boxShadow: boxShadow,
          ),
          duration: const Duration(milliseconds: 200),
          child: Opacity(
            opacity: opacity,
            child: Row(
              children: [
                if (member["icon"] != null) ...[
                  Icon(member["icon"], color: Styles.textLightColor),
                  const Gap(4),
                ],
                Text(
                  member["name"] == "Reload"
                      ? "Reload"
                      : member["name"] == "Tokens"
                      ? AppLocalizations.of(context)!.tokens
                      : AppLocalizations.of(context)!.nfts,
                  style: textStyle,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _navSection() {
    final shouldShowReload =
        (gqlConn?.isConnected != true) || (providerConn?.isConnected != true);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Styles.primaryBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: const HSLColor.fromAHSL(1, 256.36, 0.379, 0.843).toColor(),
            offset: const Offset(10, 10),
            blurRadius: 20,
            spreadRadius: -5,
          ),
          BoxShadow(
            color: const HSLColor.fromAHSL(1, 256.36, 0.379, 1).toColor(),
            offset: const Offset(-10, -10),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (shouldShowReload)
              _rowMember({
                "key": null,
                "name": "Reload",
                "component": null,
                "icon": Icons.refresh,
                "function": () => ReefAppState.instance.tokensCtrl.reload(true),
              }),
            ..._viewsMap.map<Widget>((e) => _rowMember(e)),
          ],
        ),
      ),
    );
  }

  void _showCreateAccountModal(BuildContext context, {bool fromMnemonic = false}) {
    showModal(
      context,
      headText: fromMnemonic ? "Import Account" : "Create Account",
      dismissible: true,
      child: CurrentScreen(fromMnemonic: fromMnemonic),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return SignatureContentToggle(
      Container(
        color: Styles.primaryBackgroundColor,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            slivers: [
              SliverPersistentHeader(delegate: BalanceHeaderDelegate()),
              SliverPinnedHeader(child: _navSection()),
              Observer(builder: (_) {
                final accsFeedbackDataModel =
                    ReefAppState.instance.model.accounts.accountsFDM;
                if (accsFeedbackDataModel.data.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    sliver: SliverToBoxAdapter(child: CreateAccountBox()),
                  );
                }

                final index =
                    ReefAppState.instance.model.homeNavigationModel.currentIndex;
                return SliverClip(child: _viewsMap[index]["component"]);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// Optimized balance header
/// - Avoids recomputing balance on eye toggle
/// - Clean opacity clamp
///
class BalanceHeaderDelegate extends SliverPersistentHeaderDelegate {
  BalanceHeaderDelegate();

  static final NumberFormat _fmtCompact = NumberFormat.compact();

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Opacity(
      opacity: _clamp01(((shrinkOffset - maxExtent) / maxExtent).abs()),
      child: _balanceSection(context),
    );
  }

  Widget _balanceSection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCirc,
      width: 30,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (ctx) => Text(
                      AppLocalizations.of(ctx)!.balance,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Styles.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ReefAppState.instance.appConfigCtrl.toggleDisplayBalance();
                      HapticFeedback.selectionClick();
                    },
                    icon: Observer(
                      builder: (_) => Icon(
                        ReefAppState.instance.model.appConfig.displayBalance == true
                            ? Icons.remove_red_eye_sharp
                            : Icons.visibility_off,
                      ),
                    ),
                    color: Styles.textLightColor,
                  ),
                ],
              ),

              // 1) Total (depends on tokens only)
              // 2) BlurableContent (depends on displayBalance only)
              Observer(
                builder: (_) {
                  final tokens =
                      ReefAppState.instance.model.tokens.selectedErc20List;
                  final total = _sumTokenBalances(tokens);
                  final totalStr = _fmtCompact.format(total);

                  final totalWidget = GradientText(
                    "\$$totalStr",
                    gradient: textGradient(),
                    style: GoogleFonts.poppins(
                      color: Styles.textColor,
                      fontSize: 68,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  );

                  final show =
                      ReefAppState.instance.model.appConfig.displayBalance;
                  return BlurableContent(totalWidget, show);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _sumTokenBalances(List<TokenWithAmount> list) {
    var sum = 0.0;
    for (final token in list) {
      final balValue = getBalanceValueBI(token.balance, token.price);
      if (balValue > 0) sum += balValue;
    }
    return sum;
  }

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
}

