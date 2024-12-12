import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebViewFlutterJS extends StatefulWidget {
  final Completer<WebViewController> controller;
  final Completer<void> loaded;
  final Map<String, dynamic> jsChannels;
  final bool hidden;
  final dynamic getFlutterJsHeaderTags;

  WebViewFlutterJS({
    required this.hidden,
    required this.controller,
    required this.loaded,
    required this.jsChannels,
    required this.getFlutterJsHeaderTags,
    Key? key,
  }) : super(key: key);

  @override
  State<WebViewFlutterJS> createState() => _WebViewFlutterJSState();
}

class _WebViewFlutterJSState extends State<WebViewFlutterJS> {
  bool urlDisallowed = false;
  String url = '';
  bool isControllerInit = false;
  late WebViewController controller;

  _setAuthUrl(bool _urlDisallowed, String _url) {
    setState(() {
      urlDisallowed = _urlDisallowed;
      url = _url;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.getFlutterJsHeaderTags('lib/js/packages/reef-mobile-js/dist/index.js').then((val) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              print("Progress: $progress%");
            },
            onPageStarted: (String url) {
              print("Page started loading: $url");
            },
            onPageFinished: (String url) {
              print("Page finished loading: $url");
              setState(() {
                isControllerInit = true;
              });
            },
            onHttpError: (HttpResponseError error) {
              print("HTTP error: ${error}");
            },
            onWebResourceError: (WebResourceError error) {
              print("Web resource error: ${error.description}");
            },
          ),
        )
        ..addJavaScriptChannel(
          'reefMobileChannel',
          onMessageReceived: (message) {
            print("JavaScript message: ${message.message}");
          },
        )
        ..loadHtmlString("""
          <!DOCTYPE html>
          <html>
          <head>
            <title>Injected JS</title>
          </head>
          <body>
            <script type="text/javascript">
              $val
            </script>
          </body>
          </html>
        """);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.hidden,
      child: Column(children: [
        if (urlDisallowed)
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              color: Styles.primaryAccentColor,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  AppLocalizations.of(context)!.you_disabled_this_dapp_domain,
                  style: TextStyle(color: Colors.white),
                ),
                const Gap(4),
                TextButton(
                    onPressed: () async {
                      await ReefAppState.instance.storage
                          .saveAuthUrl(AuthUrl(url, true));
                      _setAuthUrl(false, url);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(55, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.enable,
                      style: TextStyle(
                          color: Styles.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    )),
              ])),
        Expanded(
          child: isControllerInit
              ? WebViewWidget(controller: controller)
              : const Center(child: CircularProgressIndicator()),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('WEBVIEW DISPOSED');
  }
}
