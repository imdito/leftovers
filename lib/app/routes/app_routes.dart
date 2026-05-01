part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const AUTH_LOGIN = _Paths.AUTH + _Paths.LOGIN;
  static const AUTH_REGISTER = _Paths.AUTH + _Paths.REGISTER;
  static const INVENTORY = _Paths.INVENTORY;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTH = '/auth';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const AUTH_LOGIN = AUTH + LOGIN;
  static const AUTH_REGISTER = AUTH + REGISTER;
  static const INVENTORY = '/inventory';
}
