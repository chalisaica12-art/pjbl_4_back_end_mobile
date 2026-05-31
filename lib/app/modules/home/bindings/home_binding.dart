import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ ProfileController permanent = tidak di-dispose saat pindah halaman
    // Ini memastikan avatar & nama selalu sinkron di semua halaman
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    Get.lazyPut<HomeController>(() => HomeController());
  }
}