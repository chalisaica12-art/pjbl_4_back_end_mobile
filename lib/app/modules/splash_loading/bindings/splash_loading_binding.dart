import 'package:get/get.dart';
import '../controllers/splash_loading_controller.dart';

class SplashLoadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashLoadingController>(() => SplashLoadingController());
  }
}