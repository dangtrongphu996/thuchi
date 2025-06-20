import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import 'package:flutter/cupertino.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';

class BarChartScreen extends StatefulWidget {
  const BarChartScreen({super.key});

  @override
  State<BarChartScreen> createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  final DanhMucDao _danhMucDao = DanhMucDao();
  List<BarChartGroupData> barGroups = [];
  int selectedYear = DateTime.now().year;
  bool isLoading = true;
  int selectedType = 2; // 2: Chi phí, 1: Thu nhập
  List<DanhMuc> allDanhMucs = [];
  List<int> selectedDanhMucs = [];
  int startMonth = 1;
  int endMonth = DateTime.now().month;
  Map<int, Map<String, dynamic>> _barDetails = {};

  Future<void> loadChart() async {
    setState(() {
      isLoading = true;
    });

    // Lấy danh mục nếu chưa có
    if (allDanhMucs.isEmpty) {
      allDanhMucs = await _danhMucDao.getDanhMucByLoai(selectedType);
      if (selectedDanhMucs.isEmpty) {
        selectedDanhMucs = allDanhMucs.map((e) => e.id!).toList();
      }
    }

    try {
      final data = <int, double>{};
      final details =
          <int, Map<String, dynamic>>{}; // month: {total, count, topCategory}

      for (int m = startMonth; m <= endMonth; m++) {
        final list = await _dao.getByMonth(m, selectedYear);
        double chi = 0;
        int count = 0;
        Map<int, double> catSum = {};
        if (list.isNotEmpty) {
          final filtered =
              list
                  .where(
                    (e) =>
                        e.danhMuc.loai == selectedType &&
                        selectedDanhMucs.contains(e.danhMuc.id),
                  )
                  .toList();
          chi = filtered.fold<double>(
            0,
            (sum, e) => sum + e.chiTietChiTieu.soTien,
          );
          count = filtered.length;
          for (var e in filtered) {
            catSum[e.danhMuc.id!] =
                (catSum[e.danhMuc.id!] ?? 0) + e.chiTietChiTieu.soTien;
          }
        }
        String topCategory = '';
        if (catSum.isNotEmpty) {
          final topId =
              catSum.entries.reduce((a, b) => a.value > b.value ? a : b).key;
          final dm = allDanhMucs.firstWhere(
            (d) => d.id == topId,
            orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: selectedType),
          );
          topCategory = '${dm.icon ?? ''} ${dm.ten}';
        }
        data[m] = chi;
        details[m] = {'total': chi, 'count': count, 'topCategory': topCategory};
      }

      if (mounted) {
        setState(() {
          barGroups =
              data.entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      gradient: LinearGradient(
                        colors:
                            selectedType == 2
                                ? [Colors.redAccent, Colors.orangeAccent]
                                : [Colors.lightBlue, Colors.greenAccent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 22,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }).toList();
          _barDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadChart();
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán maxY và đơn vị chia phù hợp
    double maxY =
        barGroups.isEmpty
            ? 1000000
            : barGroups.fold<double>(
                  0,
                  (max, group) =>
                      group.barRods.first.toY > max
                          ? group.barRods.first.toY
                          : max,
                ) *
                1.2;
    String yUnit = '';
    double yDivisor = 1;
    if (maxY >= 1000000000) {
      yUnit = 'B';
      yDivisor = 1000000000;
    } else if (maxY >= 1000000) {
      yUnit = 'M';
      yDivisor = 1000000;
    } else if (maxY >= 1000) {
      yUnit = 'K';
      yDivisor = 1000;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Biểu đồ chi tiêu theo tháng",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ("Biểu đồ chi tiêu theo tháng").length > 20 ? 16 : 20,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : barGroups.isEmpty
                ? const Center(
                  child: Text(
                    'Không có dữ liệu chi tiêu cho năm này',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : SafeArea(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 18,
                          left: 18,
                          right: 18,
                          bottom: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.18),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selectedType == 2
                                      ? CupertinoIcons.money_dollar_circle
                                      : CupertinoIcons.money_dollar_circle_fill,
                                  color:
                                      selectedType == 2
                                          ? Colors.redAccent
                                          : Colors.lightBlue,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Loại:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<int>(
                              value: selectedType,
                              underline: Container(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_up_right_circle,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text('Chi phí'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_down_left_circle,
                                        color: Colors.lightBlue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text('Thu nhập'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedType = value;
                                    allDanhMucs = [];
                                    selectedDanhMucs = [];
                                  });
                                  loadChart();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Năm:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: DropdownButtonFormField<int>(
                                value: selectedYear,
                                decoration: InputDecoration(
                                  labelText: '',
                                  prefixIcon: Icon(
                                    Icons.date_range,
                                    color: Colors.deepOrange,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 8,
                                  ),
                                ),
                                items: List.generate(
                                  5,
                                  (i) => DropdownMenuItem(
                                    value: DateTime.now().year - 2 + i,
                                    child: Text(
                                      "${DateTime.now().year - 2 + i}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedYear = value;
                                    });
                                    loadChart();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 8,
                          left: 18,
                          right: 18,
                          bottom: 6,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final result = await showDialog<List<int>>(
                                    context: context,
                                    builder: (context) {
                                      List<int> tempSelected = List.from(
                                        selectedDanhMucs,
                                      );
                                      return AlertDialog(
                                        title: const Text('Chọn danh mục'),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children:
                                                allDanhMucs.map((dm) {
                                                  return CheckboxListTile(
                                                    value: tempSelected
                                                        .contains(dm.id),
                                                    title: Text(
                                                      '${dm.icon ?? ''} ${dm.ten}',
                                                    ),
                                                    onChanged: (checked) {
                                                      if (checked == true) {
                                                        tempSelected.add(
                                                          dm.id!,
                                                        );
                                                      } else {
                                                        tempSelected.remove(
                                                          dm.id,
                                                        );
                                                      }
                                                      (context as Element)
                                                          .markNeedsBuild();
                                                    },
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  null,
                                                ),
                                            child: const Text('Hủy'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  tempSelected,
                                                ),
                                            child: const Text('Chọn'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (result != null) {
                                    setState(() {
                                      selectedDanhMucs = result;
                                    });
                                    loadChart();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 20,
                                        color: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          selectedDanhMucs.length ==
                                                  allDanhMucs.length
                                              ? 'Tất cả danh mục'
                                              : allDanhMucs
                                                  .where(
                                                    (dm) => selectedDanhMucs
                                                        .contains(dm.id),
                                                  )
                                                  .map((dm) => dm.ten)
                                                  .join(', '),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownButton<int>(
                              value: startMonth,
                              items:
                                  List.generate(12, (i) => i + 1)
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text('T$e'),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null && value <= endMonth) {
                                  setState(() {
                                    startMonth = value;
                                  });
                                  loadChart();
                                }
                              },
                            ),
                            const Text(' - '),
                            DropdownButton<int>(
                              value: endMonth,
                              items:
                                  List.generate(12, (i) => i + 1)
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text('T$e'),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null && value >= startMonth) {
                                  setState(() {
                                    endMonth = value;
                                  });
                                  loadChart();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.18),
                                spreadRadius: 2,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipBgColor: Colors.transparent,
                                          getTooltipItem: (
                                            group,
                                            groupIndex,
                                            rod,
                                            rodIndex,
                                          ) {
                                            final m = group.x;
                                            final detail = _barDetails[m] ?? {};
                                            final total = detail['total'] ?? 0;
                                            if (total == 0) return null;
                                            return BarTooltipItem(
                                              '${total % 1 == 0 ? total.toStringAsFixed(0) : total.toStringAsFixed(1)}\n',
                                              const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval:
                                            maxY > 0 ? maxY / 5 : 1,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey.withOpacity(0.2),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      barGroups: barGroups,
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 0.0,
                                                ),
                                                child: Text(
                                                  "T${value.toInt()}",
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                ((value / yDivisor) % 1 == 0
                                                        ? (value / yDivisor)
                                                            .toStringAsFixed(0)
                                                        : (value / yDivisor)
                                                            .toStringAsFixed(
                                                              1,
                                                            )) +
                                                    yUnit,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildStatistics(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatistics() {
    // Lấy dữ liệu từ barGroups
    final List<double> values =
        barGroups.map((g) => g.barRods.first.toY).where((v) => v > 0).toList();
    if (values.isEmpty) {
      return const Text(
        'Không có dữ liệu thống kê',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }
    final total = values.fold(0.0, (a, b) => a + b);
    final avg = total / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final maxMonth = barGroups.firstWhere((g) => g.barRods.first.toY == max).x;
    final minMonth = barGroups.firstWhere((g) => g.barRods.first.toY == min).x;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Cao nhất', 'T$maxMonth', max),
          _statItem('Thấp nhất', 'T$minMonth', min),
          _statItem('Trung bình', '', avg),
          _statItem('Tổng', '', total),
        ],
      ),
    );
  }

  Widget _statItem(String label, String month, double value) {
    IconData? icon;
    Color color = Colors.black87;
    switch (label) {
      case 'Cao nhất':
        icon = Icons.trending_up;
        color = Colors.green[800]!;
        break;
      case 'Thấp nhất':
        icon = Icons.trending_down;
        color = Colors.red[800]!;
        break;
      case 'Trung bình':
        icon = Icons.bar_chart;
        color = Colors.blue[700]!;
        break;
      case 'Tổng':
        icon = Icons.summarize;
        color = Colors.deepOrange[700]!;
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, color: color, size: 20),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (month.isNotEmpty)
          Text(
            month,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        Text(
          value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
