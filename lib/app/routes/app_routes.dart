part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const REGISTER = _Paths.REGISTER;
  static const REGISTER_STEP2 = _Paths.REGISTER_STEP2;
  static const HOME = _Paths.HOME;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const REGISTER = '/register';
  static const REGISTER_STEP2 = '/register-step2';
  static const HOME = '/home';
}