import 'package:get/get.dart';

class LeaderboardController extends GetxController {
  // Data leaderboard (sementara pake data statis)
  var leaderboardList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var currentUserRank = 0.obs;
  var currentUserScore = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  void fetchLeaderboard() {
    isLoading.value = true;
    
    // TODO: Nanti ganti dengan data dari Supabase
    // Sementara pake data statis dulu
    Future.delayed(const Duration(milliseconds: 500), () {
      leaderboardList.value = [
        {'rank': 1, 'name': 'Hanna', 'score': 1000, 'avatar': 'assets/gambar/avatar1.png', 'isCurrentUser': false},
        {'rank': 2, 'name': 'Budi', 'score': 850, 'avatar': 'assets/gambar/avatar2.png', 'isCurrentUser': false},
        {'rank': 3, 'name': 'Citra', 'score': 720, 'avatar': 'assets/gambar/avatar3.png', 'isCurrentUser': false},
        {'rank': 4, 'name': 'Dedi', 'score': 500, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
        {'rank': 5, 'name': 'Eva', 'score': 450, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
        {'rank': 6, 'name': 'Fajar', 'score': 380, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
        {'rank': 7, 'name': 'Gita', 'score': 320, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
        {'rank': 8, 'name': 'Hadi', 'score': 280, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
        {'rank': 9, 'name': 'Indah', 'score': 210, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
        {'rank': 10, 'name': 'Joko', 'score': 150, 'avatar': 'assets/gambar/profile.png', 'isCurrentUser': false},
      ];
      
      currentUserRank.value = 15;
      currentUserScore.value = 120;
      isLoading.value = false;
    });
  }

  // Nanti untuk ambil data dari Supabase
  // Future<void> fetchFromSupabase() async {
  //   final supabase = Supabase.instance.client;
  //   final response = await supabase
  //       .from('quiz_results')
  //       .select('''
  //         score,
  //         profiles!inner (name, avatar_url)
  //       ''')
  //       .order('score', ascending: false)
  //       .limit(10);
  //   leaderboardList.value = response;
  // }
}