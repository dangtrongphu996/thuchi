import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import 'dart:math';
import 'thong_ke_chi_tieu_tu_ngay_screen.dart';
import 'all_transactions_screen.dart';
import 'giao_dich_danh_muc_giai_doan_screen.dart';

class BaoCaoTongHopScreen extends StatefulWidget {
  const BaoCaoTongHopScreen({super.key});

  @override
  State<BaoCaoTongHopScreen> createState() => _BaoCaoTongHopScreenState();
}

class _BaoCaoTongHopScreenState extends State<BaoCaoTongHopScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  String _mode = 'Tuần'; // Tuần, Quý, Năm
  int _selectedYear = DateTime.now().year;
  int _selectedQuarter = 1;
  int _selectedWeek = 1;
  List<_PeriodStat> _stats = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final all = await _dao.getAll();
    List<_PeriodStat> stats = [];
    if (_mode == 'Tuần') {
      // Lấy các tuần trong năm
      final weeks = List.generate(53, (i) => i + 1);
      for (final week in weeks) {
        final period = _getWeekRange(_selectedYear, week);
        final items =
            all.where((e) {
              final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
              return ngay != null &&
                  ngay.isAfter(
                    period.start.subtract(const Duration(days: 1)),
                  ) &&
                  ngay.isBefore(period.end.add(const Duration(days: 1)));
            }).toList();
        if (items.isEmpty) continue;
        double thu = 0, chi = 0;
        for (var ct in items) {
          if (ct.danhMuc.loai == 1)
            thu += ct.chiTietChiTieu.soTien;
          else
            chi += ct.chiTietChiTieu.soTien;
        }
        stats.add(
          _PeriodStat(
            label: 'Tuần $week',
            start: period.start,
            end: period.end,
            thu: thu,
            chi: chi,
          ),
        );
      }
    } else if (_mode == 'Tháng') {
      for (int m = 1; m <= 12; m++) {
        final start = DateTime(_selectedYear, m, 1);
        final end = DateTime(_selectedYear, m + 1, 0);
        final items =
            all.where((e) {
              final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
              return ngay != null &&
                  !ngay.isBefore(start) &&
                  !ngay.isAfter(end);
            }).toList();
        if (items.isEmpty) continue;
        double thu = 0, chi = 0;
        for (var ct in items) {
          if (ct.danhMuc.loai == 1)
            thu += ct.chiTietChiTieu.soTien;
          else
            chi += ct.chiTietChiTieu.soTien;
        }
        stats.add(
          _PeriodStat(
            label: 'Tháng $m',
            start: start,
            end: end,
            thu: thu,
            chi: chi,
          ),
        );
      }
    } else if (_mode == 'Quý') {
      for (int q = 1; q <= 4; q++) {
        final startMonth = (q - 1) * 3 + 1;
        final endMonth = q * 3;
        final start = DateTime(_selectedYear, startMonth, 1);
        final end = DateTime(_selectedYear, endMonth + 1, 0);
        final items =
            all.where((e) {
              final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
              return ngay != null &&
                  !ngay.isBefore(start) &&
                  !ngay.isAfter(end);
            }).toList();
        if (items.isEmpty) continue;
        double thu = 0, chi = 0;
        for (var ct in items) {
          if (ct.danhMuc.loai == 1)
            thu += ct.chiTietChiTieu.soTien;
          else
            chi += ct.chiTietChiTieu.soTien;
        }
        stats.add(
          _PeriodStat(
            label: 'Quý $q',
            start: start,
            end: end,
            thu: thu,
            chi: chi,
          ),
        );
      }
    } else {
      // Năm
      for (int y = _selectedYear - 4; y <= _selectedYear; y++) {
        final items =
            all.where((e) {
              final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
              return ngay != null && ngay.year == y;
            }).toList();
        if (items.isEmpty) continue;
        double thu = 0, chi = 0;
        for (var ct in items) {
          if (ct.danhMuc.loai == 1)
            thu += ct.chiTietChiTieu.soTien;
          else
            chi += ct.chiTietChiTieu.soTien;
        }
        stats.add(
          _PeriodStat(
            label: 'Năm $y',
            start: DateTime(y, 1, 1),
            end: DateTime(y, 12, 31),
            thu: thu,
            chi: chi,
          ),
        );
      }
    }
    setState(() {
      _stats = stats;
      isLoading = false;
    });
  }

  _WeekRange _getWeekRange(int year, int week) {
    final firstDay = DateTime(year, 1, 1);
    final daysToAdd = ((week - 1) * 7) - (firstDay.weekday - 1);
    final start = firstDay.add(Duration(days: daysToAdd));
    final end = start.add(const Duration(days: 6));
    return _WeekRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tổng hợp'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown chọn chế độ và năm
                    Card(
                      color: Colors.deepPurple.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                value: _mode,
                                decoration: InputDecoration(
                                  labelText: 'Chế độ',
                                  prefixIcon: Icon(
                                    Icons.timeline,
                                    color: Colors.deepPurple,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 8,
                                  ),
                                ),
                                items:
                                    ['Tuần', 'Tháng', 'Quý', 'Năm']
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _mode = v);
                                    _loadData();
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: DropdownButtonFormField<int>(
                                value: _selectedYear,
                                decoration: InputDecoration(
                                  labelText: 'Năm',
                                  prefixIcon: Icon(
                                    Icons.date_range,
                                    color: Colors.deepPurple,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 8,
                                  ),
                                ),
                                items:
                                    List.generate(
                                          10,
                                          (i) => DateTime.now().year - 9 + i,
                                        )
                                        .map(
                                          (y) => DropdownMenuItem(
                                            value: y,
                                            child: Text('Năm $y'),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedYear = v);
                                    _loadData();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_stats.isNotEmpty)
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Biểu đồ xu hướng thu/chi/số dư',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 220,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Builder(
                                    builder: (context) {
                                      final statsForChart =
                                          _stats.reversed.toList();
                                      return LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            horizontalInterval: _getYInterval(),
                                            getDrawingHorizontalLine:
                                                (value) => FlLine(
                                                  color: Colors.grey.shade200,
                                                  strokeWidth: 1,
                                                ),
                                            getDrawingVerticalLine:
                                                (value) => FlLine(
                                                  color: Colors.grey.shade100,
                                                  strokeWidth: 1,
                                                ),
                                          ),
                                          minY: _getMinY(statsForChart),
                                          maxY: _getMaxY(statsForChart),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 52,
                                                getTitlesWidget: (value, meta) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 4,
                                                          top: 4,
                                                          bottom: 4,
                                                        ),
                                                    child: Text(
                                                      _formatMoneyShort(value),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                interval: _getYInterval() * 2,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final idx = value.toInt();
                                                  if (statsForChart.isEmpty ||
                                                      idx < 0 ||
                                                      idx >=
                                                          statsForChart.length)
                                                    return const SizedBox();
                                                  // Chỉ hiển thị cho tuần đầu, giữa, cuối, hoặc cách 4 tuần
                                                  if (idx == 0 ||
                                                      idx ==
                                                          statsForChart.length -
                                                              1 ||
                                                      idx ==
                                                          (statsForChart
                                                                  .length ~/
                                                              2) ||
                                                      idx % 4 == 0) {
                                                    return Transform.rotate(
                                                      angle: -pi / 6,
                                                      child: Text(
                                                        statsForChart[idx]
                                                            .label,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox();
                                                },
                                                interval: 1,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(
                                              color: Colors.deepPurple.shade100,
                                              width: 1.5,
                                            ),
                                          ),
                                          lineTouchData: LineTouchData(
                                            touchTooltipData: LineTouchTooltipData(
                                              tooltipBgColor: Colors.yellow,
                                              getTooltipItems: (touchedSpots) {
                                                return touchedSpots.map((
                                                  LineBarSpot touchedSpot,
                                                ) {
                                                  final idx =
                                                      touchedSpot.x.toInt();
                                                  if (idx < 0 ||
                                                      idx >=
                                                          statsForChart.length)
                                                    return null;
                                                  final stat =
                                                      statsForChart[idx];
                                                  String label = stat.label;
                                                  String value = '';
                                                  Color color;
                                                  switch (touchedSpot
                                                      .barIndex) {
                                                    case 0:
                                                      value =
                                                          'Thu: ' +
                                                          _formatMoneyShort(
                                                            stat.thu,
                                                          );
                                                      color = Colors.green;
                                                      break;
                                                    case 1:
                                                      value =
                                                          'Chi: ' +
                                                          _formatMoneyShort(
                                                            stat.chi,
                                                          );
                                                      color = Colors.red;
                                                      break;
                                                    case 2:
                                                      value =
                                                          'Số dư: ' +
                                                          _formatMoneyShort(
                                                            stat.thu - stat.chi,
                                                          );
                                                      color = Colors.blue;
                                                      break;
                                                    default:
                                                      value =
                                                          'Giá trị: ' +
                                                          touchedSpot.y
                                                              .toStringAsFixed(
                                                                0,
                                                              );
                                                      color = Colors.black;
                                                  }
                                                  return LineTooltipItem(
                                                    '$label\n$value',
                                                    TextStyle(
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                            ),
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: [
                                                for (
                                                  int i = 0;
                                                  i < statsForChart.length;
                                                  i++
                                                )
                                                  FlSpot(
                                                    i.toDouble(),
                                                    statsForChart[i].thu,
                                                  ),
                                              ],
                                              isCurved: true,
                                              color: Colors.green,
                                              barWidth: 4,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter:
                                                    (
                                                      spot,
                                                      percent,
                                                      bar,
                                                      index,
                                                    ) => FlDotCirclePainter(
                                                      radius: 5,
                                                      color: Colors.green,
                                                      strokeWidth: 1.5,
                                                      strokeColor: Colors.white,
                                                    ),
                                              ),
                                              belowBarData: BarAreaData(
                                                show: false,
                                              ),
                                            ),
                                            LineChartBarData(
                                              spots: [
                                                for (
                                                  int i = 0;
                                                  i < statsForChart.length;
                                                  i++
                                                )
                                                  FlSpot(
                                                    i.toDouble(),
                                                    statsForChart[i].chi,
                                                  ),
                                              ],
                                              isCurved: true,
                                              color: Colors.redAccent,
                                              barWidth: 4,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter:
                                                    (
                                                      spot,
                                                      percent,
                                                      bar,
                                                      index,
                                                    ) => FlDotCirclePainter(
                                                      radius: 5,
                                                      color: Colors.redAccent,
                                                      strokeWidth: 1.5,
                                                      strokeColor: Colors.white,
                                                    ),
                                              ),
                                              belowBarData: BarAreaData(
                                                show: false,
                                              ),
                                            ),
                                            LineChartBarData(
                                              spots: [
                                                for (
                                                  int i = 0;
                                                  i < statsForChart.length;
                                                  i++
                                                )
                                                  FlSpot(
                                                    i.toDouble(),
                                                    statsForChart[i].thu -
                                                        statsForChart[i].chi,
                                                  ),
                                              ],
                                              isCurved: true,
                                              color: Colors.blue,
                                              barWidth: 4,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter:
                                                    (
                                                      spot,
                                                      percent,
                                                      bar,
                                                      index,
                                                    ) => FlDotCirclePainter(
                                                      radius: 5,
                                                      color: Colors.blue,
                                                      strokeWidth: 1.5,
                                                      strokeColor: Colors.white,
                                                    ),
                                              ),
                                              belowBarData: BarAreaData(
                                                show: false,
                                              ),
                                            ),
                                          ],
                                          clipData: FlClipData.all(),
                                          extraLinesData: ExtraLinesData(
                                            horizontalLines: [],
                                          ),
                                          minX: 0,
                                          maxX:
                                              statsForChart.isNotEmpty
                                                  ? (statsForChart.length - 1)
                                                      .toDouble()
                                                  : 0,
                                          // padding top/bottom
                                          baselineY: 0,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegend('Thu nhập', Colors.green),
                                  SizedBox(width: 12),
                                  _buildLegend('Chi phí', Colors.redAccent),
                                  SizedBox(width: 12),
                                  _buildLegend('Số dư', Colors.blue),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (_stats.isNotEmpty)
                      Card(
                        color: Colors.deepPurple.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'So sánh các giai đoạn',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._buildSummaryRows(reverse: true),
                            ],
                          ),
                        ),
                      ),
                    if (_stats.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Không có dữ liệu cho giai đoạn này',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 8, color: color),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildSummaryRows({bool reverse = false}) {
    List<Widget> rows = [];
    for (int i = 0; i < _stats.length; i++) {
      final stat = _stats[i];
      final prev = i > 0 ? _stats[i - 1] : null;
      double pctThu = 0, pctChi = 0, pctDu = 0;
      if (prev != null) {
        pctThu = prev.thu == 0 ? 0 : ((stat.thu - prev.thu) / prev.thu) * 100;
        pctChi = prev.chi == 0 ? 0 : ((stat.chi - prev.chi) / prev.chi) * 100;
        pctDu =
            (prev.thu - prev.chi) == 0
                ? 0
                : (((stat.thu - stat.chi) - (prev.thu - prev.chi)) /
                        (prev.thu - prev.chi)) *
                    100;
      }
      rows.add(
        InkWell(
          onTap: () {
            if (_mode == 'Tuần') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ThongKeChiTieuTuNgayScreen(
                        fromDate: stat.start,
                        toDate: stat.end,
                      ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BaoCaoChiTietGiaiDoanScreen(
                        start: stat.start,
                        end: stat.end,
                        label: stat.label,
                      ),
                ),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 15,
                    ),
                  ),
                  if (_mode == 'Tuần')
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Text(
                        '${DateFormat('dd/MM/yyyy').format(stat.start)} - ${DateFormat('dd/MM/yyyy').format(stat.end)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Thu: ',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${stat.thu.toStringAsFixed(0)} đ',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (prev != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '(${pctThu >= 0 ? '+' : ''}${pctThu.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: pctThu >= 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Chi: ',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${stat.chi.toStringAsFixed(0)} đ',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (prev != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '(${pctChi >= 0 ? '+' : ''}${pctChi.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: pctChi >= 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.blue,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Số dư: ',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(stat.thu - stat.chi).toStringAsFixed(0)} đ',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (prev != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '(${pctDu >= 0 ? '+' : ''}${pctDu.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: pctDu >= 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (reverse) {
      return rows.reversed.toList();
    }
    return rows;
  }

  String _formatMoneyShort(num value) {
    if (value.abs() >= 1000000) {
      return (value / 1000000).toStringAsFixed(1).replaceAll('.0', '') + 'M';
    } else if (value.abs() >= 1000) {
      return (value / 1000).toStringAsFixed(1).replaceAll('.0', '') + 'K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  double _getMaxY([List<_PeriodStat>? stats]) {
    final list = stats ?? _stats;
    if (list.isEmpty) return 1;
    final maxVal = [
      ...list.map((e) => e.thu),
      ...list.map((e) => e.chi),
      ...list.map((e) => e.thu - e.chi),
    ].reduce(max);
    return maxVal > 0 ? maxVal * 1.15 : 1;
  }

  double _getMinY([List<_PeriodStat>? stats]) {
    final list = stats ?? _stats;
    if (list.isEmpty) return 0;
    final minVal = [
      ...list.map((e) => e.thu),
      ...list.map((e) => e.chi),
      ...list.map((e) => e.thu - e.chi),
    ].reduce(min);
    return minVal < 0 ? minVal * 1.15 : 0;
  }

  double _getYInterval() {
    final maxY = _getMaxY();
    final minY = _getMinY();
    final range = (maxY - minY).abs();
    if (range > 10000000) return 2000000;
    if (range > 1000000) return 200000;
    if (range > 100000) return 20000;
    if (range > 10000) return 2000;
    if (range > 1000) return 200;
    if (range > 100) return 20;
    return 10;
  }
}

class _PeriodStat {
  final String label;
  final DateTime start;
  final DateTime end;
  final double thu;
  final double chi;
  _PeriodStat({
    required this.label,
    required this.start,
    required this.end,
    required this.thu,
    required this.chi,
  });
}

class _WeekRange {
  final DateTime start;
  final DateTime end;
  _WeekRange(this.start, this.end);
}

class BaoCaoChiTietGiaiDoanScreen extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final String label;
  const BaoCaoChiTietGiaiDoanScreen({
    super.key,
    required this.start,
    required this.end,
    required this.label,
  });

  @override
  State<BaoCaoChiTietGiaiDoanScreen> createState() =>
      _BaoCaoChiTietGiaiDoanScreenState();
}

class _BaoCaoChiTietGiaiDoanScreenState
    extends State<BaoCaoChiTietGiaiDoanScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  List<Map<String, dynamic>> _danhMucStats = [];
  double tongThu = 0;
  double tongChi = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final all = await _dao.getAll();
    final danhMucs = await _dmDao.getAllDanhMuc();
    // Lọc theo giai đoạn
    final filtered =
        all.where((e) {
          final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
          return ngay != null &&
              !ngay.isBefore(widget.start) &&
              !ngay.isAfter(widget.end);
        }).toList();
    // Gom nhóm theo danh mục
    Map<int, double> tongTienTheoDanhMuc = {};
    Map<int, DanhMuc> danhMucMap = {for (var dm in danhMucs) dm.id!: dm};
    for (var item in filtered) {
      final id = item.chiTietChiTieu.danhMucId;
      tongTienTheoDanhMuc[id] =
          (tongTienTheoDanhMuc[id] ?? 0) + item.chiTietChiTieu.soTien;
    }
    // Tạo danh sách thống kê
    List<Map<String, dynamic>> stats =
        tongTienTheoDanhMuc.entries.map((e) {
          final dm = danhMucMap[e.key];
          return {
            'id': e.key,
            'ten': dm?.ten ?? '',
            'icon': dm?.icon ?? '',
            'loai': dm?.loai ?? 2,
            'tong': e.value,
          };
        }).toList();
    // Sắp xếp: thu trước, chi sau, mỗi nhóm giảm dần theo số tiền
    stats.sort((a, b) {
      if (a['loai'] != b['loai']) return a['loai'] - b['loai'];
      return (b['tong'] as double).compareTo(a['tong'] as double);
    });
    tongThu = stats
        .where((e) => e['loai'] == 1)
        .fold(0.0, (p, e) => p + (e['tong'] as double));
    tongChi = stats
        .where((e) => e['loai'] == 2)
        .fold(0.0, (p, e) => p + (e['tong'] as double));
    setState(() {
      _danhMucStats = stats;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ${widget.label}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Colors.deepPurple.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Tổng thu',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${tongThu.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Tổng chi',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${tongChi.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Số dư',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${(tongThu - tongChi).toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_danhMucStats.isEmpty)
                      Center(
                        child: Text(
                          'Không có giao dịch nào trong giai đoạn này',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    if (_danhMucStats.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _danhMucStats.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final dm = _danhMucStats[index];
                          final isThu = dm['loai'] == 1;
                          final Color mainColor =
                              isThu ? Colors.green : Colors.redAccent;
                          final Color bgColor =
                              isThu
                                  ? Colors.green.shade100
                                  : Colors.red.shade100;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => GiaoDichDanhMucGiaiDoanScreen(
                                        danhMucId: dm['id'],
                                        tenDanhMuc: dm['ten'],
                                        loai: dm['loai'],
                                        start: widget.start,
                                        end: widget.end,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: bgColor,
                                      radius: 28,
                                      child: Text(
                                        dm['icon'] ?? '',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        dm['ten'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '${dm['tong'].toStringAsFixed(0)} đ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: mainColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
    );
  }
}
