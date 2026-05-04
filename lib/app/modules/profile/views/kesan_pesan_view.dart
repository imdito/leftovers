import 'package:flutter/material.dart';

class KesanPesanView extends StatelessWidget {
  const KesanPesanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuoteCard(),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    label: "KESAN",
                    title: "Pengalaman Belajar yang Berkesan",
                    children: [
                      _buildParagraph(
                        "Mata kuliah Teknologi Pemrograman Mobile (TPM) adalah salah satu "
                        "perkuliahan yang paling menantang sekaligus paling berkesan. Tidak "
                        "seperti mata kuliah lain yang materinya cukup diikuti di kelas, TPM "
                        "menuntut mahasiswa untuk benar-benar proaktif — aktif mencari "
                        "referensi sendiri, mengikuti perkembangan teknologi mobile yang "
                        "bergerak sangat cepat, serta mempraktikkan setiap konsep secara "
                        "langsung dengan tepat dan efisien.",
                      ),
                      const SizedBox(height: 12),
                      _buildParagraph(
                        "Proses belajar yang intens ini mengajarkan bahwa membangun aplikasi "
                        "mobile bukan sekadar urusan menulis kode. Di baliknya ada proses "
                        "berpikir sistematis, merancang antarmuka yang nyaman digunakan, "
                        "mengelola state dan data, hingga mengintegrasikan berbagai layanan "
                        "eksternal. Setiap tugas dan proyek menjadi simulasi nyata yang "
                        "mempersiapkan diri untuk terjun ke dunia industri.",
                      ),
                      const SizedBox(height: 16),
                      _buildHighlightRow([
                        _HighlightItem(Icons.speed_rounded, "Serba\nCepat"),
                        _HighlightItem(
                          Icons.psychology_rounded,
                          "Berpikir\nKritis",
                        ),
                        _HighlightItem(
                          Icons.build_rounded,
                          "Praktik\nLangsung",
                        ),
                        _HighlightItem(
                          Icons.trending_up_rounded,
                          "Terus\nBerkembang",
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.mail_outline_rounded,
                    iconColor: const Color(0xFF1565C0),
                    label: "PESAN",
                    title: "Untuk Mahasiswa yang Akan Datang",
                    children: [
                      _buildMessagePoint(
                        number: "01",
                        color: const Color(0xFF2E7D32),
                        title: "Jangan Tunggu Materi Datang Sendiri",
                        body:
                            "Jadilah mahasiswa yang aktif dan haus ilmu. Eksplorasi "
                            "dokumentasi resmi, ikuti tutorial dari berbagai sumber, dan "
                            "bangun proyek kecil sejak dini. Informasi ada di mana-mana — "
                            "yang membedakan adalah siapa yang mau bergerak lebih dulu.",
                      ),
                      _buildMessagePoint(
                        number: "02",
                        color: const Color(0xFF1565C0),
                        title: "Jadikan Error sebagai Guru",
                        body:
                            "Setiap pesan error yang muncul bukan musuh, melainkan "
                            "petunjuk berharga menuju solusi. Biasakan membaca, memahami, "
                            "dan men-debug masalah secara mandiri. Kemampuan ini jauh lebih "
                            "bernilai daripada sekadar hafal sintaks.",
                      ),
                      _buildMessagePoint(
                        number: "03",
                        color: const Color(0xFF6A1B9A),
                        title: "Kecepatan & Ketepatan adalah Kunci",
                        body:
                            "Dunia mobile development bergerak sangat dinamis. Teknologi "
                            "baru hadir silih berganti. Latih kemampuan untuk menyerap hal "
                            "baru dengan cepat sekaligus mengimplementasikannya dengan "
                            "tepat — dua hal inilah yang membentuk pengembang sejati.",
                      ),
                      _buildMessagePoint(
                        number: "04",
                        color: const Color(0xFFE65100),
                        title: "Nikmati Setiap Prosesnya",
                        body:
                            "Frustasi, begadang, dan deadline yang mepet adalah bagian "
                            "tak terpisahkan dari perjalanan ini. Hadapilah dengan kepala "
                            "dingin dan rasa ingin tahu yang tinggi. Perjalanan belajar "
                            "inilah yang kelak akan membentuk kompetensi dan karakter "
                            "seorang pengembang aplikasi yang sesungguhnya.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildClosingCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Lingkaran dekoratif
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              // Konten utama
              const Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.school_rounded, color: Colors.white, size: 52),
                    SizedBox(height: 12),
                    Text(
                      "Kesan & Pesan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Teknologi Pemrograman Mobile",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Quote card ───────────────────────────────────────────────────────────
  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Colors.white70,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            "\"Belajar pemrograman mobile bukan tentang menghafal, "
            "melainkan tentang keberanian untuk terus mencoba, gagal, "
            "dan bangkit lebih cepat dari sebelumnya.\"",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "— Mahasiswa TPM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section wrapper ──────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.7),
    );
  }

  Widget _buildHighlightRow(List<_HighlightItem> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(item.icon, color: const Color(0xFF2E7D32), size: 20),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessagePoint({
    required String number,
    required Color color,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.favorite_rounded, color: Colors.greenAccent, size: 30),
          SizedBox(height: 10),
          Text(
            "Terima kasih, TPM!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Mata kuliah ini bukan sekadar soal nilai — ia mengajarkan "
            "cara berpikir, cara belajar mandiri, dan cara bertahan "
            "dalam ketidakpastian. Bekal terbaik untuk masa depan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Data class ──────────────────────────────────────────────────────────────
class _HighlightItem {
  final IconData icon;
  final String label;
  const _HighlightItem(this.icon, this.label);
}
