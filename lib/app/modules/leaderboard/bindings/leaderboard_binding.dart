import 'package:get/get.dart';
import '../controllers/leaderboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Pastikan ProfileController ada sebelum leaderboard dibuka
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    Get.lazyPut<LeaderboardController>(() => LeaderboardController());
  }
}