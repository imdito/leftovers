import 'package:flutter/material.dart';

class AnggotaKelompokView extends StatelessWidget {
  const AnggotaKelompokView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Kelompok'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Anggota',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _memberCard(
              name: 'Muhammad Pandito Setiawan',
              nim: '123230157',
              kelas: 'IF-H',
              initials: 'MP',
              color: const Color(0xFF42A5F5),
            ),
            const SizedBox(height: 12),
            _memberCard(
              name: 'Taufiq Candra Kurniawan',
              nim: '123230071',
              kelas: 'IF-H',
              initials: 'TC',
              color: const Color(0xFFAB47BC),
            ),
            const Spacer(),
            Center(
              child: Text(
                'TPM - Teknologi Pemrograman Mobile',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _memberCard({
    required String name,
    required String nim,
    required String kelas,
    required String initials,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('NIM: $nim', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  'Kelas: $kelas',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
