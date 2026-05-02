import 'dart:ui';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeController extends GetxController {
  late final WebViewController webViewController;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
    // Langsung muat URL sumber dari iframe kamu
      ..loadRequest(Uri.parse('https://zv1y2i8p.play.gamezop.com/g/H1be5Ef0Qp'));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }



  void increment() => count.value++;
}
