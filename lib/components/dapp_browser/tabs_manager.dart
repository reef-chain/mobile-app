import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/dapp_browser/tabs_display.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class TabsManager extends StatefulWidget {
  const TabsManager({super.key});

  @override
  State<TabsManager> createState() => _TabsManagerState();
}

class _TabsManagerState extends State<TabsManager> {
  List<String> tabs = [];
  final dAppRequestService = const DAppRequestService();

  Future<String> _getHtml(String url) async {
    return http.read(Uri.parse(url));
  }

  NavigationDelegate _getNavigationDelegate(String tabHash) =>
      (navigation) async {
        if (navigation.isForMainFrame) {
          try {
            Uri.parse(navigation.url);
            final tabData = ReefAppState.instance.browserCtrl.browserModel.tabs
                .firstWhere((tab) => tab.tabHash == tabHash);
            print("=====================");
            print(navigation.url);
            print(tabData.currentUrl);
            print("=====================");
            if (navigation.url == tabData.currentUrl) {
              return NavigationDecision.navigate;
            }
            await setup(tabHash, navigation.url);
            // await tabData.jsApiService?.loadNewURLWithDappInjectedHtml(
            //     fJsFilePath: 'lib/js/packages/dApp-js/dist/index.js',
            //     htmlString: await _getHtml(navigation.url),
            //     baseUrl: navigation.url);
          } catch (e) {
            return NavigationDecision.navigate;
          }
        }
        return NavigationDecision.navigate;
      };

  Future<void> setup(String tabHash, [String? url]) async {
    final tabData = ReefAppState.instance.browserCtrl.browserModel.tabs
        .firstWhere((tab) => tab.tabHash == tabHash);

    final html = await _getHtml(url ?? tabData.currentUrl);

    final dappJsApi = JsApiService.dAppInjectedHtml(html,
        url ?? tabData.currentUrl, _getNavigationDelegate(tabData.tabHash));
    dappJsApi.jsDAppMsgSubj.listen((value) {
      dAppRequestService.handleDAppMsgRequest(
          value, dappJsApi.sendDappMsgResponse);
    });

    ReefAppState.instance.browserCtrl.updateWebView(
      newUrl: url ?? tabData.currentUrl,
      tabHash: tabData.tabHash,
      jsApiService: dappJsApi,
      webView: dappJsApi.widget,
    );

    setState(() {
      print("CALLED RIGHT THERE");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Flex(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          direction: Axis.horizontal,
          children: [
            TextButton(
                onPressed: () {
                  ReefAppState.instance.browserCtrl.closeAllTabs();
                },
                child: const Text(
                  "Close All",
                  style: TextStyle(color: Styles.primaryAccentColor),
                )),
            TextButton(
                onPressed: () {
                  ReefAppState.instance.browserCtrl.closeCurrentTab();
                },
                child: const Text(
                  "Done",
                  style: TextStyle(color: Styles.primaryAccentColor),
                ))
          ],
        )
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.primaryAccentColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final tabHash = getRandString(20);
          JsApiService? dappJsApi;
          final html = await _getHtml("https://reef.io/");

          dappJsApi = JsApiService.dAppInjectedHtml(
              html, "https://reef.io/", _getNavigationDelegate(tabHash));
          dappJsApi.jsDAppMsgSubj.listen((value) {
            dAppRequestService.handleDAppMsgRequest(
                value, dappJsApi!.sendDappMsgResponse);
          });

          ReefAppState.instance.browserCtrl.addWebView(
              url: "https://reef.io/",
              tabHash: tabHash,
              webView: dappJsApi.widget,
              jsApiService: dappJsApi,
              webViewController: null);
        },
      ),
      body: const Flex(
        direction: Axis.vertical,
        children: [
          Expanded(child: TabsDisplay()),
          Divider(
            height: 0.4,
            thickness: 0.4,
          ),
        ],
      ),
    );
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
