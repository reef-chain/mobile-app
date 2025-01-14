import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class JsApiService {
  static bool resolveBooleanValue(dynamic res) {
    return res == true ||
        res == 'true' ||
        res == 1 ||
        res == '1' ||
        res == '"true"';
  }

  final flutterJsFilePath;
  final LOG_STREAM_ID = '_console.log';
  final API_READY_STREAM_ID = '_windowApisReady';
  final TX_SIGNATURE_CONFIRMATION_STREAM_ID = '_txSignStreamId';
  final DAPP_MSG_CONFIRMATION_STREAM_ID = '_dAppMsgIdent';
  final TX_SIGN_CONFIRMATION_JS_FN_NAME = '_txSignConfirmationJsFnName';
  final DAPP_MSG_CONFIRMATION_JS_FN_NAME = '_dAppMsgConfirmationJsFnName';
  final REEF_MOBILE_CHANNEL_NAME = 'reefMobileChannel';
  final FLUTTER_SUBSCRIBE_METHOD_NAME = 'flutterSubscribe';

  late final WebViewController controller;

  final controllerInit = Completer<WebViewController>();
  final jsApiLoaded = Completer<WebViewController>();

  // when web page loads
  final jsApiReady = Completer<WebViewController>();

  final jsMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsTxSignatureConfirmationMessageSubj = BehaviorSubject<JsApiMessage>();
  final jsDAppMsgSubj = BehaviorSubject<JsApiMessage>();
  final jsMessageUnknownSubj = BehaviorSubject<JsApiMessage>();

  late Function()? onJsConnectionError;

  JsApiService._(String this.flutterJsFilePath,
      {String? url, String? html, Function()? onErrorCb}) {
    // #docregion platform_features
    var ctrl = _createController();
    // #enddocregion platform_features

    // print('JS API SERVICE CREATE $flutterJsFilePath');
    _renderWithFlutterJS(ctrl, flutterJsFilePath, html, url)
        .then((v) => debugPrint("WV controller set"));
    this.controller = ctrl;
    this.onJsConnectionError = onErrorCb;
  }

  JsApiService.customJsApi(String assetsJsPath,
      {String? host, Function()? onErrorCb})
      : this._(assetsJsPath, url: host, onErrorCb: onErrorCb);

  JsApiService.reefAppJsApi({Function()? onErrorCb})
      : this._('lib/js/packages/reef-mobile-js/dist/index.js',
            url: 'https://app.reef.io', onErrorCb: onErrorCb);

  JsApiService.dAppInjectedHtml(
      String html, String? baseUrl, Function()? onErrorCb)
      : this._('lib/js/packages/dApp-js/dist/index.js',
            html: html, url: baseUrl, onErrorCb: onErrorCb);

  WebViewController _createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    var controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            // openDialog(request);
            debugPrint("http auth req");
          },
        ),
      );

    controller.setOnConsoleMessage((JavaScriptConsoleMessage consoleMessage) {
      debugPrint(
          '== JS == ${consoleMessage.level.name}: ${consoleMessage.message}');
    });

    _getJavascriptChannels().forEach((jsChanParam) =>
        controller.addJavaScriptChannel(jsChanParam.name,
            onMessageReceived: jsChanParam.onMessageReceived));

    debugPrint("js controller set");

    return controller;
  }

  Future<void> _renderWithFlutterJS(WebViewController ctrl, String fJsFilePath,
      String? htmlString, String? baseUrl) async {
    htmlString ??= "<html><head></head><body></body></html>";
    var headerTags = await _getFlutterJsHeaderTags(fJsFilePath);
    htmlString = _insertHeaderTags(htmlString, headerTags);
    _renderHtml(ctrl, htmlString, baseUrl);
  }

  // for js methods with no return value
  Future<void> jsCallVoidReturn(String executeJs) {
    return controller.runJavaScript(executeJs);
  }

  Future<dynamic> jsCall<T>(String executeJs) async {
    try {
      dynamic res = await controller.runJavaScriptReturningResult(executeJs);
      return T == bool ? resolveBooleanValue(res) : res;
    } catch (e) {
      print('JS LOST ctrl ERROR=${e.toString()}');
      if (this.onJsConnectionError != null) {
        this.onJsConnectionError!();
      }
      throw e;
    }
    return null;
  }

  Future jsPromise<T>(String jsObsRefName) async {
    dynamic res = await jsObservable(jsObsRefName).first;
    return T == bool ? resolveBooleanValue(res) : res;
  }

  Stream jsObservable(String jsObsRefName) {
    String ident = Random().nextInt(9999999).toString();

    jsCall("window['$FLUTTER_SUBSCRIBE_METHOD_NAME']('$jsObsRefName','$ident')")
        .then((res) {
      var err = res.toString().indexOf('error');
      if (err > 0) {
        print("ERROR while calling JS ${jsObsRefName} ///// response=$err");
      }
    }).catchError((err) {
      print(
          "ERROR evaluating = $jsObsRefName ///// uncaught exception - ${err}");
    });

    // stream not emitting or if awaiting Future stuck if error in js - we'd need to async this method and return stream in then() fn above or close stream immediately on error
    return jsMessageSubj.stream
        .where((event) => event.streamId == ident)
        .map((event) => event.value);
  }

  void confirmTxSignature(String reqId, String? mnemonic) {
    jsCallVoidReturn(
        '${TX_SIGN_CONFIRMATION_JS_FN_NAME}("$reqId", "${mnemonic ?? ''}")');
  }

  void sendDappMsgResponse(String reqId, dynamic value) {
    jsCall('${DAPP_MSG_CONFIRMATION_JS_FN_NAME}(`$reqId`, `$value`)');
  }

  Future<String> _getFlutterJsHeaderTags(String assetsFilePath) async {
    var jsScript = await rootBundle.loadString(assetsFilePath, cache: true);
    return """
    <script>
    // polyfills
    window.global = window;
    </script>
    <script>${jsScript}</script>
    <script>window.flutterJS.init( 
    '$REEF_MOBILE_CHANNEL_NAME', 
    '$LOG_STREAM_ID', 
    '$FLUTTER_SUBSCRIBE_METHOD_NAME', 
    '$API_READY_STREAM_ID', 
    '$TX_SIGNATURE_CONFIRMATION_STREAM_ID', 
    '$TX_SIGN_CONFIRMATION_JS_FN_NAME',
    '$DAPP_MSG_CONFIRMATION_STREAM_ID', 
    '$DAPP_MSG_CONFIRMATION_JS_FN_NAME',
    )</script>
    """;
  }

  String _insertHeaderTags(String htmlString, String headerTags) {
    var insertAfterStr = '<head>';
    var insertAt = htmlString.indexOf(insertAfterStr) + insertAfterStr.length;
    if (insertAt == insertAfterStr.length) {
      print('ERROR inserting flutter JS script tags');
      return '';
    }
    return htmlString.substring(0, insertAt) +
        headerTags +
        htmlString.substring(insertAt);
  }

  void _renderHtml(
      WebViewController ctrl, String htmlString, String? baseUrl) async {
    if (Platform.isIOS &&
        Platform.operatingSystemVersion.indexOf("Version 16.0") >= 0) {
      ctrl
          .loadFlutterAsset("lib/js/packages/reef-mobile-js/dist/index.js")
          .then((value) => ctrl)
          .catchError((err) {
        debugPrint('Error loading HTML=$err');
      });
    } else {
      ctrl
          .loadHtmlString(htmlString, baseUrl: baseUrl)
          .then((value) => ctrl)
          .catchError((err) {
        debugPrint('Error loading HTML=$err');
      });
    }
  }

  Set<JsChannParam> _getJavascriptChannels() {
    return {
      JsChannParam(
        name: REEF_MOBILE_CHANNEL_NAME,
        onMessageReceived: (message) {
          JsApiMessage apiMsg =
              JsApiMessage.fromJson(jsonDecode(message.message));
          if (apiMsg.streamId == LOG_STREAM_ID) {
            print('$LOG_STREAM_ID= ${apiMsg.value}');
          } else if (apiMsg.streamId == API_READY_STREAM_ID) {
            jsApiLoaded.future.then((ctrl) => jsApiReady.complete(ctrl));
          } else if (apiMsg.streamId == TX_SIGNATURE_CONFIRMATION_STREAM_ID) {
            jsTxSignatureConfirmationMessageSubj.add(apiMsg);
          } else if (apiMsg.streamId == DAPP_MSG_CONFIRMATION_STREAM_ID) {
            jsDAppMsgSubj.add(apiMsg);
          } else if (int.tryParse(apiMsg.streamId) == null) {
            jsMessageUnknownSubj.add(apiMsg);
          } else {
            jsMessageSubj.add(apiMsg);
          }
        },
      ),
    };
  }

  void rejectTxSignature(String signatureIdent) {
    confirmTxSignature(signatureIdent, '_canceled');
  }
}

class JsChannParam {
  late String name;
  late void Function(JavaScriptMessage) onMessageReceived;

  JsChannParam({required this.name, required this.onMessageReceived});
}

class JsApiMessage {
  late String streamId;
  late String msgType;
  late String reqId;
  late dynamic value;
  late String? url;

  JsApiMessage(this.streamId, this.value, this.msgType, this.reqId, this.url);

  JsApiMessage.fromJson(Map<String, dynamic> json)
      : streamId = json['streamId'],
        reqId = json['reqId'],
        value = json['value'],
        url = json['url'],
        msgType = json['msgType'];
}
