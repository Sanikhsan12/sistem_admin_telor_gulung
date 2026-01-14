import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/order_model.dart';
import '../service/order_service.dart';

class SalesGraphPage extends StatefulWidget {
  const SalesGraphPage({super.key});

  @override
  State<SalesGraphPage> createState() => _SalesGraphPageState();
}

class _SalesGraphPageState extends State<SalesGraphPage>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Selected chart type
  int _selectedChartType = 0; // 0: Line, 1: Bar, 2: Pie

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _fetchOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _animationController.forward(from: 0);
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

    // Daily sales data (last 7 days simulation based on order count)
    Map<String, int> dailySales = {};

    for (var order in _orders) {
      totalPendapatan += order.total_harga;
      totalBarang += order.total_barang;

      String status = order.status.replaceAll(' ', '_');
      if (statusCount.containsKey(status)) {
        statusCount[status] = statusCount[status]! + 1;
        statusRevenue[status] = statusRevenue[status]! + order.total_harga;
      }
    }

    // Generate mock daily data based on orders distribution
    int ordersPerDay = (_orders.length / 7).ceil();
    List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    int remainingOrders = _orders.length;

    for (int i = 0; i < 7; i++) {
      int dayOrders = i < 6
          ? (ordersPerDay + (i % 3) - 1).clamp(0, remainingOrders)
          : remainingOrders;
      dailySales[days[i]] = dayOrders;
      remainingOrders -= dayOrders;
      if (remainingOrders < 0) remainingOrders = 0;
    }

    return {
      'totalTransaksi': totalTransaksi,
      'totalPendapatan': totalPendapatan,
      'totalBarang': totalBarang,
      'statusCount': statusCount,
      'statusRevenue': statusRevenue,
      'dailySales': dailySales,
    };
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_antrian':
        return const Color(0xFFFF9800);
      case 'diproses':
        return const Color(0xFF2196F3);
      case 'selesai':
        return const Color(0xFF4CAF50);
      case 'dibatalkan':
        return const Color(0xFFF44336);
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
      backgroundColor: const Color(0xFF1565C0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
    final dailySales = stats['dailySales'] as Map<String, int>;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards with gradient
        _buildGradientSummaryCards(stats),
        const SizedBox(height: 24),

        // Chart Type Selector
        _buildChartTypeSelector(),
        const SizedBox(height: 16),

        // Dynamic Chart based on selection
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _buildSelectedChart(statusCount, dailySales);
          },
        ),
        const SizedBox(height: 24),

        // Status Legend
        _buildStatusLegend(statusCount),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildGradientSummaryCards(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernCard(
                'Total Transaksi',
                '${stats['totalTransaksi']}',
                Icons.receipt_long,
                const [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernCard(
                'Total Barang',
                '${stats['totalBarang']} pcs',
                Icons.shopping_bag,
                const [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildModernCard(
          'Total Pendapatan',
          _formatCurrency(stats['totalPendapatan']),
          Icons.monetization_on,
          const [Color(0xFFf093fb), Color(0xFFf5576c)],
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildModernCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors, {
    bool isWide = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 20 : 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: isWide ? 32 : 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isWide ? 14 : 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isWide ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildChartTypeButton(0, Icons.show_chart, 'Line'),
          _buildChartTypeButton(1, Icons.bar_chart, 'Bar'),
          _buildChartTypeButton(2, Icons.pie_chart, 'Pie'),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(int index, IconData icon, String label) {
    bool isSelected = _selectedChartType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedChartType = index);
          _animationController.forward(from: 0);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF1565C0) : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF1565C0) : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart(
    Map<String, int> statusCount,
    Map<String, int> dailySales,
  ) {
    switch (_selectedChartType) {
      case 0:
        return _buildLineChart(dailySales);
      case 1:
        return _buildBarChart(statusCount);
      case 2:
        return _buildPieChart(statusCount);
      default:
        return _buildLineChart(dailySales);
    }
  }

  Widget _buildLineChart(Map<String, int> dailySales) {
    List<FlSpot> spots = [];
    List<String> days = dailySales.keys.toList();
    int maxValue = 1;

    for (int i = 0; i < days.length; i++) {
      int value = dailySales[days[i]] ?? 0;
      if (value > maxValue) maxValue = value;
      spots.add(FlSpot(i.toDouble(), value.toDouble() * _animation.value));
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Trend Penjualan Mingguan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxValue / 4).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[index],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (days.length - 1).toDouble(),
                minY: 0,
                maxY: (maxValue * 1.2).toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: const Color(0xFF667eea),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.3),
                          const Color(0xFF667eea).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} order',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> statusCount) {
    int maxCount = 1;
    statusCount.forEach((key, value) {
      if (value > maxCount) maxCount = value;
    });

    List<String> statuses = statusCount.keys.toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF11998e).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF11998e),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order per Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount * 1.3).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String status = statuses[group.x];
                      return BarTooltipItem(
                        '${status.replaceAll('_', ' ')}\n${rod.toY.toInt()} order',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < statuses.length) {
                          String label = statuses[index];
                          IconData icon;
                          switch (label) {
                            case 'menunggu_antrian':
                              icon = Icons.hourglass_empty;
                              break;
                            case 'diproses':
                              icon = Icons.sync;
                              break;
                            case 'selesai':
                              icon = Icons.check_circle;
                              break;
                            case 'dibatalkan':
                              icon = Icons.cancel;
                              break;
                            default:
                              icon = Icons.circle;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(
                              icon,
                              size: 20,
                              color: _getStatusColor(label),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxCount / 4).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: statuses.asMap().entries.map((entry) {
                  int index = entry.key;
                  String status = entry.value;
                  int count = statusCount[status] ?? 0;
                  Color color = _getStatusColor(status);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble() * _animation.value,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [color.withOpacity(0.7), color],
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxCount * 1.3,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> statusCount) {
    int total = statusCount.values.fold(0, (sum, count) => sum + count);
    if (total == 0) total = 1;

    List<PieChartSectionData> sections = [];
    int index = 0;

    statusCount.forEach((status, count) {
      double percentage = (count / total) * 100;
      Color color = _getStatusColor(status);

      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble() * _animation.value,
          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: 55 * _animation.value,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: percentage > 10 ? _buildPieBadge(count, color) : null,
          badgePositionPercentageOffset: 1.3,
        ),
      );
      index++;
    });

    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf093fb).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFFf093fb),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Distribusi Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                sections: sections,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusLegend(Map<String, int> statusCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: statusCount.entries.map((entry) {
              String displayLabel = entry.key.replaceAll('_', ' ');
              displayLabel =
                  displayLabel[0].toUpperCase() + displayLabel.substring(1);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(entry.key),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$displayLabel (${entry.value})',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
