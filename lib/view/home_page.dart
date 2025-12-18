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
      appBar: AppBar(
        title: const Text(
          'Jadwal Sholat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.blue,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.blue,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _jadwalData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ! Logging eror
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text('Error: ${snapshot.error}')),
                ],
              );
            }

            // ! Data null
            if (snapshot.data == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Data kosong. Pastikan URL di .env sudah benar.',
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
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(data['lokasi'], jadwal.tanggal),
                const SizedBox(height: 20),
                _buildSholatTile('Imsak', jadwal.imsak),
                _buildSholatTile('Subuh', jadwal.subuh),
                _buildSholatTile('Terbit', jadwal.terbit),
                _buildSholatTile('Dzuhur', jadwal.dzuhur),
                _buildSholatTile('Ashar', jadwal.ashar),
                _buildSholatTile('Maghrib', jadwal.maghrib),
                _buildSholatTile('Isya', jadwal.isya),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String lokasi, String tanggal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lokasi,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(tanggal, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ],
    );
  }

  Widget _buildSholatTile(String name, String time) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
