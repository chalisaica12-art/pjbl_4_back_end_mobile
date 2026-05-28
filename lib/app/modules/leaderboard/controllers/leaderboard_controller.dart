import 'package:get/get.dart';

class LeaderboardController extends GetxController {
  var isLoading = false.obs;
  var topThree = <Map<String, dynamic>>[].obs;
  var otherRanks = <Map<String, dynamic>>[].obs;
  var currentUserRank = 0.obs;
  var currentUserScore = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  void fetchLeaderboard() {
    isLoading.value = true;
    
    // Data sementara (nanti ganti dengan data dari Supabase)
    Future.delayed(const Duration(milliseconds: 500), () {
      topThree.value = [
        {'rank': 1, 'name': 'Hanna', 'score': 100, 'avatar': 'h'},
        {'rank': 2, 'name': 'Naura', 'score': 50, 'avatar': 'n'},
        {'rank': 3, 'name': 'Chalisa', 'score': 25, 'avatar': 'r'},
      ];
      
      otherRanks.value = [
        {'rank': 4, 'name': 'gfggd', 'score': 10},
        {'rank': 5, 'name': 'gddg', 'score': 10},
        {'rank': 6, 'name': 'gdfdfg', 'score': 10},
        {'rank': 7, 'name': 'dgffgf', 'score': 8},
        {'rank': 8, 'name': 'gfffr', 'score': 7},
        {'rank': 9, 'name': 'fgfgfd', 'score': 6},
      ];
      
      currentUserRank.value = 10;
      currentUserScore.value = 5;
      isLoading.value = false;
    });
  }
}