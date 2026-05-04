import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class CurrencyService {
  final Box _box;

  CurrencyService({Box? box}) : _box = box ?? Hive.box('gamificationBox');

  static const String kCurrencyCode = 'currencyCode';
  static const String kCurrencySymbol = 'currencySymbol';
  static const String kCurrencyLocale = 'currencyLocale';

  static const String kCurrencyRates = 'currencyRates';

  /// IMPORTANT CONTRACT:
  /// - Semua nilai yang disimpan di Hive (savedMoney, price, dll) dianggap dalam IDR.
  /// - Pengubahan mata uang hanya mengubah tampilan (display) lewat konversi.

  String get code => (_box.get(kCurrencyCode) as String?) ?? 'IDR';
  String get symbol => (_box.get(kCurrencySymbol) as String?) ?? 'Rp ';
  String get locale => (_box.get(kCurrencyLocale) as String?) ?? 'id';

  Future<void> setCurrency({
    required String code,
    required String symbol,
    required String locale,
  }) async {
    await _box.put(kCurrencyCode, code);
    await _box.put(kCurrencySymbol, symbol);
    await _box.put(kCurrencyLocale, locale);
  }

  NumberFormat formatter({int decimalDigits = 0}) {
    return NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
  }

  Map<String, double> _defaultRatesAgainstIdr() {
    // Rate sederhana (manual). Angka ini bisa kamu update kapan saja.
    // Nilai = 1 IDR sama dengan berapa unit currency tsb.
    return {
      'IDR': 1.0,
      'USD': 1.0 / 16000.0,
      'EUR': 1.0 / 17500.0,
      'JPY': 1.0 / 110.0,
      'GBP': 1.0 / 20500.0,
      'SGD': 1.0 / 11800.0,
    };
  }

  Map<String, double> get ratesAgainstIdr {
    final raw = _box.get(kCurrencyRates);
    if (raw is Map) {
      final map = <String, double>{};
      raw.forEach((key, value) {
        if (key is String) {
          final v = (value is num) ? value.toDouble() : double.tryParse(value.toString());
          if (v != null) map[key] = v;
        }
      });
      if (map.isNotEmpty) return map;
    }
    return _defaultRatesAgainstIdr();
  }

  Future<void> setRatesAgainstIdr(Map<String, double> rates) async {
    await _box.put(kCurrencyRates, rates);
  }

  /// Konversi IDR (storage) menjadi nominal sesuai currency user (display).
  double convertFromIdr(int idrAmount) {
    final rates = ratesAgainstIdr;
    final rate = rates[code] ?? 1.0;
    return idrAmount * rate;
  }

  /// Format untuk DISPLAY: konversi dari IDR -> currency terpilih, lalu format.
  String formatFromIdr(int idrAmount, {int decimalDigits = 0}) {
    final converted = convertFromIdr(idrAmount);
    return formatter(decimalDigits: decimalDigits).format(converted);
  }
}
