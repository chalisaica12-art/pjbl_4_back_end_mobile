import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/avatar_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../leaderboard/controllers/leaderboard_controller.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  String? get userId => supabase.auth.currentUser?.id;

  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var userLevel = 1.obs;
  var currentXP = 0.obs;
  var maxXP = 1000.obs;
  var levelTitle = "Pemula".obs;
  var userStars = 0.obs;
  var activeAvatarId = Rx<int?>(null);
  var unlockedAvatarIds = <int>[].obs;
  var avatars = <AvatarModel>[].obs;
  var isLoading = true.obs;

  // Realtime
  RealtimeChannel? _profileChannel;
  RealtimeChannel? _avatarsChannel;

  @override
  void onInit() {
    super.onInit();
    _loadAvatars();
    fetchProfile();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    // ✅ Realtime profile user
    if (userId != null) {
      _profileChannel = supabase
          .channel('profile_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: userId!,
            ),
            callback: (_) => fetchProfile(),
          )
          .subscribe();
    }

    // ✅ Realtime avatars - kalau admin tambah avatar baru
    _avatarsChannel = supabase
        .channel('profile_avatars')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'avatars',
          callback: (_) => _loadAvatars(),
        )
        .subscribe();
  }

  Future<void> fetchProfile() async {
    if (userId == null) return;
    try {
      isLoading.value = true;
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId!)
          .single();

      userName.value = response['name'] ?? '';
      userEmail.value = response['email'] ?? '';
      userPhone.value = response['phone'] ?? '';
      userLevel.value = response['level'] ?? 1;
      currentXP.value = response['xp'] ?? 0;
      userStars.value = response['stars'] ?? 0;
      activeAvatarId.value = response['active_avatar_id'] as int?;

      final unlockedList = response['unlocked_avatar_ids'];
      if (unlockedList != null) {
        unlockedAvatarIds.value = List<int>.from(unlockedList);
      } else {
        unlockedAvatarIds.value = [];
      }

      maxXP.value = 1000 + (userLevel.value - 1) * 500;
      levelTitle.value = _getLevelTitle(userLevel.value);

      await _loadAvatars();
    } catch (e) {
      print('Error fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getLevelTitle(int level) {
    if (level < 3) return 'Pemula';
    if (level < 6) return 'Penjelajah';
    if (level < 10) return 'Petualang';
    if (level < 15) return 'Ahli Sejarah';
    return 'History Master';
  }

  Future<void> _loadAvatars() async {
    try {
      final response = await supabase
          .from('avatars')
          .select()
          .order('price_stars', ascending: true);
      avatars.value = (response as List)
          .map((e) => AvatarModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error load avatars: $e');
    }
  }

  double get xpProgress {
    if (maxXP.value == 0) return 0.0;
    return currentXP.value / maxXP.value;
  }

  int get xpPercentage {
    if (maxXP.value == 0) return 0;
    return ((currentXP.value / maxXP.value) * 100).toInt();
  }

  String get activeAvatarImage {
    final avatarId = activeAvatarId.value;
    if (avatarId == null || avatarId == 0) return '';
    final avatar = avatars.firstWhereOrNull((a) => a.id == avatarId);
    return avatar?.imagePath ?? '';
  }

  String getAvatarName(int id) {
    final avatar = avatars.firstWhereOrNull((a) => a.id == id);
    return avatar?.name ?? "";
  }

  bool isAvatarUnlocked(int avatarId) => unlockedAvatarIds.contains(avatarId);
  bool isAvatarActive(int avatarId) => activeAvatarId.value == avatarId;

  Future<void> buyAvatar(AvatarModel avatar) async {
    if (userId == null) return;
    if (userStars.value >= avatar.priceStars && !isAvatarUnlocked(avatar.id)) {
      try {
        userStars.value -= avatar.priceStars;
        unlockedAvatarIds.add(avatar.id);
        await supabase.from('profiles').update({
          'stars': userStars.value,
          'unlocked_avatar_ids': unlockedAvatarIds.toList(),
        }).eq('id', userId!);
        Get.snackbar("Berhasil!", "Avatar ${avatar.name} terbuka!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar("Gagal", "Terjadi kesalahan",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Gagal", "Bintang tidak cukup!",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> useAvatar(int avatarId) async {
    if (userId == null) return;
    if (isAvatarUnlocked(avatarId)) {
      activeAvatarId.value = avatarId;
      await supabase.from('profiles')
          .update({'active_avatar_id': avatarId}).eq('id', userId!);

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchUserProfile();
      }
      if (Get.isRegistered<LeaderboardController>()) {
        Get.find<LeaderboardController>().fetchLeaderboard();
      }

      Get.back();
      Get.snackbar(
        "Sukses",
        "Avatar ${getAvatarName(avatarId)} aktif!",
        backgroundColor: const Color(0xFFFDE7E4),
        colorText: Colors.black,
      );
    }
  }

  Future<void> addXP(int amount) async {
    if (userId == null) return;
    currentXP.value += amount;
    if (currentXP.value >= maxXP.value) {
      userLevel.value++;
      currentXP.value = currentXP.value - maxXP.value;
      maxXP.value = 1000 + (userLevel.value - 1) * 500;
      userStars.value += 50;
      levelTitle.value = _getLevelTitle(userLevel.value);
      Get.snackbar("Level Up! 🎉", "Kamu naik ke Level ${userLevel.value}",
          backgroundColor: Colors.amber, colorText: Colors.black);
    }
    await supabase.from('profiles').update({
      'xp': currentXP.value,
      'level': userLevel.value,
      'stars': userStars.value,
    }).eq('id', userId!);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.delete<ProfileController>(force: true);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _profileChannel?.unsubscribe();
    _avatarsChannel?.unsubscribe();
    super.onClose();
  }
}