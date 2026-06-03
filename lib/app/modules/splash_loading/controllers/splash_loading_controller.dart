import 'package:get/get.dart';

class SplashLoadingController extends GetxController {
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    startLoading();
  }

  void startLoading() async {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      progress.value = i / 100;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed('/quiz', arguments: args);
  }
}