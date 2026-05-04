import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';
import 'package:leftovers/app/widgets/app_bottom_navbar.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── LAYER 1: Map penuh satu layar ──────────────
          _buildFullMap(),

          // ── LAYER 2: AppBar transparan di atas map ─────
          _buildTopBar(),

          // ── LAYER 3: Filter kategori ───────────────────
          _buildCategoryFilterOverlay(),

          // ── LAYER 4: Panel list bisa di-drag ──────────
          _buildDraggablePanel(),
        ],
      ),

      // ── FAB: Kembali ke lokasi user ───────────────────
      floatingActionButton: _buildMyLocationFab(),
      bottomNavigationBar: const AppBottomNavbar(currentIndex: 3),
    );
  }

  // ─── Map full screen ───────────────────────────────────
  Widget _buildFullMap() {
    return Obx(() {
      final pos = controller.currentPosition.value;

      // Sebelum lokasi didapat
      if (pos == null) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 12),
                Text('Mengambil lokasi GPS...'),
              ],
            ),
          ),
        );
      }

      final markers = <Marker>[
        // Marker posisi user
        Marker(
          point: pos,
          width: 60,
          height: 60,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
        ),

        // Marker tiap tempat
        ...controller.places.map((place) {
          final isSelected =
              controller.selectedPlace.value?.placeId == place.placeId;
          final color = controller.colorForCategory(place.category);

          return Marker(
            point: place.position,
            width: 60,
            height: 65,
            child: GestureDetector(
              onTap: () => controller.selectedPlace.value = place,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? Colors.red : color).withOpacity(
                            0.4,
                          ),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.iconForCategory(place.category),
                      color: Colors.white,
                      size: isSelected ? 22 : 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${place.distanceKm.toStringAsFixed(1)}km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ];

      return FlutterMap(
        options: MapOptions(
          initialCenter: pos,
          initialZoom: 14,
          onTap: (_, __) => controller.selectedPlace.value = null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.leftovers',
          ),
          MarkerLayer(markers: markers),
        ],
      );
    });
  }

  // ─── AppBar transparan di atas map ────────────────────
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Text(
                    '📍 Tempat Terdekat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: controller.fetchLocation,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Filter kategori overlay di atas map ──────────────
  Widget _buildCategoryFilterOverlay() {
    return Positioned(
      top: 100,
      left: 12,
      right: 12,
      child: Obx(
        () => Row(
          children: PlaceCategory.values.map((cat) {
            final isSelected = controller.selectedCategory.value == cat;
            final color = controller.colorForCategory(cat);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => controller.changeCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color
                          : Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          controller.iconForCategory(cat),
                          color: isSelected ? Colors.white : Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          controller.labelForCategory(cat),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Panel bawah yang bisa di-drag ────────────────────
  Widget _buildDraggablePanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.32, // awalnya 32% layar
      minChildSize: 0.12, // minimal 12% (cuma handle keliatan)
      maxChildSize: 0.75, // maksimal 75% layar
      snap: true,
      snapSizes: const [0.12, 0.32, 0.75],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle drag
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Popup tempat dipilih
              _buildSelectedPlacePopup(),

              // Judul & jumlah hasil
              Obx(() {
                final count = controller.places.length;
                final cat = controller.labelForCategory(
                  controller.selectedCategory.value,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        count > 0 ? '$count $cat ditemukan' : cat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (controller.isLoading.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                );
              }),

              // List tempat
              Expanded(child: _buildPlacesList(scrollController)),
            ],
          ),
        );
      },
    );
  }

  // ─── Popup tempat yang dipilih dari marker ─────────────
  Widget _buildSelectedPlacePopup() {
    return Obx(() {
      final place = controller.selectedPlace.value;
      if (place == null) return const SizedBox();

      final color = controller.colorForCategory(place.category);
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(controller.iconForCategory(place.category), color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${place.distanceKm.toStringAsFixed(1)} km  •  ${place.address}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.navigation, color: color),
              onPressed: () => controller.openNavigation(place),
              tooltip: 'Navigasi',
            ),
          ],
        ),
      );
    });
  }

  // ─── List tempat ───────────────────────────────────────
  Widget _buildPlacesList(ScrollController scrollController) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.green),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              // ← Column diganti jadi ini
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: controller.fetchNearbyPlaces,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (controller.places.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada tempat ditemukan.\nCoba kategori lain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
        itemCount: controller.places.length,
        itemBuilder: (_, i) => _buildPlaceCard(controller.places[i]),
      );
    });
  }

  // ─── Card tiap tempat ──────────────────────────────────
  Widget _buildPlaceCard(NearbyPlace place) {
    final color = controller.colorForCategory(place.category);
    return Obx(() {
      final isSelected =
          controller.selectedPlace.value?.placeId == place.placeId;
      return GestureDetector(
        onTap: () => controller.selectedPlace.value = place,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon kategori
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    controller.iconForCategory(place.category),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        place.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          // Jarak
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 13,
                                color: color,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${place.distanceKm.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          // Jam buka
                          if (place.openingHours != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 13,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  place.openingHours!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Nomor telepon
                      if (place.phone != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 13,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              place.phone!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Tombol navigasi
                IconButton(
                  icon: Icon(Icons.navigation, color: color),
                  onPressed: () => controller.openNavigation(place),
                  tooltip: 'Navigasi',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── FAB kembali ke posisi user ───────────────────────
  Widget _buildMyLocationFab() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 180),
      child: FloatingActionButton.small(
        onPressed: controller.fetchLocation,
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.green),
      ),
    );
  }
}
