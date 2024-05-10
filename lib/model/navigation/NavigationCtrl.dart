import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/home/tx_info.dart';
import 'package:reef_mobile_app/model/navigation/homepage_navigation_model.dart';
import 'package:reef_mobile_app/model/navigation/nav_swipe_compute.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/pages/send_nft.dart';
import 'package:reef_mobile_app/pages/send_page.dart';
import 'package:reef_mobile_app/pages/swap_page.dart';
import 'package:reef_mobile_app/pages/wallet_connect_page.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/sign/SignatureContentToggle.dart';

class NavigationCtrl with NavSwipeCompute {
  final NavigationModel _navigationModel;
  final HomePageNavigationModel _homePageNavigationModel;

  GlobalKey<LiquidCarouselState>? carouselKey;
  Future<bool>? _swipeComplete;
  bool _swiping = false;

  NavigationCtrl(this._navigationModel, this._homePageNavigationModel);

  void navigateHomePage(int index) => _homePageNavigationModel.navigate(index);

  void navigate(NavigationPage navigationPage) async {
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
    final i = computeSwipeAnimation(
        currentPage: _navigationModel.currentPage, page: navigationPage);

    if (i.abs() > 1) {
      HapticFeedback.selectionClick();
      _swipeComplete = _computeSwipeAnimation(
          currentPage: _navigationModel.currentPage, page: navigationPage);
    } else {
      _swipeComplete = _computeSwipeAnimation(
          currentPage: _navigationModel.currentPage, page: navigationPage);
      HapticFeedback.selectionClick();
      _navigationModel.navigate(navigationPage);
    }
  }

  void navigateToSendPage(
      {required BuildContext context,
      required String preselected,
      String? preSelectedTransferAddress}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignatureContentToggle(Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.send_tokens,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      color: Styles.whiteColor,
                    )),
                backgroundColor: Colors.deepPurple.shade700,
              ),
              body: SendPage(
                  preselected,
                  preSelectedTransferAddress: preSelectedTransferAddress,
                ),
               backgroundColor: Styles.greyColor,
              ),
             )));
  }


  void navigateToSendNFTPage(
      {required BuildContext context,
      required String nftUrl,
      required String name,
      required int balance,
      required String nftId,
      required String mimetype}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignatureContentToggle(Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.send_nft,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      color: Styles.whiteColor
                    )),
                backgroundColor: Colors.deepPurple.shade700,
              ),
              backgroundColor: Styles.greyColor,
              body: 
              // Padding(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              //     child: 
                  SendNFT(nftUrl, name, balance, nftId, mimetype)
                  ),
            // )
            )
            ));
  }
  void navigateToTxInfo(
      {required BuildContext context,
      required String unparsedTimestamp,
      required String? imageUrl,
      required String? iconUrl,
      required String? mimetype}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignatureContentToggle(Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.transaction_info,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      color: Styles.whiteColor
                    )),
                backgroundColor: Colors.deepPurple.shade700,
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: TxInfo(unparsedTimestamp, imageUrl, iconUrl, mimetype),
              ),
              backgroundColor: Styles.greyColor,
            ))));
  }

  void navigateToSwapPage(
      {required BuildContext context, required String preselected}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignatureContentToggle(Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.swap_tokens),
                backgroundColor: Colors.deepPurple.shade700,
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: SwapPage(preselected),
              ),
              backgroundColor: Styles.greyColor,
            ))));
  }

  void navigateToWalletConnectPage(
      {required BuildContext context}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignatureContentToggle(Scaffold(
              appBar: AppBar(
                title: Text("WalletConnect",style: TextStyle(color: Styles.whiteColor),),
                backgroundColor: Colors.deepPurple.shade700,
              ),
              body: const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: WalletConnectPage(),
              ),
              backgroundColor: Styles.greyColor,
            ))));
  }

  // void navigateToPage({required BuildContext context, required Widget child}) {
  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => child));
  // }

  Future<bool> _computeSwipeAnimation(
      {required NavigationPage currentPage,
      required NavigationPage page}) async {
    if (currentPage == NavigationPage.home && page == NavigationPage.settings) {
      // return await carouselKey!.currentState!.swipeXNext(x: 2);
      await carouselKey!.currentState!.swipeXNext(x: 2);
      await carouselKey!.currentState!.swipeXNext(x: 2);
      return true;
    } else if ((currentPage == NavigationPage.accounts &&
            page == NavigationPage.home) ||
        (currentPage == NavigationPage.settings &&
            page == NavigationPage.accounts)) {
      return await carouselKey!.currentState!.swipeXPrevious();
    } else if (currentPage == NavigationPage.settings &&
        page == NavigationPage.home) {
      // return await carouselKey!.currentState!.swipeXPrevious(x: 2);
      await carouselKey!.currentState!.swipeXPrevious(x: 2);
      await carouselKey!.currentState!.swipeXPrevious(x: 2);
      return true;
    } else if ((currentPage == NavigationPage.home &&
            page == NavigationPage.accounts) ||
        (currentPage == NavigationPage.accounts &&
            page == NavigationPage.settings)) {
      return await carouselKey!.currentState!.swipeXNext();
    }
    return false;
  }
}
