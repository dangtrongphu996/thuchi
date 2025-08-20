import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'lich_su_giao_dich_danh_muc_screen.dart';

enum _FilterMode { today, range, month, year }

enum _TypeFilter { all, income, expense }

class PhanTichTongHopScreen extends StatefulWidget {
  const PhanTichTongHopScreen({super.key});

  @override
  State<PhanTichTongHopScreen> createState() => _PhanTichTongHopScreenState();
}

class _PhanTichTongHopScreenState extends State<PhanTichTongHopScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();

  _FilterMode _mode = _FilterMode.month;
  _TypeFilter _typeFilter = _TypeFilter.all;
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isLoading = true;

  List<ChiTietChiTieuDanhMuc> _all = [];
  List<ChiTietChiTieuDanhMuc> _filtered = [];

  double _tongThu = 0;
  double _tongChi = 0;
  double _prevThu = 0;
  double _prevChi = 0;

  List<PieChartSectionData> _thuSections = [];
  List<PieChartSectionData> _chiSections = [];
  List<String> _thuLabels = [];
  List<String> _chiLabels = [];
  final List<Color> _palette = const [
    Colors.teal,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.indigo,
    Colors.deepOrange,
    Colors.green,
    Colors.brown,
  ];

  Color _categoryBaseColor(int categoryId) {
    final index = (categoryId.abs()) % _palette.length;
    return _palette[index];
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final list = await _dao.getAll();
    _all = List.from(list);
    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    List<ChiTietChiTieuDanhMuc> data = [];
    final now = DateTime.now();
    if (_mode == _FilterMode.today) {
      data =
          _all.where((e) {
            final d = DateTime.tryParse(e.chiTietChiTieu.ngay);
            if (d == null) return false;
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          }).toList();
    } else if (_mode == _FilterMode.range) {
      if (_startDate != null && _endDate != null) {
        final start = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        final end = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        data =
            _all.where((e) {
              final d = DateTime.tryParse(e.chiTietChiTieu.ngay);
              if (d == null) return false;
              return !d.isBefore(start) && !d.isAfter(end);
            }).toList();
      } else {
        data = [];
      }
    } else if (_mode == _FilterMode.month) {
      data =
          _all.where((e) {
            final d = DateTime.tryParse(e.chiTietChiTieu.ngay);
            if (d == null) return false;
            return d.year == _selectedYear && d.month == _selectedMonth;
          }).toList();
    } else if (_mode == _FilterMode.year) {
      data =
          _all.where((e) {
            final d = DateTime.tryParse(e.chiTietChiTieu.ngay);
            if (d == null) return false;
            return d.year == _selectedYear;
          }).toList();
    }

    data.sort(
      (a, b) => DateTime.parse(
        b.chiTietChiTieu.ngay,
      ).compareTo(DateTime.parse(a.chiTietChiTieu.ngay)),
    );
    _filtered = data;
    if (_mode == _FilterMode.month) {
      _computePrevMonthTotals();
    } else {
      _prevThu = 0;
      _prevChi = 0;
    }
    _recalcStats();
  }

  void _recalcStats() {
    double thu = 0, chi = 0;
    final Map<String, double> thuByCate = {};
    final Map<String, double> chiByCate = {};
    for (final e in _filtered) {
      if (e.danhMuc.loai == 1) {
        thu += e.chiTietChiTieu.soTien;
        thuByCate.update(
          e.danhMuc.ten,
          (v) => v + e.chiTietChiTieu.soTien,
          ifAbsent: () => e.chiTietChiTieu.soTien,
        );
      } else if (e.danhMuc.loai == 2) {
        chi += e.chiTietChiTieu.soTien;
        chiByCate.update(
          e.danhMuc.ten,
          (v) => v + e.chiTietChiTieu.soTien,
          ifAbsent: () => e.chiTietChiTieu.soTien,
        );
      }
    }
    _tongThu = thu;
    _tongChi = chi;

    _thuLabels = thuByCate.keys.toList();
    _chiLabels = chiByCate.keys.toList();
    _thuSections = _buildPieSections(thuByCate);
    _chiSections = _buildPieSections(chiByCate);
    setState(() {});
  }

  void _computePrevMonthTotals() {
    int prevMonth = _selectedMonth == 1 ? 12 : _selectedMonth - 1;
    int prevYear = _selectedMonth == 1 ? _selectedYear - 1 : _selectedYear;
    double thu = 0, chi = 0;
    for (final e in _all) {
      final d = DateTime.tryParse(e.chiTietChiTieu.ngay);
      if (d == null) continue;
      if (d.year == prevYear && d.month == prevMonth) {
        if (e.danhMuc.loai == 1) {
          thu += e.chiTietChiTieu.soTien;
        } else if (e.danhMuc.loai == 2) {
          chi += e.chiTietChiTieu.soTien;
        }
      }
    }
    _prevThu = thu;
    _prevChi = chi;
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final keys = data.keys.toList();
    final total = data.values.fold(0.0, (p, e) => p + e);
    return keys.asMap().entries.map((entry) {
      final index = entry.key;
      final key = entry.value;
      final value = data[key] ?? 0;
      final percent = total > 0 ? (value / total * 100) : 0.0;
      return PieChartSectionData(
        title: percent > 0 ? '${percent.toStringAsFixed(0)}%' : '',
        value: value,
        color: _palette[index % _palette.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      _applyFilter();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Phân tích tổng hợp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF57C785), Color.fromARGB(255, 246, 213, 82)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFilterBar(),
                      const SizedBox(height: 12),
                      _buildSummaryCards(currency),
                      const SizedBox(height: 12),
                      if (_mode == _FilterMode.month)
                        _buildDailySpendingChart(currency),
                      if (_mode == _FilterMode.month)
                        const SizedBox(height: 12),
                      _buildPieCharts(),
                      const SizedBox(height: 12),
                      _buildCategoryList(currency),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFilterBar() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<_FilterMode>(
                    value: _mode,
                    decoration: InputDecoration(
                      labelText: 'Chế độ thời gian',
                      prefixIcon: const Icon(
                        Icons.filter_alt,
                        color: Colors.deepOrange,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: _FilterMode.today,
                        child: Text('Hôm nay'),
                      ),
                      DropdownMenuItem(
                        value: _FilterMode.range,
                        child: Text('Khoảng thời gian'),
                      ),
                      DropdownMenuItem(
                        value: _FilterMode.month,
                        child: Text('Theo tháng'),
                      ),
                      DropdownMenuItem(
                        value: _FilterMode.year,
                        child: Text('Theo năm'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _mode = val);
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_mode == _FilterMode.range)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartDate,
                      icon: const Icon(
                        Icons.date_range,
                        color: Colors.deepPurple,
                      ),
                      label: Text(
                        _startDate == null
                            ? 'Từ ngày'
                            : DateFormat('dd/MM/yyyy').format(_startDate!),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.date_range, color: Colors.indigo),
                      label: Text(
                        _endDate == null
                            ? 'Đến ngày'
                            : DateFormat('dd/MM/yyyy').format(_endDate!),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            if (_mode == _FilterMode.month)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'Tháng',
                        prefixIcon: const Icon(
                          Icons.calendar_month,
                          color: Colors.teal,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      items:
                          List.generate(12, (i) => i + 1)
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text('Tháng $m'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedMonth = v);
                        _applyFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Năm',
                        prefixIcon: const Icon(Icons.event, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      items:
                          List.generate(10, (i) => DateTime.now().year - 5 + i)
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text('Năm $y'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedYear = v);
                        _applyFilter();
                      },
                    ),
                  ),
                ],
              ),
            if (_mode == _FilterMode.year)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Năm',
                        prefixIcon: const Icon(
                          Icons.event,
                          color: Colors.indigo,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      items:
                          List.generate(10, (i) => DateTime.now().year - 5 + i)
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text('Năm $y'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedYear = v);
                        _applyFilter();
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.all_inclusive, size: 16),
                      SizedBox(width: 6),
                      Text('Tất cả'),
                    ],
                  ),
                  selected: _typeFilter == _TypeFilter.all,
                  selectedColor: Colors.deepOrange,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color:
                        _typeFilter == _TypeFilter.all
                            ? Colors.white
                            : Colors.deepOrange,
                  ),
                  side: const BorderSide(color: Colors.deepOrange),
                  onSelected: (s) {
                    if (!s) return;
                    setState(() => _typeFilter = _TypeFilter.all);
                  },
                ),
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.savings, size: 16),
                      SizedBox(width: 6),
                      Text('Thu'),
                    ],
                  ),
                  selected: _typeFilter == _TypeFilter.income,
                  selectedColor: Colors.teal,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color:
                        _typeFilter == _TypeFilter.income
                            ? Colors.white
                            : Colors.teal,
                  ),
                  side: const BorderSide(color: Colors.teal),
                  onSelected: (s) {
                    if (!s) return;
                    setState(() => _typeFilter = _TypeFilter.income);
                  },
                ),
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shopping_bag, size: 16),
                      SizedBox(width: 6),
                      Text('Chi'),
                    ],
                  ),
                  selected: _typeFilter == _TypeFilter.expense,
                  selectedColor: Colors.red,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color:
                        _typeFilter == _TypeFilter.expense
                            ? Colors.white
                            : Colors.red,
                  ),
                  side: const BorderSide(color: Colors.red),
                  onSelected: (s) {
                    if (!s) return;
                    setState(() => _typeFilter = _TypeFilter.expense);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat currency) {
    final soDu = _tongThu - _tongChi;
    final prevSoDu = _prevThu - _prevChi;
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Thu nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currency.format(_tongThu),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_mode == _FilterMode.month)
                    _deltaWidget(
                      current: _tongThu,
                      previous: _prevThu,
                      upColor: Colors.green,
                      downColor: Colors.red,
                      currency: currency,
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Chi phí',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currency.format(_tongChi),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_mode == _FilterMode.month)
                    _deltaWidget(
                      current: _tongChi,
                      previous: _prevChi,
                      upColor: Colors.green,
                      downColor: Colors.red,
                      currency: currency,
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Còn lại',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currency.format(soDu),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: soDu >= 0 ? Colors.teal : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_mode == _FilterMode.month)
                    _deltaWidget(
                      current: soDu,
                      previous: prevSoDu,
                      upColor: Colors.teal,
                      downColor: Colors.red,
                      currency: currency,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _deltaWidget({
    required double current,
    required double previous,
    required Color upColor,
    required Color downColor,
    required NumberFormat currency,
  }) {
    final diff = current - previous;
    if (diff == 0) {
      return Text(
        'Không đổi so với tháng trước',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }
    final isUp = diff > 0;
    final color = isUp ? upColor : downColor;
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${currency.format(diff.abs())}',
            style: TextStyle(color: color, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDailySpendingChart(NumberFormat currency) {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final Map<int, double> dailySpending = {};

    // Initialize all days with 0
    for (int day = 1; day <= daysInMonth; day++) {
      dailySpending[day] = 0;
    }

    // Aggregate spending by day
    for (final item in _filtered) {
      if (item.danhMuc.loai == 2) {
        // Only expenses
        final day = DateTime.parse(item.chiTietChiTieu.ngay).day;
        dailySpending[day] =
            (dailySpending[day] ?? 0) + item.chiTietChiTieu.soTien;
      }
    }

    // Define representative days to show (1, 7, 14, 21, 28, 30)
    final representativeDays = <int>[1, 7, 14, 21, 28];

    // Add the last day of month if it's different from 28
    final lastDay = daysInMonth;
    if (lastDay != 28 && !representativeDays.contains(lastDay)) {
      representativeDays.add(lastDay);
    }

    // Sort days in ascending order
    representativeDays.sort();

    final spendingData =
        representativeDays
            .map((day) => MapEntry(day, dailySpending[day] ?? 0))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final maxSpending = spendingData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.trending_down, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Chi phí theo ngày trong tháng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child:
                  spendingData.isEmpty
                      ? const Center(child: Text('Không có dữ liệu'))
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval:
                                maxSpending > 0 ? maxSpending / 4 : 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final day = value.toInt();
                                  if (spendingData.any((e) => e.key == day)) {
                                    return Text(
                                      'Ngày $day',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: maxSpending > 0 ? maxSpending / 4 : 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    currency.format(value).replaceAll('đ', ''),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          minX: spendingData.first.key.toDouble(),
                          maxX: spendingData.last.key.toDouble(),
                          minY: 0,
                          maxY: maxSpending > 0 ? maxSpending * 1.2 : 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  spendingData
                                      .map(
                                        (e) =>
                                            FlSpot(e.key.toDouble(), e.value),
                                      )
                                      .toList(),
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade300],
                              ),
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.red,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.withOpacity(0.3),
                                    Colors.red.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.red.shade100,
                              tooltipRoundedRadius: 8,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((touchedSpot) {
                                  return LineTooltipItem(
                                    'Ngày ${touchedSpot.x.toInt()}\n',
                                    const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: currency.format(touchedSpot.y),
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }

  Widget _buildPieCharts() {
    final List<Widget> children = [];
    if (_typeFilter != _TypeFilter.expense) {
      children.add(
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.savings, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Thu nhập theo danh mục',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child:
                      _thuSections.isEmpty
                          ? const Center(child: Text('Không có dữ liệu'))
                          : PieChart(
                            PieChartData(
                              sections: _thuSections,
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                ),
                const SizedBox(height: 8),
                _buildLegend(_thuSections, _thuLabels),
              ],
            ),
          ),
        ),
      );
    }
    if (_typeFilter != _TypeFilter.income) {
      children.add(
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shopping_bag, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Chi phí theo danh mục',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child:
                      _chiSections.isEmpty
                          ? const Center(child: Text('Không có dữ liệu'))
                          : PieChart(
                            PieChartData(
                              sections: _chiSections,
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                ),
                const SizedBox(height: 8),
                _buildLegend(_chiSections, _chiLabels),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildLegend(List<PieChartSectionData> sections, List<String> labels) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (int i = 0; i < sections.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: sections[i].color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(labels.length > i ? labels[i] : ''),
            ],
          ),
      ],
    );
  }

  Widget _buildCategoryList(NumberFormat currency) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Danh mục (theo bộ lọc)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Center(child: Text('Không có dữ liệu')),
            )
          else
            Builder(
              builder: (context) {
                final Map<int, Map<String, dynamic>> categoryAgg = {};
                double totalIncome = 0;
                double totalExpense = 0;
                for (final item in _filtered) {
                  if (_typeFilter == _TypeFilter.income &&
                      item.danhMuc.loai != 1)
                    continue;
                  if (_typeFilter == _TypeFilter.expense &&
                      item.danhMuc.loai != 2)
                    continue;
                  final categoryId = item.danhMuc.id ?? -1;
                  final isIncome = item.danhMuc.loai == 1;
                  final amount = item.chiTietChiTieu.soTien;
                  if (isIncome)
                    totalIncome += amount;
                  else
                    totalExpense += amount;
                  categoryAgg.update(
                    categoryId,
                    (curr) {
                      final newTotal = (curr['total'] as double) + amount;
                      final newCount = (curr['count'] as int) + 1;
                      return {
                        'name': curr['name'],
                        'type': curr['type'],
                        'total': newTotal,
                        'count': newCount,
                      };
                    },
                    ifAbsent:
                        () => {
                          'name': item.danhMuc.ten,
                          'type': item.danhMuc.loai, // 1 thu, 2 chi
                          'total': amount,
                          'count': 1,
                        },
                  );
                }
                final entries =
                    categoryAgg.entries.toList()..sort(
                      (a, b) => (b.value['total'] as double).compareTo(
                        a.value['total'] as double,
                      ),
                    );
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final categoryId = entry.key;
                    final name = entry.value['name'] as String;
                    final type = entry.value['type'] as int;
                    final total = entry.value['total'] as double;
                    final count = entry.value['count'] as int;
                    final isIncome = type == 1;
                    final totalByType = isIncome ? totalIncome : totalExpense;
                    final percent =
                        totalByType > 0 ? (total / totalByType * 100) : 0.0;
                    final sampleDanhMuc =
                        _filtered
                            .firstWhere(
                              (e) => (e.danhMuc.id ?? -1) == categoryId,
                            )
                            .danhMuc;
                    final baseColor = _categoryBaseColor(categoryId);
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [baseColor, baseColor.withOpacity(0.65)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: baseColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: baseColor.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              (sampleDanhMuc.icon ?? '').isNotEmpty
                                  ? sampleDanhMuc.icon!.characters.first
                                  : (isIncome ? 'T' : 'C'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Icon(
                                isIncome ? Icons.savings : Icons.shopping_bag,
                                size: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isIncome ? Colors.green : Colors.red)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isIncome ? 'Thu' : 'Chi',
                              style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count giao dịch • ${percent.toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                      trailing: Text(
                        currency.format(total),
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => LichSuGiaoDichDanhMucScreen(
                                  danhMuc: sampleDanhMuc,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
