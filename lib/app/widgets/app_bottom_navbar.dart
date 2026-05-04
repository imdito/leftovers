import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leftovers/app/routes/app_pages.dart';


class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavbar({super.key, required this.currentIndex});

  // index → route mapping:
  // 0: Kulkas  1: Resep  2: Home  3: Donasi  4: Profil
  static const _routes = [
    Routes.INVENTORY,
    Routes.RECIPE,
    Routes.HOME,
    Routes.LOCATION,
    Routes.PROFILE,
  ];

  void _navigate(int index) {
    if (index == currentIndex) return;
    Get.offAllNamed(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem(0, Icons.kitchen_outlined, Icons.kitchen, 'Kulkas'),
          _buildItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Resep'),
          _buildHomeItem(),
          _buildItem(3, Icons.map_outlined, Icons.map, 'Donasi'),
          _buildItem(4, Icons.person_outline, Icons.person, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF2E7D32) : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _navigate(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeItem() {
    final isSelected = currentIndex == 2;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigate(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
