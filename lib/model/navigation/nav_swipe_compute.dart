import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/components/page_layout.dart';

mixin NavSwipeCompute {
  int computeSwipeAnimation(
      {required NavigationPage currentPage, required NavigationPage page}) {
    var currIndex = bottomNavigationBarItems.indexWhere((itm){return itm.page==currentPage;});
    var targetIndex = bottomNavigationBarItems.indexWhere((itm){return itm.page==page;});
    var diff = targetIndex - currIndex;
    return diff+1;

    if (currentPage == NavigationPage.home && page == NavigationPage.settings) {
      return 3;
    } else if ((currentPage == NavigationPage.pools &&
            page == NavigationPage.home) ||
        (currentPage == NavigationPage.settings &&
            page == NavigationPage.accounts)) {
      return -1;
    } else if ((currentPage == NavigationPage.accounts &&
            page == NavigationPage.home) ||
        (currentPage == NavigationPage.settings &&
            page == NavigationPage.accounts)) {
      return -1;
    } else if (currentPage == NavigationPage.settings &&
        page == NavigationPage.home) {
      return -3;
    } else if ((currentPage == NavigationPage.home &&
            page == NavigationPage.accounts) ||
        (currentPage == NavigationPage.accounts &&
            page == NavigationPage.settings)) {
      return 1;
    }
    return 0;
  }
}
