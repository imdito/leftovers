part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const AUTH_LOGIN = _Paths.AUTH + _Paths.LOGIN;
  static const AUTH_REGISTER = _Paths.AUTH + _Paths.REGISTER;
  static const INVENTORY = _Paths.INVENTORY;
  static const INVENTORY_DETAIL = _Paths.INVENTORY + _Paths.DETAIL;
  static const PROFILE = _Paths.PROFILE;
  static const SCAN = _Paths.SCAN;
  static const LOCATION = _Paths.LOCATION;
  static const RECIPE = _Paths.RECIPE;
  static const RECIPE_DETAIL = _Paths.RECIPE + _Paths.DETAIL;
  static const KESAN_PESAN = _Paths.KESAN_PESAN;
  static const ANGGOTA_KELOMPOK = _Paths.ANGGOTA_KELOMPOK;
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
  static const DETAIL = '/detail';
  static const PROFILE = '/profile';
  static const SCAN = '/scan';
  static const LOCATION = '/location';
  static const RECIPE = '/recipe';
  static const KESAN_PESAN = '/kesan-pesan';
  static const ANGGOTA_KELOMPOK = '/anggota';
}
