import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

enum PlaceCategory { supermarket, donation, warung }

class NearbyPlace {
  final String name;
  final String address;
  final LatLng position; // LatLng dari latlong2
  final double distanceKm;
  final PlaceCategory category;
  final String? phone;
  final String? openingHours;
  final String? placeId; // id dari database (bukan osmId)

  NearbyPlace({
    required this.name,
    required this.address,
    required this.position,
    required this.distanceKm,
    required this.category,
    this.phone,
    this.openingHours,
    this.placeId,
  });

  // Parse dari response JSON API kamu
  factory NearbyPlace.fromJson(Map<String, dynamic> json, PlaceCategory cat) {
    return NearbyPlace(
      name: json['name'] ?? 'Tanpa Nama',
      address: json['address'] ?? 'Alamat tidak tersedia',
      position: LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      ),
      distanceKm: (json['distance_meters'] as num) / 1000,
      category: cat,
      phone: json['phone'],
      openingHours: json['opening_hours'],
      placeId: json['id'].toString(),
    );
  }
}

class LocationController extends GetxController {
  final isLoading = false.obs;
  final currentPosition = Rxn<LatLng>(); // LatLng dari latlong2
  final places = <NearbyPlace>[].obs;
  final selectedCategory = PlaceCategory.supermarket.obs;
  final errorMessage = ''.obs;
  final selectedPlace = Rxn<NearbyPlace>();

  final String baseUrl = dotenv.env['EXPRESS_API_URL']!;
  static const _radiusMeters = 20000;

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  // ─── 1. Ambil GPS ──────────────────────────────────────
  Future<void> fetchLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        errorMessage.value =
            'Izin lokasi ditolak. Aktifkan di Settings perangkat kamu.';
        isLoading.value = false;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = LatLng(pos.latitude, pos.longitude);
      await fetchNearbyPlaces();
    } catch (e) {
      errorMessage.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 2. Fetch dari database API kamu ──────────────────
  Future<void> fetchNearbyPlaces() async {
    final pos = currentPosition.value;
    if (pos == null) return;

    isLoading.value = true;
    places.clear();
    selectedPlace.value = null;
    errorMessage.value = '';

    try {
      final categoryStr = _categoryToString(selectedCategory.value);
      final url = Uri.parse(
        '$baseUrl/places/nearby'
        '?lat=${pos.latitude}'
        '&lng=${pos.longitude}'
        '&category=$categoryStr'
        '&radius=$_radiusMeters',
      );

      print('🌐 Fetching URL: $url'); // ← TAMBAH INI

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print('📡 Status: ${response.statusCode}'); // ← TAMBAH INI
      print('📦 Body: ${response.body}'); // ← TAMBAH INI

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final results = (data['data'] as List)
              .map((e) => NearbyPlace.fromJson(e, selectedCategory.value))
              .toList();

          print('✅ Places loaded: ${results.length}'); // ← TAMBAH INI

          places.assignAll(results);

          if (places.isEmpty) {
            errorMessage.value =
                'Tidak ada tempat ditemukan dalam ${_radiusMeters ~/ 20000} km.';
          }
        } else {
          errorMessage.value = data['message'] ?? 'Gagal mengambil data.';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Error: $e'); // ← TAMBAH INI
      errorMessage.value = 'Gagal terhubung ke server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 3. Buka navigasi ─────────────────────────────────
  Future<void> openNavigation(NearbyPlace place) async {
    final gmaps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${place.position.latitude},${place.position.longitude}'
      '&travelmode=driving',
    );
    final osm = Uri.parse(
      'https://www.openstreetmap.org/directions'
      '?from=${currentPosition.value?.latitude},${currentPosition.value?.longitude}'
      '&to=${place.position.latitude},${place.position.longitude}',
    );

    if (await canLaunchUrl(gmaps)) {
      await launchUrl(gmaps, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(osm)) {
      await launchUrl(osm, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak bisa membuka aplikasi navigasi');
    }
  }

  // ─── Helper ────────────────────────────────────────────
  String _categoryToString(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.supermarket:
        return 'supermarket';
      case PlaceCategory.donation:
        return 'donation';
      case PlaceCategory.warung:
        return 'warung';
    }
  }

  void changeCategory(PlaceCategory cat) {
    selectedCategory.value = cat;
    fetchNearbyPlaces();
  }

  String labelForCategory(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.supermarket:
        return 'Toko / Market';
      case PlaceCategory.donation:
        return 'Donasi';
      case PlaceCategory.warung:
        return 'Warung / Resto';
    }
  }

  IconData iconForCategory(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.supermarket:
        return Icons.store;
      case PlaceCategory.donation:
        return Icons.volunteer_activism;
      case PlaceCategory.warung:
        return Icons.restaurant;
    }
  }

  Color colorForCategory(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.supermarket:
        return Colors.blue;
      case PlaceCategory.donation:
        return Colors.orange;
      case PlaceCategory.warung:
        return Colors.green;
    }
  }
}
