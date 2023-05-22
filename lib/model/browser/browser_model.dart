import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'browser_model.g.dart';

class BrowserModel = _BrowserModel with _$BrowserModel;

abstract class _BrowserModel with Store {
  final dAppRequestService = const DAppRequestService();

  @observable
  List<TabData> tabs = [];
  bool refreshTrigger = false;

  @action
  void addWebView(
      {required String url,
      required String tabHash,
      required Widget webView,
      required JsApiService? jsApiService,
      required WebViewController? webViewController}) {
    final tabData = TabData(
        firstBuild: true,
        tabHash: tabHash,
        currentUrl: url,
        webView: webView,
        jsApiService: jsApiService,
        webViewController: webViewController);
    tabs = [...tabs, tabData];
  }

  @action
  void updateWebViewUrl({required String tabHash, required String newUrl}) {
    tabs = tabs.map((tabData) {
      if (tabData.tabHash == tabHash) {
        return TabData(
            firstBuild: tabData.firstBuild,
            tabHash: tabData.tabHash,
            currentUrl: newUrl,
            webView: tabData.webView,
            jsApiService: tabData.jsApiService,
            webViewController: tabData.webViewController);
      }
      return tabData;
    }).toList();
    refreshTrigger = !refreshTrigger;
  }

  @action
  void updateWebViewCtrl(
      {required String tabHash, required WebViewController webViewController}) {
    tabs = tabs
        .map((tabData) => tabData.tabHash == tabHash
            ? TabData(
                firstBuild: tabData.firstBuild,
                tabHash: tabData.tabHash,
                currentUrl: tabData.currentUrl,
                webView: tabData.webView,
                jsApiService: tabData.jsApiService,
                webViewController: webViewController)
            : tabData)
        .toList();
    refreshTrigger = !refreshTrigger;
  }

  @action
  void updateWebView(
      {required String tabHash,
      required String newUrl,
      required JsApiService? jsApiService,
      required Widget webView}) {
    tabs = tabs
        .map((tabData) => tabData.tabHash == tabHash
            ? TabData(
                firstBuild: tabData.firstBuild,
                tabHash: tabData.tabHash,
                currentUrl: newUrl,
                webView: webView,
                jsApiService: jsApiService,
                webViewController: tabData.webViewController)
            : tabData)
        .toList();
    refreshTrigger = !refreshTrigger;
  }

  @action
  void updateFirstBuild({required String tabHash}) {
    tabs = tabs
        .map((tabData) => tabData.tabHash == tabHash
            ? TabData(
                firstBuild: false,
                tabHash: tabData.tabHash,
                currentUrl: tabData.currentUrl,
                webView: tabData.webView,
                jsApiService: tabData.jsApiService,
                webViewController: tabData.webViewController)
            : tabData)
        .toList();
    refreshTrigger = !refreshTrigger;
  }

  @action
  void removeWebView({required String tabHash}) {
    tabs = tabs.where((tabData) => tabData.tabHash != tabHash).toList();
  }
}

class TabData {
  final String tabHash;
  bool firstBuild;
  String currentUrl;
  Widget webView;
  WebViewController? webViewController;
  JsApiService? jsApiService;

  TabData({
    required this.firstBuild,
    required this.tabHash,
    required this.currentUrl,
    required this.webView,
    required this.webViewController,
    this.jsApiService,
  });
}
