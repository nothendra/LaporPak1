import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../flutterViz_bottom_navigationBar_model.dart';

// 🔹 Import halaman lain (JANGAN DIUBAH)
import '../admin/home_admin.dart';
import '../Date/dateadmin.dart';
import '../history/HistoryAdmin.dart';

class ProfileAdmin extends StatelessWidget {
  const ProfileAdmin({super.key});

  final int _selectedIndex = 3; // Halaman aktif: Akun

  // 🔹 Navigasi antar halaman
  void _onItemTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;

    Widget? nextPage;
    switch (index) {
      case 0:
        nextPage = const HomeAdmin(); // Halaman utama admin
        break;
      case 1:
        nextPage = const DateAdmin(); // Halaman kalender admin
        break;
      case 2:
        nextPage = const Approvement(); // Halaman approvement admin
        break;
      case 3:
        nextPage = const ProfileAdmin(); // Halaman akun admin
        break;
    }

    if (nextPage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FlutterVizBottomNavigationBarModel> navItems = [
      FlutterVizBottomNavigationBarModel(icon: Icons.home, label: "Home"),
      FlutterVizBottomNavigationBarModel(icon: Icons.calendar_today, label: "Date"),
      FlutterVizBottomNavigationBarModel(icon: Icons.description, label: "History"),
      FlutterVizBottomNavigationBarModel(icon: Icons.account_circle, label: "Account"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),

      // =============================
      // ✅ APP BAR (diseragamkan dengan Ketua RT)
      // =============================
      appBar: AppBar(
        backgroundColor: const Color(0xff5f34e0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmin()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Profil Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/logo.png',
              width: 22,
              height: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),

      // =============================
      // ✅ BOTTOM NAVIGATION (SAMA PERSIS DENGAN HOMEADMIN)
      // =============================
      bottomNavigationBar: BottomNavigationBar(
        items: navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        elevation: 8,
        iconSize: 24,
        selectedItemColor: const Color(0xff5f33e2),
        unselectedItemColor: const Color(0xffb5a1f0),
        selectedFontSize: 10,
        unselectedFontSize: 9,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onItemTapped(context, index),
      ),

      // =============================
      // BODY (tidak diubah)
      // =============================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            // ==================================
            // FOTO PROFIL & NAMA
            // ==================================
            Stack(
              alignment: Alignment.center,
              children: [
                Lottie.network(
                  "https://assets8.lottiefiles.com/packages/lf20_8ydmsved.json",
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff5f34e0), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    "assets/profile.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Pak Etmin",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Admin",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xff5f34e0),
              ),
            ),
            const SizedBox(height: 25),

            // ==================================
            // INFO KONTAK
            // ==================================
            _infoCard(
              icon: Icons.mail_outline,
              title: "Email",
              value: "adminlaporpak@gmail.com",
            ),
            const SizedBox(height: 14),
            _infoCard(
              icon: Icons.location_on_outlined,
              title: "Alamat Kantor",
              value: "Jl. Siliwangi No. 10, Lowokwaru, Kota Malang, 65141",
            ),
            const SizedBox(height: 14),
            _infoCard(
              icon: Icons.work_outline,
              title: "Tugas",
              value:
                  "Mengelola data laporan warga dan melakukan validasi hasil investigasi dari petugas lapangan.",
            ),

            const SizedBox(height: 35),

            // ==================================
            // TOMBOL LOGOUT
            // ==================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Anda telah keluar dari akun!"),
                      backgroundColor: Color(0xff5f34e0),
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Keluar Akun",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5f34e0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================================
  // REUSABLE WIDGET INFO CARD
  // ==================================
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xffe7e3ff),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x145f34e0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff5f34e0), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
