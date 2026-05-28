import 'package:get/get.dart';

class SplashLoadingController extends GetxController {
  var progress = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    startLoading();
  }
  
  void startLoading() async {
    // Animasi progress dari 0 ke 1 selama 3 detik
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      progress.value = i / 100;
    }
    
    // Tunggu 0.5 detik lalu navigasi
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigasi ke halaman quiz (ganti dengan tujuan yang sesuai)
    if (Get.isRegistered<SplashLoadingController>()) {
      Get.offAllNamed('/quiz'); // Ganti dengan route quiz yang sesuai
    }
  }
}