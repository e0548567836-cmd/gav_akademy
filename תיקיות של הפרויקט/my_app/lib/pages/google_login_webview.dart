import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleLoginWebView extends StatefulWidget {
  const GoogleLoginWebView({super.key});

  @override
  State<GoogleLoginWebView> createState() => _GoogleLoginWebViewState();
}

class _GoogleLoginWebViewState extends State<GoogleLoginWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // כשגוגל מחזיר לנו את הנתונים
            if (request.url.contains('complete-profile') ||
                request.url.contains('studentId')) {
              Navigator.pop(context, request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('http://10.0.2.2:5022/api/Student/login-google'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('כניסה עם Google')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
