part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const REGISTER = _Paths.REGISTER;
  static const REGISTER_STEP2 = _Paths.REGISTER_STEP2;
  static const HOME = _Paths.HOME;
  static const LEADERBOARD = _Paths.LEADERBOARD;
  static const QUIZ_DETAIL = _Paths.QUIZ_DETAIL;
  static const SPLASH_LOADING = _Paths.SPLASH_LOADING;
  static const QUIZ = _Paths.QUIZ;
  static const SCORE = _Paths.SCORE;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;  // <-- TAMBAHKAN INI
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const REGISTER = '/register';
  static const REGISTER_STEP2 = '/register-step2';
  static const HOME = '/home';
  static const LEADERBOARD = '/leaderboard';
  static const QUIZ_DETAIL = '/quiz-detail';
  static const SPLASH_LOADING = '/splash-loading';
  static const QUIZ = '/quiz';
  static const SCORE = '/score';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit-profile';  // <-- TAMBAHKAN INI
}