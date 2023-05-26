// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/dapp_browser/reef_search_delegate.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/service/DAppRequestService.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

const double _fabDimension = 56.0;

class BrowserTab extends StatefulWidget {
  final int index;

  const BrowserTab({super.key, required this.index});

  @override
  State<BrowserTab> createState() {
    return _BrowserTabState();
  }
}

class _BrowserTabState extends State<BrowserTab> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return _OpenContainerWrapper(
      index: widget.index,
      transitionType: _transitionType,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        final tabData =
            ReefAppState.instance.browserCtrl.browserModel.tabs[widget.index];
        if (tabData.firstBuild) {
          Future.delayed(const Duration(milliseconds: 100), () {
            openContainer();
          });
          ReefAppState.instance.browserCtrl
              .updateFirstBuild(tabHash: tabData.tabHash);
        }
        return _SmallerCard(
          index: widget.index,
          openContainer: openContainer,
          subtitle: "tab",
        );
      },
      onClosed: (data) {},
    );
  }
}

class _OpenContainerWrapper extends StatefulWidget {
  const _OpenContainerWrapper({
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
    required this.index,
  });

  final int index;
  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool?> onClosed;

  @override
  State<_OpenContainerWrapper> createState() => __OpenContainerWrapperState();
}

class __OpenContainerWrapperState extends State<_OpenContainerWrapper> {
  final dAppRequestService = const DAppRequestService();

  NavigationDelegate _getNavigationDelegate(String tabHash) =>
      (navigation) async {
        if (navigation.isForMainFrame) {
          try {
            Uri.parse(navigation.url);
            final tabData = ReefAppState
                .instance.browserCtrl.browserModel.tabs[widget.index];
            if (tabData.currentUrl == navigation.url) {
              return NavigationDecision.navigate;
            }
            await setup(navigation.url);
            // final tabData = ReefAppState
            //     .instance.browserCtrl.browserModel.tabs[widget.index];
            // await tabData.jsApiService!.loadNewURLWithDappInjectedHtml(
            //     fJsFilePath: 'lib/js/packages/dApp-js/dist/index.js',
            //     htmlString: await _getHtml(navigation.url),
            //     baseUrl: navigation.url);
          } catch (e) {
            return NavigationDecision.navigate;
          }
        }
        return NavigationDecision.navigate;
      };

  Future<String> _getHtml(String url) async {
    return http.read(Uri.parse(url));
  }

  Future<void> setup([String? url]) async {
    print("THIS ONE WAS CALLED");
    final tabData =
        ReefAppState.instance.browserCtrl.browserModel.tabs[widget.index];
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
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: widget.transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        final tabHash = ReefAppState
            .instance.browserCtrl.browserModel.tabs[widget.index].tabHash;
        ReefAppState.instance.browserCtrl
            .setCurrentTabHash(currentTabHash: tabHash);
        return _DetailsPage(index: widget.index);
      },
      onClosed: (data) async {
        setup();
      },
      tappable: false,
      closedBuilder: widget.closedBuilder,
    );
  }
}

class _SmallerCard extends StatelessWidget {
  const _SmallerCard({
    required this.openContainer,
    required this.subtitle,
    required this.index,
  });

  final int index;
  final VoidCallback openContainer;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    child: Text(
                  Uri.parse(ReefAppState.instance.browserCtrl.browserModel
                          .tabs[index].currentUrl)
                      .host,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                )),
                IconButton(
                    padding: const EdgeInsets.all(1),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final tabHash = ReefAppState.instance.browserCtrl
                          .browserModel.tabs[index].tabHash;
                      ReefAppState.instance.browserCtrl
                          .removeWebView(tabHash: tabHash);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                    ))
              ],
            ),
          ),
          Expanded(
            child: Container(
                color: Colors.grey.shade100,
                child: Center(child: Builder(builder: (context) {
                  return const Icon(
                    Icons.image,
                    size: 35,
                  );
                }))),
          ),
        ],
      ),
    );
  }
}

class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.height,
    this.child,
  });

  final VoidCallback? openContainer;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: InkWell(
        onTap: openContainer,
        child: child,
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  final int index;
  final controller = TextEditingController();
  final dAppRequestService = const DAppRequestService();

  _DetailsPage({this.includeMarkAsDoneButton = true, required this.index});

  final bool includeMarkAsDoneButton;

  NavigationDelegate _getNavigationDelegate(String tabHash) =>
      (navigation) async {
        if (navigation.isForMainFrame) {
          try {
            Uri.parse(navigation.url);
            final tabData =
                ReefAppState.instance.browserCtrl.browserModel.tabs[index];
            if (tabData.currentUrl == navigation.url) {
              return NavigationDecision.navigate;
            }
            await setup(navigation.url);
            // final tabData = ReefAppState
            //     .instance.browserCtrl.browserModel.tabs[widget.index];
            // await tabData.jsApiService!.loadNewURLWithDappInjectedHtml(
            //     fJsFilePath: 'lib/js/packages/dApp-js/dist/index.js',
            //     htmlString: await _getHtml(navigation.url),
            //     baseUrl: navigation.url);
          } catch (e) {
            return NavigationDecision.navigate;
          }
        }
        return NavigationDecision.navigate;
      };

  Future<String> _getHtml(String url) async {
    return http.read(Uri.parse(url));
  }

  Future<void> setup([String? url]) async {
    print("THIS ONE WAS CALLED");
    final tabData = ReefAppState.instance.browserCtrl.browserModel.tabs[index];
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

    print("THIS ONE WAS SUCCEED");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Flex(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          direction: Axis.horizontal,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)),
            IconButton(
                onPressed: () async {
                  await setup("https://reef.io");
                },
                icon: const Icon(Icons.home_filled)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.grid_view)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
          ],
        )
      ],
      appBar: AppBar(
        toolbarHeight: 75,
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
        title: Observer(builder: (_) {
          controller.text = Uri.parse(ReefAppState
                  .instance.browserCtrl.browserModel.tabs[index].currentUrl)
              .origin;
          return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                onTap: () async {
                  final result = await showSearch(
                      context: context, delegate: ReefSearchDelegate());
                  final uri = Uri.tryParse(result!);
                  if (uri != null) {
                    await setup(uri.toString());
                  }
                },
                readOnly: true,
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    prefixIcon: Uri.parse(ReefAppState.instance.browserCtrl
                                .browserModel.tabs[index].currentUrl)
                            .isScheme("HTTP")
                        ? const Icon(Icons.dangerous)
                        : const Icon(Icons.lock),
                    isDense: true,
                    border: OutlineInputBorder(
                        gapPadding: 0,
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.1)),
              ));
        }),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person),
            ),
          )
        ],
      ),
      body: Builder(builder: (context) {
        String currentURL = ReefAppState
            .instance.browserCtrl.browserModel.tabs[index].currentUrl;
        return Observer(builder: (context) {
          final actualURL = ReefAppState
              .instance.browserCtrl.browserModel.tabs[index].currentUrl;
          if (currentURL == actualURL) {
            return SizedBox(
                child: ReefAppState.instance.browserCtrl.browserModel
                    .tabs[index].jsApiService?.widget);
          }
          return FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 300)),
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.done
                    ? SizedBox(
                        child: ReefAppState.instance.browserCtrl.browserModel
                            .tabs[index].jsApiService?.widget)
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
          );
        });
      }),
    );
  }

  String getURL(String currentUrl) {
    final url = Uri.parse(currentUrl);
    final currentUri = Uri.https(url.authority, url.path);
    return currentUri.toString();
  }
}
