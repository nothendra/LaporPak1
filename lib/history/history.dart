import 'package:flutter/material.dart';
import '../flutterViz_bottom_navigationBar_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';

// 🔹 Import halaman lain
import '../Home/home.dart';
import '../Date/date.dart';
import '../Formulir/tambah.dart';
import '../Akun/akun.dart';

class HistoryLaporan extends StatefulWidget {
  const HistoryLaporan({super.key});

  @override
  State<HistoryLaporan> createState() => _HistoryLaporanPageState();
}

class _HistoryLaporanPageState extends State<HistoryLaporan> {
  int _selectedIndex = 3;
  String selectedFilter = "All";
  bool _loading = false;
  String? _error;
  List<dynamic> _aduan = [];

  final List<String> filters = ["All", "Terkirim", "Dalam Proses", "Selesai"];

  final List<FlutterVizBottomNavigationBarModel> navItems = [
    FlutterVizBottomNavigationBarModel(icon: Icons.home, label: "Home"),
    FlutterVizBottomNavigationBarModel(icon: Icons.calendar_today, label: "Date"),
    FlutterVizBottomNavigationBarModel(icon: Icons.add, label: "Tambah"),
    FlutterVizBottomNavigationBarModel(icon: Icons.description, label: "History"),
    FlutterVizBottomNavigationBarModel(icon: Icons.account_circle, label: "Account"),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget? nextPage;
    switch (index) {
      case 0:
        nextPage = const HomeWarga();
        break;
      case 1:
        nextPage = const DatePage();
        break;
      case 2:
        nextPage = const UploadKeluhan();
        break;
      case 3:
        nextPage = const HistoryLaporan();
        break;
      case 4:
        nextPage = Profile();
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
  void initState() {
    super.initState();
    _loadData();
  }

  int? _filterToStatus(String filter) {
    switch (filter) {
      case 'Terkirim':
        return 1;
      case 'Dalam Proses':
        return 2;
      case 'Selesai':
        return 3;
      default:
        return null;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Anda belum login.';
        });
        return;
      }

      final status = _filterToStatus(selectedFilter);
      final res = await ApiService.getWargaAduan(token: token, status: status);
      setState(() {
        _aduan = (res['data'] as List<dynamic>);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _aduan;

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),

      // ✅ HEADER DISESUAIKAN DENGAN RT
      appBar: AppBar(
        backgroundColor: const Color(0xff5f34e0),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "History Laporan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: ImageIcon(
              AssetImage('assets/logo.png'),
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),

      // ========================== BODY ==========================
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildFilterBar(),
          const SizedBox(height: 10),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!)))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index] as Map<String, dynamic>;
                  return _buildReportCard(item);
                },
              ),
            ),
        ],
      ),

      // ✅ BOTTOM NAVBAR (warna ungu RT-style)
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
        iconSize: 24,
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

  // ========================== FILTER BAR ==========================
  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () async {
              setState(() => selectedFilter = filter);
              await _loadData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff5f34e0) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xff5f34e0)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xff5f34e0).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========================== KARTU LAPORAN ==========================
  Widget _buildReportCard(Map<String, dynamic> item) {
    Color statusColor;
    String statusLabel;
    switch (item['status']) {
      case 1:
        statusColor = const Color(0xff5f34e0);
        statusLabel = 'Terkirim';
        break;
      case 2:
        statusColor = Colors.orangeAccent;
        statusLabel = 'Dalam Proses';
        break;
      case 3:
        statusColor = Colors.green;
        statusLabel = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = 'Tidak diketahui';
    }

    final String? fotoPath = item['foto'];
    final imageWidget = (fotoPath != null)
        ? Image.network(
            '${ApiService.baseHost}/storage/$fotoPath',
            width: double.infinity,
            height: 170,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              color: Colors.grey.shade200,
              height: 170,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          )
        : Container(
            color: Colors.grey.shade200,
            width: double.infinity,
            height: 170,
            alignment: Alignment.center,
            child: const Icon(Icons.image, color: Colors.grey),
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: imageWidget,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item["judul"] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (item["deskripsi"] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 13, color: Color(0xff5f34e0)),
                          const SizedBox(width: 4),
                          Text(
                            (item["tanggal"] ?? '').toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
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
