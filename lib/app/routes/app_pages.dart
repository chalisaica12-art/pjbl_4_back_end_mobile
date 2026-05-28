import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/login/forgot_password_binding.dart';
import '../modules/login/forgot_password_view.dart';
import '../modules/register/register_binding.dart';
import '../modules/register/register_step1_view.dart';
import '../modules/register/register_step2_view.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';
import '../modules/quiz_detail/views/quiz_detail_view.dart';
import '../modules/quiz_detail/bindings/quiz_detail_binding.dart';
import '../modules/splash_loading/bindings/splash_loading_binding.dart';
import '../modules/splash_loading/views/splash_loading_view.dart';
import '../modules/score/views/score_view.dart';
import '../modules/quiz/views/quiz_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';


part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterStep1View(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER_STEP2,
      page: () => const RegisterStep2View(),
      // binding dihapus agar controller tidak di-dispose saat pindah halaman
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LEADERBOARD,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: '/quiz-detail',
      page: () => const QuizDetailView(),
      binding: QuizDetailBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_LOADING,
      page: () => const SplashLoadingView(),
      binding: SplashLoadingBinding(),
    ),
    GetPage(
      name: '/score',
      page: () => const ScoreView(),
    ),
    GetPage(
      name: '/quiz',
      page: () => const QuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
  ];
}