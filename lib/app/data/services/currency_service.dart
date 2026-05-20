import 'dart:convert';
import 'package:http/http.dart' as http;
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
    // Rate cadangan jika aplikasi pertama kali dibuka dan tidak ada internet
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


  Future<void> fetchAndSaveLatestRates() async {
    try {
      // Karena storage kita base-nya IDR, kita tembak endpoint idr.json
      // API ini akan mereturn nilai "1 IDR = berapa USD/EUR/dll"
      final url = Uri.parse('https://latest.currency-api.pages.dev/v1/currencies/idr.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> idrRates = data['idr'];

        // Daftar mata uang yang kita dukung di aplikasi
        final targetCurrencies = ['idr', 'usd', 'eur', 'jpy', 'gbp', 'sgd'];
        final updatedRates = <String, double>{};

        for (String curr in targetCurrencies) {
          if (idrRates.containsKey(curr)) {
            // Ubah key jadi UPPERCASE agar cocok dengan standar aplikasi
            updatedRates[curr.toUpperCase()] = (idrRates[curr] as num).toDouble();
          }
        }

        if (updatedRates.isNotEmpty) {
          // Timpa data lama di Hive dengan data API terbaru
          await setRatesAgainstIdr(updatedRates);
          print("✅ Berhasil update API kurs mata uang ke Hive!");
        }
      } else {
        print("⚠️ Gagal tarik API kurs. HTTP Status: ${response.statusCode}");
      }
    } catch (e) {
      // Jika HP tidak ada koneksi internet, biarkan gagal diam-diam.
      // Aplikasi akan otomatis fallback memakai rates yang sudah tersimpan di Hive.
      print("❌ Error API Kurs: $e. Menggunakan cache Hive/Default.");
    }
  }
  // ====================================================================

  /// Konversi IDR (storage) menjadi nominal sesuai currency user (display).
  double convertFromIdr(double idrAmount) {
    final rates = ratesAgainstIdr;
    final rate = rates[code] ?? 1.0;
    return idrAmount * rate;
  }

  /// Format untuk DISPLAY: konversi dari IDR -> currency terpilih, lalu format.
  String formatFromIdr(double idrAmount, {int decimalDigits = 2}) {
    final converted = convertFromIdr(idrAmount);
    return formatter(decimalDigits: decimalDigits).format(converted);
  }

  /// Konversi dari nominal user (dalam mata uang terpilih) ke IDR untuk disimpan.
  double convertSelectedToIdr(double amountInSelected) {
    final rates = ratesAgainstIdr;
    final rate = rates[code] ?? 1.0;
    if (rate == 0) return amountInSelected;
    return amountInSelected / rate;
  }
}