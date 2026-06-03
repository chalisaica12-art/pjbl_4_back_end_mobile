import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var topThree = <Map<String, dynamic>>[].obs;
  var otherRanks = <Map<String, dynamic>>[].obs;
  var currentUserRank = 0.obs;
  var currentUserScore = 0.obs;
  var currentUserName = ''.obs;
  var currentUserAvatar = ''.obs;

  // Realtime
  RealtimeChannel? _profilesChannel;
  RealtimeChannel? _avatarsChannel;

  String? get currentUserId => supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
    supabase.auth.onAuthStateChange.listen((_) => fetchLeaderboard());
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    // ✅ Realtime profiles - kalau stars berubah, leaderboard langsung update
    _profilesChannel = supabase
        .channel('leaderboard_profiles')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (_) => fetchLeaderboard(),
        )
        .subscribe();

    // ✅ Realtime avatars - kalau user ganti avatar
    _avatarsChannel = supabase
        .channel('leaderboard_avatars')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'avatars',
          callback: (_) => fetchLeaderboard(),
        )
        .subscribe();
  }

  Future<void> fetchLeaderboard() async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('profiles')
          .select('id, name, username, stars, active_avatar_id')
          .order('stars', ascending: false);

      final allUsers = List<Map<String, dynamic>>.from(response);
      List<Map<String, dynamic>> rankedUsers = [];

      for (var i = 0; i < allUsers.length; i++) {
        final user = allUsers[i];

        String displayName = 'Player';
        final name = user['name'];
        final username = user['username'];
        if (name != null && name.toString().trim().isNotEmpty && name.toString().trim() != '-') {
          displayName = name.toString().trim();
        } else if (username != null && username.toString().trim().isNotEmpty && username.toString().trim() != '-') {
          displayName = username.toString().trim();
        }

        String avatarPath = '';
        final avatarId = user['active_avatar_id'];
        if (avatarId != null && avatarId != 0) {
          try {
            final avatarData = await supabase
                .from('avatars')
                .select('image_path')
                .eq('id', avatarId)
                .maybeSingle();
            avatarPath = avatarData?['image_path'] ?? '';
          } catch (e) {
            avatarPath = '';
          }
        }

        rankedUsers.add({
          'rank': i + 1,
          'name': displayName,
          'score': user['stars'] ?? 0,
          'id': user['id'],
          'active_avatar_id': avatarId,
          'avatar_path': avatarPath,
        });
      }

      topThree.value = rankedUsers.take(3).toList();
      otherRanks.value = rankedUsers.skip(3).toList();

      if (currentUserId != null) {
        final userEntry = rankedUsers.firstWhereOrNull((u) => u['id'] == currentUserId);
        if (userEntry != null) {
          currentUserRank.value = userEntry['rank'] ?? 0;
          currentUserScore.value = userEntry['score'] ?? 0;
          currentUserName.value = userEntry['name'] ?? 'Kamu';
          currentUserAvatar.value = userEntry['avatar_path'] ?? '';
        }
      } else {
        currentUserRank.value = 0;
        currentUserScore.value = 0;
        currentUserName.value = '';
        currentUserAvatar.value = '';
      }
    } catch (e) {
      print('Error fetch leaderboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _profilesChannel?.unsubscribe();
    _avatarsChannel?.unsubscribe();
    super.onClose();
  }
}