import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({required this.url, required this.title});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title,
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: Styles.whiteColor)),
          backgroundColor: Colors.deepPurple.shade700,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {},
                onPageStarted: (String url) {},
                onPageFinished: (String url) {},
                onHttpError: (HttpResponseError error) {},
                onWebResourceError: (WebResourceError error) {},
              ),
            )
            ..loadRequest(Uri.parse(widget.url)),
        ));
  }
}