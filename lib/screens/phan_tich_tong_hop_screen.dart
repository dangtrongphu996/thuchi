import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'lich_su_giao_dich_danh_muc_screen.dart';
import 'thong_ke_nam_danh_muc_screen.dart';
import 'thong_ke_thang_danh_muc_screen.dart';

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
  bool _useShortNumberFormat = false;
  String? _errorMessage;

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

  String _formatCurrency(double value, {bool withSymbol = true}) {
    if (_useShortNumberFormat) {
      return _formatShortNumber(value, withSymbol: withSymbol);
    }
    final formatted = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: withSymbol ? 'đ' : '',
      decimalDigits: 0,
    ).format(value);
    return withSymbol ? formatted : formatted.replaceAll('đ', '').trim();
  }

  String _formatNumber(num value, {bool withSymbol = false}) {
    return _formatCurrency(value.toDouble(), withSymbol: withSymbol);
  }

  String _formatShortNumber(double value, {bool withSymbol = true}) {
    final abs = value.abs();
    String suffix;
    double numPart;
    if (abs >= 1e9) {
      numPart = value / 1e9;
      suffix = 'B';
    } else if (abs >= 1e6) {
      numPart = value / 1e6;
      suffix = 'M';
    } else if (abs >= 1e3) {
      numPart = value / 1e3;
      suffix = 'k';
    } else {
      numPart = value;
      suffix = '';
    }
    final fixed =
        numPart >= 100 || numPart == numPart.roundToDouble()
            ? numPart.toStringAsFixed(0)
            : numPart.toStringAsFixed(1);
    return withSymbol ? '$fixed$suffix đ' : '$fixed$suffix';
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _dao.getAll();
      _all = List.from(list);
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    _recalcStats();
  }

  void _recalcStats() {
    double thu = 0, chi = 0;
    final Map<String, double> thuByCate = {};
    final Map<String, double> chiByCate = {};
    for (final e in _filtered) {
      if (e.danhMuc.loai == 1) {
        thu += e.chiTietChiTieu.soTien;
        final cateName = e.danhMuc.ten;
        thuByCate[cateName] =
            (thuByCate[cateName] ?? 0) + e.chiTietChiTieu.soTien;
      } else if (e.danhMuc.loai == 2) {
        chi += e.chiTietChiTieu.soTien;
        final cateName = e.danhMuc.ten;
        chiByCate[cateName] =
            (chiByCate[cateName] ?? 0) + e.chiTietChiTieu.soTien;
      }
    }
    setState(() {
      _tongThu = thu;
      _tongChi = chi;
      _thuLabels = thuByCate.keys.toList();
      _chiLabels = chiByCate.keys.toList();
      _thuSections = _buildPieSections(thuByCate);
      _chiSections = _buildPieSections(chiByCate);
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadAll();
            },
            tooltip: 'Làm mới dữ liệu',
          ),
          PopupMenuButton<String>(
            tooltip: 'Tùy chọn hiển thị',
            onSelected: (val) {
              if (val == 'toggle_number_format') {
                setState(() => _useShortNumberFormat = !_useShortNumberFormat);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'toggle_number_format',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.format_list_numbered,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _useShortNumberFormat
                              ? 'Định dạng số: Đầy đủ'
                              : 'Định dạng số: Ngắn',
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilterBar(),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadAll,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isLoading)
                _buildSkeletonSummaryCards()
              else
                _buildSummaryCards(currency),
              const SizedBox(height: 12),
              if (_mode == _FilterMode.month) ...[
                if (_isLoading)
                  _buildSkeletonChart(color: Colors.green.shade100)
                else if (_typeFilter == _TypeFilter.all ||
                    _typeFilter == _TypeFilter.income)
                  _buildDailyIncomeChart(currency),
                if (_isLoading)
                  const SizedBox(height: 12)
                else if (_typeFilter == _TypeFilter.all ||
                    _typeFilter == _TypeFilter.expense)
                  _buildDailySpendingChart(currency),
                const SizedBox(height: 12),
              ],
              if (_isLoading)
                _buildSkeletonChart(color: Colors.blueGrey.shade100)
              else
                _buildPieCharts(),
              const SizedBox(height: 12),
              if (_isLoading)
                _buildSkeletonList()
              else
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
    final balanceColor = soDu >= 0 ? Colors.green : Colors.red;
    final balanceIcon = soDu >= 0 ? Icons.trending_up : Icons.trending_down;

    // Calculate proportions and deltas for tooltips
    final monthProportion =
        _mode == _FilterMode.month ? _calculateMonthProportion() : null;
    final yearProportion =
        _mode == _FilterMode.year ? _calculateYearProportion() : null;
    final previousPeriodDelta = _calculatePreviousPeriodDelta();

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: Tooltip(
              message: _buildIncomeTooltip(
                monthProportion,
                yearProportion,
                previousPeriodDelta['income'],
              ),
              waitDuration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Thu nhập',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(_tongThu),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (previousPeriodDelta['income'] != null)
                      Text(
                        _formatDelta(previousPeriodDelta['income']!),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              previousPeriodDelta['income']! >= 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: Colors.red.shade50,
            child: Tooltip(
              message: _buildExpenseTooltip(
                monthProportion,
                yearProportion,
                previousPeriodDelta['expense'],
              ),
              waitDuration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.trending_down,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chi phí',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(_tongChi),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    if (previousPeriodDelta['expense'] != null)
                      Text(
                        _formatDelta(previousPeriodDelta['expense']!),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              previousPeriodDelta['expense']! >= 0
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: balanceColor.shade50,
            child: Tooltip(
              message: _buildBalanceTooltip(
                monthProportion,
                yearProportion,
                previousPeriodDelta['balance'],
              ),
              waitDuration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(balanceIcon, color: balanceColor, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'Còn lại',
                      style: TextStyle(fontSize: 12, color: balanceColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(soDu),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                    if (previousPeriodDelta['balance'] != null)
                      Text(
                        _formatDelta(previousPeriodDelta['balance']!),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              previousPeriodDelta['balance']! >= 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for tooltip calculations
  Map<String, double?> _calculatePreviousPeriodDelta() {
    if (_mode == _FilterMode.month) {
      final previousMonth = DateTime(_selectedYear, _selectedMonth - 1);
      final previousData =
          _all.where((item) {
            final itemDate = DateTime.parse(item.chiTietChiTieu.ngay);
            return itemDate.year == previousMonth.year &&
                itemDate.month == previousMonth.month;
          }).toList();

      final prevIncome = previousData
          .where((item) => item.danhMuc.loai == 1)
          .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
      final prevExpense = previousData
          .where((item) => item.danhMuc.loai == 2)
          .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
      final prevBalance = prevIncome - prevExpense;

      return {
        'income': _tongThu - prevIncome,
        'expense': _tongChi - prevExpense,
        'balance': (_tongThu - _tongChi) - prevBalance,
      };
    } else if (_mode == _FilterMode.year) {
      final previousYear = _selectedYear - 1;
      final previousData =
          _all.where((item) {
            final itemDate = DateTime.parse(item.chiTietChiTieu.ngay);
            return itemDate.year == previousYear;
          }).toList();

      final prevIncome = previousData
          .where((item) => item.danhMuc.loai == 1)
          .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
      final prevExpense = previousData
          .where((item) => item.danhMuc.loai == 2)
          .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
      final prevBalance = prevIncome - prevExpense;

      return {
        'income': _tongThu - prevIncome,
        'expense': _tongChi - prevExpense,
        'balance': (_tongThu - _tongChi) - prevBalance,
      };
    } else if (_mode == _FilterMode.range &&
        _startDate != null &&
        _endDate != null) {
      final previousRange = _endDate!.difference(_startDate!);
      final previousStart = _startDate!.subtract(previousRange);
      final previousEnd = _startDate!;

      final previousData =
          _all.where((item) {
            final itemDate = DateTime.parse(item.chiTietChiTieu.ngay);
            return itemDate.isAfter(
                  previousStart.subtract(const Duration(days: 1)),
                ) &&
                itemDate.isBefore(previousEnd.add(const Duration(days: 1)));
          }).toList();

      final prevIncome = previousData
          .where((item) => item.danhMuc.loai == 1)
          .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
      final prevExpense = previousData
          .where((item) => item.danhMuc.loai == 2)
          .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
      final prevBalance = prevIncome - prevExpense;

      return {
        'income': _tongThu - prevIncome,
        'expense': _tongChi - prevExpense,
        'balance': (_tongThu - _tongChi) - prevBalance,
      };
    }
    return {'income': null, 'expense': null, 'balance': null};
  }

  double? _calculateMonthProportion() {
    if (_mode != _FilterMode.month) return null;

    final yearData =
        _all.where((item) {
          final itemDate = DateTime.parse(item.chiTietChiTieu.ngay);
          return itemDate.year == _selectedYear;
        }).toList();

    final yearIncome = yearData
        .where((item) => item.danhMuc.loai == 1)
        .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
    final yearExpense = yearData
        .where((item) => item.danhMuc.loai == 2)
        .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);

    if (yearIncome > 0) return (_tongThu / yearIncome) * 100;
    if (yearExpense > 0) return (_tongChi / yearExpense) * 100;
    return null;
  }

  double? _calculateYearProportion() {
    if (_mode != _FilterMode.year) return null;

    final allData = _all;
    final totalIncome = allData
        .where((item) => item.danhMuc.loai == 1)
        .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);
    final totalExpense = allData
        .where((item) => item.danhMuc.loai == 2)
        .fold(0.0, (sum, item) => sum + item.chiTietChiTieu.soTien);

    if (totalIncome > 0) return (_tongThu / totalIncome) * 100;
    if (totalExpense > 0) return (_tongChi / totalExpense) * 100;
    return null;
  }

  String _formatDelta(double delta) {
    final prefix = delta >= 0 ? '+' : '';
    return '$prefix${_formatCurrency(delta.abs())}';
  }

  String _buildIncomeTooltip(
    double? monthProportion,
    double? yearProportion,
    double? delta,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('💰 THU NHẬP CHI TIẾT 💰');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (delta != null) {
      final period =
          _mode == _FilterMode.month
              ? 'tháng trước'
              : _mode == _FilterMode.year
              ? 'năm trước'
              : 'kỳ trước';
      final deltaIcon = delta >= 0 ? '📈' : '📉';
      buffer.writeln(
        '$deltaIcon Chênh lệch so với $period: ${_formatDelta(delta)}',
      );
    }

    // Thêm thông tin về số lượng giao dịch
    final incomeTransactions =
        _filtered.where((item) => item.danhMuc.loai == 1).length;
    buffer.writeln('📊 Số giao dịch: $incomeTransactions');

    // Thêm thông tin về trung bình
    if (incomeTransactions > 0) {
      final average = _tongThu / incomeTransactions;
      buffer.writeln('📊 Trung bình/giao dịch: ${_formatCurrency(average)}');
    }

    if (monthProportion != null) {
      buffer.writeln(
        '📅 Tỉ trọng trong năm: ${monthProportion.toStringAsFixed(1)}%',
      );
    }

    if (yearProportion != null) {
      buffer.writeln(
        '📅 Tỉ trọng tổng thể: ${yearProportion.toStringAsFixed(1)}%',
      );
    }

    // Thêm thông tin về danh mục lớn nhất
    final incomeByCategory = <String, double>{};
    for (final item in _filtered.where((item) => item.danhMuc.loai == 1)) {
      final categoryName = item.danhMuc.ten;
      incomeByCategory[categoryName] =
          (incomeByCategory[categoryName] ?? 0) + item.chiTietChiTieu.soTien;
    }

    if (incomeByCategory.isNotEmpty) {
      final topCategory = incomeByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      buffer.writeln('🏆 Danh mục lớn nhất: ${topCategory.key}');
      buffer.writeln('   (${_formatCurrency(topCategory.value)})');
    }

    return buffer.toString().trim();
  }

  String _buildExpenseTooltip(
    double? monthProportion,
    double? yearProportion,
    double? delta,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('💸 CHI PHÍ CHI TIẾT 💸');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (delta != null) {
      final period =
          _mode == _FilterMode.month
              ? 'tháng trước'
              : _mode == _FilterMode.year
              ? 'năm trước'
              : 'kỳ trước';
      final deltaIcon = delta >= 0 ? '📈' : '📉';
      buffer.writeln(
        '$deltaIcon Chênh lệch so với $period: ${_formatDelta(delta)}',
      );
    }

    // Thêm thông tin về số lượng giao dịch
    final expenseTransactions =
        _filtered.where((item) => item.danhMuc.loai == 2).length;
    buffer.writeln('📊 Số giao dịch: $expenseTransactions');

    // Thêm thông tin về trung bình
    if (expenseTransactions > 0) {
      final average = _tongChi / expenseTransactions;
      buffer.writeln('📊 Trung bình/giao dịch: ${_formatCurrency(average)}');
    }

    if (monthProportion != null) {
      buffer.writeln(
        '📅 Tỉ trọng trong năm: ${monthProportion.toStringAsFixed(1)}%',
      );
    }

    if (yearProportion != null) {
      buffer.writeln(
        '📅 Tỉ trọng tổng thể: ${yearProportion.toStringAsFixed(1)}%',
      );
    }

    // Thêm thông tin về danh mục lớn nhất
    final expenseByCategory = <String, double>{};
    for (final item in _filtered.where((item) => item.danhMuc.loai == 2)) {
      final categoryName = item.danhMuc.ten;
      expenseByCategory[categoryName] =
          (expenseByCategory[categoryName] ?? 0) + item.chiTietChiTieu.soTien;
    }

    if (expenseByCategory.isNotEmpty) {
      final topCategory = expenseByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      buffer.writeln('🏆 Danh mục lớn nhất: ${topCategory.key}');
      buffer.writeln('   (${_formatCurrency(topCategory.value)})');
    }

    return buffer.toString().trim();
  }

  String _buildBalanceTooltip(
    double? monthProportion,
    double? yearProportion,
    double? delta,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('💳 SỐ DƯ CHI TIẾT 💳');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (delta != null) {
      final period =
          _mode == _FilterMode.month
              ? 'tháng trước'
              : _mode == _FilterMode.year
              ? 'năm trước'
              : 'kỳ trước';
      final deltaIcon = delta >= 0 ? '📈' : '📉';
      buffer.writeln(
        '$deltaIcon Chênh lệch so với $period: ${_formatDelta(delta)}',
      );
    }

    final balance = _tongThu - _tongChi;
    if (balance > 0) {
      buffer.writeln('✅ Tiết kiệm: ${_formatCurrency(balance)}');

      // Thêm thông tin về tỷ lệ tiết kiệm
      final savingsRate = (balance / _tongThu) * 100;
      buffer.writeln('📊 Tỷ lệ tiết kiệm: ${savingsRate.toStringAsFixed(1)}%');
    } else if (balance < 0) {
      buffer.writeln('⚠️ Chi tiêu vượt: ${_formatCurrency(balance.abs())}');

      // Thêm thông tin về tỷ lệ chi tiêu vượt
      final overspendingRate = (balance.abs() / _tongThu) * 100;
      buffer.writeln(
        '📊 Tỷ lệ chi tiêu vượt: ${overspendingRate.toStringAsFixed(1)}%',
      );
    }

    // Thêm thông tin về tổng số giao dịch
    final totalTransactions = _filtered.length;
    buffer.writeln('📊 Tổng số giao dịch: $totalTransactions');

    // Thêm thông tin về ngày giao dịch đầu/cuối
    if (_filtered.isNotEmpty) {
      final sortedByDate = List<ChiTietChiTieuDanhMuc>.from(_filtered)..sort(
        (a, b) => DateTime.parse(
          a.chiTietChiTieu.ngay,
        ).compareTo(DateTime.parse(b.chiTietChiTieu.ngay)),
      );

      final firstDate = DateTime.parse(sortedByDate.first.chiTietChiTieu.ngay);
      final lastDate = DateTime.parse(sortedByDate.last.chiTietChiTieu.ngay);

      buffer.writeln(
        '📅 Giao dịch đầu: ${DateFormat('dd/MM/yyyy').format(firstDate)}',
      );
      buffer.writeln(
        '📅 Giao dịch cuối: ${DateFormat('dd/MM/yyyy').format(lastDate)}',
      );
    }

    return buffer.toString().trim();
  }

  // Skeletons
  Widget _buildSkeletonSummaryCards() {
    Widget _skeletonCard(Color color) => Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(height: 68),
        ),
      ),
    );
    return Row(
      children: [
        _skeletonCard(Colors.green),
        _skeletonCard(Colors.red),
        _skeletonCard(Colors.teal),
      ],
    );
  }

  Widget _buildSkeletonChart({required Color color}) {
    return Card(
      color: color.withOpacity(0.25),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(height: 200),
      ),
    );
  }

  Widget _buildSkeletonList() {
    final items = List.generate(6, (i) => i);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (final _ in items)
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.black12),
                title: SizedBox(
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black12),
                  ),
                ),
                subtitle: SizedBox(
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black12),
                  ),
                ),
                trailing: SizedBox(
                  width: 72,
                  height: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black12),
                  ),
                ),
              ),
          ],
        ),
      ),
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

    // Define representative days for labels (1, 7, 14, 21, 28, and last day of month)
    final labelDays = <int>[1, 7, 14, 21, 28];

    // Add the last day of month if it's different from 28
    final lastDay = daysInMonth;
    if (lastDay != 28 && !labelDays.contains(lastDay)) {
      labelDays.add(lastDay);
    }

    // Sort label days in ascending order
    labelDays.sort();

    // Get all days with spending data (not just representative days)
    final spendingData =
        dailySpending.entries
            .where((e) => e.value > 0)
            .map((e) => MapEntry(e.key, e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // If no spending data, hide chart
    if (spendingData.isEmpty) {
      return const SizedBox.shrink();
    }

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
                                  // Only show labels for representative days (1, 7, 14, 21, 28, last day)
                                  if (labelDays.contains(day)) {
                                    return Text(
                                      'ng$day',
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
                                    _formatNumber(value),
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
                                        text: _formatCurrency(touchedSpot.y),
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

  Widget _buildDailyIncomeChart(NumberFormat currency) {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final Map<int, double> dailyIncome = {};

    // Initialize all days with 0
    for (int day = 1; day <= daysInMonth; day++) {
      dailyIncome[day] = 0;
    }

    // Aggregate income by day
    for (final item in _filtered) {
      if (item.danhMuc.loai == 1) {
        // Only income
        final day = DateTime.parse(item.chiTietChiTieu.ngay).day;
        dailyIncome[day] = (dailyIncome[day] ?? 0) + item.chiTietChiTieu.soTien;
      }
    }

    // Define representative days for labels (1, 7, 14, 21, 28, and last day of month)
    final labelDays = <int>[1, 7, 14, 21, 28];

    // Add the last day of month if it's different from 28
    final lastDay = daysInMonth;
    if (lastDay != 28 && !labelDays.contains(lastDay)) {
      labelDays.add(lastDay);
    }

    // Sort label days in ascending order
    labelDays.sort();

    // Get all days with income data (not just representative days)
    final incomeData =
        dailyIncome.entries
            .where((e) => e.value > 0)
            .map((e) => MapEntry(e.key, e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // If no income data, hide chart
    if (incomeData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxIncome = incomeData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Thu nhập theo ngày trong tháng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child:
                  incomeData.isEmpty
                      ? const Center(child: Text('Không có dữ liệu'))
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval:
                                maxIncome > 0 ? maxIncome / 4 : 1,
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
                                  // Only show labels for representative days (1, 7, 14, 21, 28, last day)
                                  if (labelDays.contains(day)) {
                                    return Text(
                                      'ng$day',
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
                                interval: maxIncome > 0 ? maxIncome / 4 : 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    _formatNumber(value),
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
                          minX: incomeData.first.key.toDouble(),
                          maxX: incomeData.last.key.toDouble(),
                          minY: 0,
                          maxY: maxIncome > 0 ? maxIncome * 1.2 : 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  incomeData
                                      .map(
                                        (e) =>
                                            FlSpot(e.key.toDouble(), e.value),
                                      )
                                      .toList(),
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [Colors.green, Colors.green.shade300],
                              ),
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity(0.3),
                                    Colors.green.withOpacity(0.1),
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
                              tooltipBgColor: Colors.green.shade100,
                              tooltipRoundedRadius: 8,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((touchedSpot) {
                                  return LineTooltipItem(
                                    'Ngày ${touchedSpot.x.toInt()}\n',
                                    const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _formatCurrency(touchedSpot.y),
                                        style: const TextStyle(
                                          color: Colors.green,
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
                    categoryAgg.entries.toList()..sort((a, b) {
                      // Sắp xếp: thu nhập trước (loai == 1), chi phí sau (loai == 2)
                      if (a.value['type'] != b.value['type']) {
                        return a.value['type'].compareTo(b.value['type']);
                      }
                      // Trong mỗi nhóm, sắp xếp theo số tiền giảm dần
                      return (b.value['total'] as double).compareTo(
                        a.value['total'] as double,
                      );
                    });
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
                    // Find the actual danhMuc from filtered data
                    final danhMucItem =
                        _filtered
                            .where((e) => (e.danhMuc.id ?? -1) == categoryId)
                            .firstOrNull;

                    if (danhMucItem == null)
                      return const SizedBox.shrink(); // Return empty widget if no matching danhMuc

                    final danhMuc = danhMucItem.danhMuc;
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
                              (danhMuc.icon ?? '').isNotEmpty
                                  ? danhMuc.icon!.characters.first
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
                        _formatCurrency(total),
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Only allow navigation for month and year modes
                        if (_mode == _FilterMode.month ||
                            _mode == _FilterMode.year) {
                          _showDanhMucOptions(context, danhMuc);
                        }
                      },
                      // Visual feedback for non-navigable modes
                      tileColor:
                          (_mode == _FilterMode.month ||
                                  _mode == _FilterMode.year)
                              ? null
                              : Colors.grey.withOpacity(0.1),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDanhMucOptions(BuildContext context, dynamic danhMuc) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chọn tùy chọn cho danh mục:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Lịch sử giao dịch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  LichSuGiaoDichDanhMucScreen(danhMuc: danhMuc),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Thống kê năm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ThongKeNamDanhMucScreen(
                                danhMuc: danhMuc,
                                selectedYear: _selectedYear,
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Thống kê tháng'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ThongKeThangDanhMucScreen(
                                danhMuc: danhMuc,
                                selectedMonth: _selectedMonth,
                                selectedYear: _selectedYear,
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    child: const Text('Đóng', style: TextStyle(fontSize: 16)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
