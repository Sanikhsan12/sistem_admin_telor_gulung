import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/jadwal_sholat_service.dart';
import '../model/jadwal_sholat_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SholatService _sholatService = SholatService();
  late Future<Map<String, dynamic>?> _jadwalData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      String today = DateFormat('yyyy/MM/dd').format(DateTime.now());
      _jadwalData = _sholatService.fetchJadwalSholat('1219', today);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      appBar: AppBar(
        title: const Text(
          'Jadwal Sholat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _jadwalData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            // ! Logging error
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            }

            // ! Data null
            if (snapshot.data == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Text(
                      'Data kosong. Pastikan URL di .env sudah benar.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!;
            final JadwalSholatModel jadwal = JadwalSholatModel.fromJson(
              data['jadwal'],
            );

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              children: [
                _buildHeader(data['lokasi'], jadwal.tanggal),
                const SizedBox(height: 30),
                // Grid Menu
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildSholatCard(
                      'Imsak',
                      jadwal.imsak,
                      Icons.nightlight_round,
                    ),
                    _buildSholatCard('Subuh', jadwal.subuh, Icons.wb_twilight),
                    _buildSholatCard(
                      'Terbit',
                      jadwal.terbit,
                      Icons.wb_sunny_outlined,
                    ),
                    _buildSholatCard('Dzuhur', jadwal.dzuhur, Icons.wb_sunny),
                    _buildSholatCard('Ashar', jadwal.ashar, Icons.cloud),
                    _buildSholatCard(
                      'Maghrib',
                      jadwal.maghrib,
                      Icons.wb_twilight,
                    ),
                    _buildSholatCard('Isya', jadwal.isya, Icons.nights_stay),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String lokasi, String tanggal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.white70, size: 40),
        const SizedBox(height: 8),
        Text(
          lokasi,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tanggal,
          style: TextStyle(color: Colors.blue.shade100, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSholatCard(String name, String time, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
