import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../Date/datert.dart';
import '../history/historyrt.dart';
import '../rt/rt_home.dart';
import '../flutterViz_bottom_navigationBar_model.dart';

class ProfilKetua extends StatefulWidget {
  const ProfilKetua({super.key});

  @override
  State<ProfilKetua> createState() => _ProfilKetuaState();
}

class _ProfilKetuaState extends State<ProfilKetua> {
  int _selectedIndex = 3;

  final List<FlutterVizBottomNavigationBarModel> navItems = [
    FlutterVizBottomNavigationBarModel(icon: Icons.home, label: "Home"),
    FlutterVizBottomNavigationBarModel(icon: Icons.calendar_today, label: "Date"),
    FlutterVizBottomNavigationBarModel(icon: Icons.description, label: "History"),
    FlutterVizBottomNavigationBarModel(icon: Icons.account_circle, label: "Account"),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreenrt()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DatePageRT()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Historyyrt()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),

      /// ✅ APP BAR (header sama persis seperti Date & History)
      appBar: AppBar(
        backgroundColor: const Color(0xff5f34e0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreenrt()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Profil Ketua RT',
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

      /// ✅ BODY
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),

            // ====================================================
            // 🔹 FOTO PROFIL + NAMA + JABATAN
            // ====================================================
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
                    border: Border.all(
                      color: const Color(0xff5f34e0),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset("assets/profile.png", fit: BoxFit.cover),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Kentangtintung",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Ketua RT",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xff5f34e0),
              ),
            ),
            const SizedBox(height: 25),

            // ====================================================
            // 🔹 INFORMASI KONTAK
            // ====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoCard(
                    icon: Icons.mail_outline,
                    title: "Email",
                    value: "emailpakrete@gmail.com",
                  ),
                  const SizedBox(height: 14),
                  _infoCard(
                    icon: Icons.location_on_outlined,
                    title: "Alamat",
                    value:
                        "Perumahan Alfa, Blok A-12, Blimbing, Kec. Torimiso, Kota Malang, 65112",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ====================================================
            // 🔹 TOMBOL LOGOUT
            // ====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Tambahkan aksi logout nanti
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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      /// ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        elevation: 8,
        iconSize: 22,
        selectedItemColor: const Color(0xff5f33e2),
        unselectedItemColor: const Color(0xffb5a1f0),
        selectedFontSize: 10,
        unselectedFontSize: 9,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  // ====================================================
  // 🔹 REUSABLE WIDGET — INFO CARD
  // ====================================================
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
        border: Border.all(color: const Color(0xffe7e3ff), width: 1),
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
