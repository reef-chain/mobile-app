import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/home/tx_info.dart';
import 'package:reef_mobile_app/model/navigation/homepage_navigation_model.dart';
import 'package:reef_mobile_app/model/navigation/nav_swipe_compute.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/pages/splash_screen.dart';
import 'package:reef_mobile_app/pages/pools_page.dart';
import 'package:reef_mobile_app/pages/send_nft.dart';
import 'package:reef_mobile_app/pages/send_page.dart';
import 'package:reef_mobile_app/pages/swap_page_anukul.dart';
import 'package:reef_mobile_app/pages/wallet_connect_page.dart';
import 'package:reef_mobile_app/pages/wallet_connect_tx_page.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';

import '../../components/sign/SignatureContentToggle.dart';

import 'dart:async';


class NavigationCtrl with NavSwipeCompute {
  final NavigationModel _navigationModel;
  final HomePageNavigationModel _homePageNavigationModel;

  GlobalKey<LiquidCarouselState>? carouselKey;
  Future<bool>? _swipeComplete;
  bool _swiping = false;

  NavigationCtrl(this._navigationModel, this._homePageNavigationModel);

  void navigateHomePage(int index) => _homePageNavigationModel.navigate(index);

  // ---------------------------------------------------------
  // SAFE CONTEXT HANDLING — prevents crash from null context
  // ---------------------------------------------------------
  BuildContext? _obtainContext(BuildContext? ctx) {
    if (ctx != null) return ctx;

    try {
      return navigatorKey.currentContext;
    } catch (_) {
      return null;
    }
  }

  bool get _isAppResumed {
    final binding = WidgetsBinding.instance;
    final state = binding.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  Future<void> _pushSafe({
    required WidgetBuilder builder,
    BuildContext? context,
    bool rootNavigator = false,
  }) async {
    final ctx = _obtainContext(context);

    if (ctx == null) {
      debugPrint("⚠️ Navigation canceled: context is null");
      return;
    }

    if (!_isAppResumed) {
      debugPrint("⚠️ Navigation canceled: app is not in foreground");
      return;
    }

    try {
      await Navigator.of(ctx, rootNavigator: rootNavigator).push(
        MaterialPageRoute(builder: builder),
      );
    } catch (e, st) {
      debugPrint("❌ Navigation error: $e\n$st");
    }
  }

  // ---------------------------------------------------------
  // PAGE SWIPING (unchanged but null-safe)
  // ---------------------------------------------------------
  Future<void> navigate(NavigationPage navigationPage) async {
    if (_swiping) return;

    if (_swipeComplete != null) {
      _swiping = true;
      await _swipeComplete;
      _swiping = false;
    }
    _swipeComplete = null;

    if (_navigationModel.currentPage == navigationPage) {
      _swiping = false;
      return;
    }

    final pageDiff = computeSwipeAnimation(
      currentPage: _navigationModel.currentPage,
      page: navigationPage,
    );

    if (pageDiff.abs() > 1) {
      HapticFeedback.selectionClick();
      _swipeComplete = _swipePageTo(nr: pageDiff);
    } else {
      _swipeComplete = _swipePageTo(nr: pageDiff);
      HapticFeedback.selectionClick();
      _navigationModel.navigate(navigationPage);
    }
  }

  Future<bool> _swipePageTo({required int nr}) async {
    final state = carouselKey?.currentState;
    if (state == null) return true;

    if (nr > 0) {
      for (var i = 0; i < nr; i++) {
        await state.swipeXNext(x: nr);
      }
    } else {
      for (var i = 0; i > nr; i--) {
        await state.swipeXPrevious(x: nr);
      }
    }
    return true;
  }

  // ---------------------------------------------------------
  // SAFE NAVIGATION ENDPOINTS (ALL FIXED)
  // ---------------------------------------------------------

  void navigateToSendPage({
    required BuildContext context,
    required String preselected,
    String? preSelectedTransferAddress,
  }) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(ctx)!.send_tokens,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Styles.whiteColor,
              ),
            ),
            backgroundColor: Colors.deepPurple.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SendPage(
            preselected,
            preSelectedTransferAddress: preSelectedTransferAddress,
          ),
          backgroundColor: Styles.greyColor,
        ),
      ),
    );
  }

  void navigateToSendNFTPage({
    required BuildContext context,
    required String nftUrl,
    required String name,
    required int balance,
    required String nftId,
    required String mimetype,
  }) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(ctx)!.send_nft,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Styles.whiteColor,
              ),
            ),
            backgroundColor: Colors.deepPurple.shade700,
          ),
          backgroundColor: Styles.greyColor,
          body: SendNFT(nftUrl, name, balance, nftId, mimetype),
        ),
      ),
    );
  }

  void navigateToTxInfo({
    required BuildContext context,
    required String unparsedTimestamp,
    required String? imageUrl,
    required String? iconUrl,
    required String? mimetype,
  }) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(ctx)!.transaction_info,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Styles.whiteColor,
              ),
            ),
            backgroundColor: Colors.deepPurple.shade700,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: TxInfo(unparsedTimestamp, imageUrl, iconUrl, mimetype),
          ),
          backgroundColor: Styles.greyColor,
        ),
      ),
    );
  }

  void navigateToSwapPage({
    required BuildContext context,
    String? preselectedTop,
    String? preselectedBottom,
  }) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(ctx)!.swap_tokens,
              style: TextStyle(color: Styles.whiteColor),
            ),
            backgroundColor: Colors.deepPurple.shade700,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SwapPage(
              preselectedTop: preselectedTop,
              preselectedBottom: preselectedBottom,
            ),
          ),
          backgroundColor: Styles.greyColor,
        ),
      ),
    );
  }

  /// ⭐ MOST IMPORTANT FIX: no force unwrap, no null crash
  void navigateToWalletConnectSignaturePage({BuildContext? context}) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title:  Text(
              "WalletConnect",
              style: TextStyle(color: Styles.whiteColor),
            ),
            backgroundColor: Colors.deepPurple.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                'assets/images/walletconnect.svg',
                height: 24,
                width: 24,
              ),
            ),
          ),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: WalletConnectTxPage(),
          ),
          backgroundColor: Styles.greyColor,
        ),
      ),
    );
  }

  void navigateToWalletConnectPage({required BuildContext context}) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title:  Text("WalletConnect",
                style: TextStyle(color: Styles.whiteColor)),
            backgroundColor: Colors.deepPurple.shade700,
          ),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: WalletConnectPage(),
          ),
          backgroundColor: Styles.greyColor,
        ),
      ),
    );
  }

  void navigateToPoolsPage({required BuildContext context}) {
    _pushSafe(
      context: context,
      builder: (ctx) => SignatureContentToggle(
        Scaffold(
          appBar: AppBar(
            title:  Text("Pools",
                style: TextStyle(color: Styles.whiteColor)),
            backgroundColor: Colors.deepPurple.shade700,
          ),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: PoolsPage(),
          ),
          backgroundColor: Styles.greyColor,
        ),
      ),
    );
  }
}
