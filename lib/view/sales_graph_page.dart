import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../service/order_service.dart';

class SalesGraphPage extends StatefulWidget {
  const SalesGraphPage({super.key});

  @override
  State<SalesGraphPage> createState() => _SalesGraphPageState();
}

class _SalesGraphPageState extends State<SalesGraphPage> {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _orderService.fetchOrders();

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'];

        setState(() {
          _orders = data.map((e) => OrderModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal load data (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Hitung statistik penjualan
  Map<String, dynamic> _calculateStats() {
    int totalTransaksi = _orders.length;
    int totalPendapatan = 0;
    int totalBarang = 0;

    Map<String, int> statusCount = {
      'menunggu_antrian': 0,
      'diproses': 0,
      'selesai': 0,
      'dibatalkan': 0,
    };

    Map<String, int> statusRevenue = {
      'menunggu_antrian': 0,
      'diproses': 0,
      'selesai': 0,
      'dibatalkan': 0,
    };

    for (var order in _orders) {
      totalPendapatan += order.total_harga;
      totalBarang += order.total_barang;

      String status = order.status.replaceAll(' ', '_');
      if (statusCount.containsKey(status)) {
        statusCount[status] = statusCount[status]! + 1;
        statusRevenue[status] = statusRevenue[status]! + order.total_harga;
      }
    }

    return {
      'totalTransaksi': totalTransaksi,
      'totalPendapatan': totalPendapatan,
      'totalBarang': totalBarang,
      'statusCount': statusCount,
      'statusRevenue': statusRevenue,
    };
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_antrian':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grafik Penjualan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: _orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.bar_chart, size: 64, color: Colors.white70),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Belum ada data order',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    )
                  : _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    final stats = _calculateStats();
    final statusCount = stats['statusCount'] as Map<String, int>;
    final statusRevenue = stats['statusRevenue'] as Map<String, int>;

    // Find max count for chart scaling
    int maxCount = 1;
    statusCount.forEach((key, value) {
      if (value > maxCount) maxCount = value;
    });

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Transaksi',
                '${stats['totalTransaksi']}',
                Icons.receipt_long,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Barang',
                '${stats['totalBarang']} pcs',
                Icons.shopping_bag,
                Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Total Pendapatan',
          _formatCurrency(stats['totalPendapatan']),
          Icons.monetization_on,
          Colors.green,
        ),
        const SizedBox(height: 24),

        // Chart Title
        const Text(
          'Jumlah Order per Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Bar Chart
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: statusCount.entries.map((entry) {
                double percentage = maxCount > 0 ? entry.value / maxCount : 0;
                return _buildBarItem(
                  entry.key,
                  entry.value,
                  percentage,
                  _getStatusColor(entry.key),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Revenue per Status Title
        const Text(
          'Pendapatan per Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Revenue Cards
        ...statusRevenue.entries.map((entry) {
          return _buildRevenueCard(
            entry.key,
            entry.value,
            statusCount[entry.key] ?? 0,
            _getStatusColor(entry.key),
          );
        }),

        const SizedBox(height: 100), // Extra padding for bottom navbar
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarItem(
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    String displayLabel = label.replaceAll('_', ' ').toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count order',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 20,
                    width: constraints.maxWidth * percentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.7), color],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(
    String status,
    int revenue,
    int count,
    Color color,
  ) {
    String displayStatus = status.replaceAll('_', ' ').toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 10,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        title: Text(
          displayStatus,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$count order'),
        trailing: Text(
          _formatCurrency(revenue),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
