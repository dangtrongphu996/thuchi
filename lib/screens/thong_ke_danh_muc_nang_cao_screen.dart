import 'package:flutter/material.dart';
import 'package:thuchi/models/chi_tiet_chi_tieu_danh_muc.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/danh_muc.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class ThongKeDanhMucNangCaoScreen extends StatefulWidget {
  const ThongKeDanhMucNangCaoScreen({super.key});

  @override
  State<ThongKeDanhMucNangCaoScreen> createState() =>
      _ThongKeDanhMucNangCaoScreenState();
}

class _ThongKeDanhMucNangCaoScreenState
    extends State<ThongKeDanhMucNangCaoScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  List<DanhMuc> _danhMucs = [];
  int? _selectedYear;
  int? _selectedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedDanhMucId;

  double _tongCong = 0;
  double _caoNhat = 0;
  double _thapNhat = 0;
  String? _periodCaoNhat;
  String? _periodThapNhat;

  List<_StatItem> _statItems = [];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year; // Default to current year
    _selectedMonth = null;
    _startDate = null;
    _endDate = null;
    loadData();
  }

  Future<void> loadData() async {
    // Load categories
    final all = await _dmDao.getAllDanhMuc();
    setState(() {
      _danhMucs = all;
      if (_danhMucs.isNotEmpty && _selectedDanhMucId == null) {
        _selectedDanhMucId = _danhMucs.first.id;
      }
    });

    // Filter transactions based on selected criteria
    List<ChiTietChiTieuDanhMuc> filteredTransactions = [];
    if (_selectedDanhMucId != null) {
      // Fetch all transactions and their categories
      final allTransactionsWithCategories = await _ctDao.getAll();

      // Filter by selected category
      List<ChiTietChiTieuDanhMuc> categoryFiltered =
          allTransactionsWithCategories
              .where((ctdm) => ctdm.danhMuc.id == _selectedDanhMucId)
              .toList();

      if (_startDate != null && _endDate != null) {
        // Filter by date range
        filteredTransactions =
            categoryFiltered.where((ctdm) {
              final transactionDate = DateTime.parse(ctdm.chiTietChiTieu.ngay);
              return !transactionDate.isBefore(_startDate!) &&
                  !transactionDate.isAfter(_endDate!);
            }).toList();
        _selectedYear = null; // Clear year/month selection if range is set
        _selectedMonth = null;
      } else if (_selectedYear != null) {
        // Filter by year (and optional month)
        filteredTransactions =
            categoryFiltered
                .where(
                  (ctdm) =>
                      DateTime.parse(ctdm.chiTietChiTieu.ngay).year ==
                      _selectedYear,
                )
                .toList();

        if (_selectedMonth != null) {
          filteredTransactions =
              filteredTransactions
                  .where(
                    (ctdm) =>
                        DateTime.parse(ctdm.chiTietChiTieu.ngay).month ==
                        _selectedMonth,
                  )
                  .toList();
        }
      } else {
        // If no year or range selected, show all for the category
        filteredTransactions = categoryFiltered;
      }
    }

    // Calculate total, max, min
    _calculateStats(filteredTransactions);

    // Populate statItems based on selected filter level (month/day)
    _populateStatItems(filteredTransactions);

    setState(() {}); // Update UI
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _calculateStats(List<ChiTietChiTieuDanhMuc> transactions) {
    if (transactions.isEmpty) {
      _tongCong = 0;
      _caoNhat = 0;
      _thapNhat = 0;
      _periodCaoNhat = null;
      _periodThapNhat = null;
      return;
    }

    _tongCong = transactions.fold(
      0.0,
      (sum, item) => sum + item.chiTietChiTieu.soTien,
    );
    final List<double> amounts =
        transactions.map((item) => item.chiTietChiTieu.soTien).toList();
    _caoNhat = amounts.isNotEmpty ? amounts.reduce(max) : 0;
    _thapNhat = amounts.isNotEmpty ? amounts.reduce(min) : 0;

    // Tìm ngày hoặc tháng tương ứng
    final idxCaoNhat = amounts.indexOf(_caoNhat);
    final idxThapNhat = amounts.indexOf(_thapNhat);
    if (idxCaoNhat != -1 && idxCaoNhat < transactions.length) {
      final ngay = DateTime.parse(transactions[idxCaoNhat].chiTietChiTieu.ngay);
      if (_selectedYear != null && _selectedMonth != null) {
        _periodCaoNhat = DateFormat('dd/MM/yyyy').format(ngay);
      } else if (_selectedYear != null) {
        _periodCaoNhat = 'Tháng ${ngay.month}';
      } else {
        _periodCaoNhat = 'Năm ${ngay.year}';
      }
    } else {
      _periodCaoNhat = null;
    }
    if (idxThapNhat != -1 && idxThapNhat < transactions.length) {
      final ngay = DateTime.parse(
        transactions[idxThapNhat].chiTietChiTieu.ngay,
      );
      if (_selectedYear != null && _selectedMonth != null) {
        _periodThapNhat = DateFormat('dd/MM/yyyy').format(ngay);
      } else if (_selectedYear != null) {
        _periodThapNhat = 'Tháng ${ngay.month}';
      } else {
        _periodThapNhat = 'Năm ${ngay.year}';
      }
    } else {
      _periodThapNhat = null;
    }
  }

  void _populateStatItems(List<ChiTietChiTieuDanhMuc> transactions) {
    _statItems = [];
    if (transactions.isEmpty) {
      _periodCaoNhat = null;
      _periodThapNhat = null;
      return;
    }

    if (_startDate != null && _endDate != null) {
      // If date range is selected, group by day
      final Map<int, double> dailyTotals = {};
      final Map<int, List<ChiTietChiTieuDanhMuc>> dailyTransactions =
          {}; // To store transactions per day
      for (var ctdm in transactions) {
        final day = DateTime.parse(ctdm.chiTietChiTieu.ngay).day;
        dailyTotals.update(
          day,
          (value) => value + ctdm.chiTietChiTieu.soTien,
          ifAbsent: () => ctdm.chiTietChiTieu.soTien,
        );
        dailyTransactions.update(
          day,
          (value) => value..add(ctdm),
          ifAbsent: () => [ctdm],
        );
      }
      _statItems =
          dailyTotals.entries.map((e) {
              // Get the full date from one of the transactions for that day
              final fullDate = DateTime.parse(
                dailyTransactions[e.key]!.first.chiTietChiTieu.ngay,
              );
              return _StatItem(
                DateFormat('dd/MM/yyyy').format(fullDate),
                e.value,
              ); // Format as dd/MM/yyyy
            }).toList()
            ..sort(
              (a, b) => DateFormat('dd/MM/yyyy')
                  .parse(b.period)
                  .compareTo(DateFormat('dd/MM/yyyy').parse(a.period)),
            );
    } else if (_selectedYear != null && _selectedMonth != null) {
      // If year and month are selected, group by day
      final Map<int, double> dailyTotals = {};
      final Map<int, List<ChiTietChiTieuDanhMuc>> dailyTransactions =
          {}; // To store transactions per day
      for (var ctdm in transactions) {
        final day = DateTime.parse(ctdm.chiTietChiTieu.ngay).day;
        dailyTotals.update(
          day,
          (value) => value + ctdm.chiTietChiTieu.soTien,
          ifAbsent: () => ctdm.chiTietChiTieu.soTien,
        );
        dailyTransactions.update(
          day,
          (value) => value..add(ctdm),
          ifAbsent: () => [ctdm],
        );
      }
      _statItems =
          dailyTotals.entries.map((e) {
              // Get the full date from one of the transactions for that day
              final fullDate = DateTime.parse(
                dailyTransactions[e.key]!.first.chiTietChiTieu.ngay,
              );
              return _StatItem(
                DateFormat('dd/MM/yyyy').format(fullDate),
                e.value,
              ); // Format as dd/MM/yyyy
            }).toList()
            ..sort(
              (a, b) => DateFormat('dd/MM/yyyy')
                  .parse(b.period)
                  .compareTo(DateFormat('dd/MM/yyyy').parse(a.period)),
            );
    } else if (_selectedYear != null) {
      // If only year is selected, group by month
      final Map<int, double> monthlyTotals = {};
      for (var ctdm in transactions) {
        final month = DateTime.parse(ctdm.chiTietChiTieu.ngay).month;
        monthlyTotals.update(
          month,
          (value) => value + ctdm.chiTietChiTieu.soTien,
          ifAbsent: () => ctdm.chiTietChiTieu.soTien,
        );
      }
      _statItems =
          monthlyTotals.entries
              .map((e) => _StatItem('Tháng ${e.key}', e.value))
              .toList()
            ..sort(
              (a, b) => int.parse(
                b.period.split(' ')[1],
              ).compareTo(int.parse(a.period.split(' ')[1])),
            );
    } else {
      // If only category is selected, group by year
      final Map<int, double> yearlyTotals = {};
      for (var ctdm in transactions) {
        final year = DateTime.parse(ctdm.chiTietChiTieu.ngay).year;
        yearlyTotals.update(
          year,
          (value) => value + ctdm.chiTietChiTieu.soTien,
          ifAbsent: () => ctdm.chiTietChiTieu.soTien,
        );
      }
      _statItems =
          yearlyTotals.entries
              .map((e) => _StatItem('Năm ${e.key}', e.value))
              .toList()
            ..sort(
              (a, b) => int.parse(
                a.period.split(' ')[1],
              ).compareTo(int.parse(b.period.split(' ')[1])),
            );
    }

    // Sau khi đã có _statItems, tìm item cao nhất và thấp nhất
    if (_statItems.isNotEmpty) {
      final maxItem = _statItems.reduce((a, b) => a.total >= b.total ? a : b);
      final minItem = _statItems.reduce((a, b) => a.total <= b.total ? a : b);
      _caoNhat = maxItem.total;
      _thapNhat = minItem.total;
      _periodCaoNhat = maxItem.period;
      _periodThapNhat = minItem.period;
    } else {
      _periodCaoNhat = null;
      _periodThapNhat = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê danh mục nâng cao',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.teal, // Choose a distinct color
        foregroundColor: Colors.white,
      ),
      body: Container(
        // Added Container for background
        decoration: BoxDecoration(
          // Added gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white], // Gradient colors
          ),
        ),
        child: SingleChildScrollView(
          // Wrapped content in SingleChildScrollView
          child: Padding(
            // Added Padding
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters
                Card(
                  // Wrapped filters in a Card
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    // Added Padding inside the Card
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      // Wrapped filters in a Column
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bộ lọc',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ), // Added title for filters
                        SizedBox(height: 16),
                        // Year and Month Dropdowns
                        Row(
                          children: [
                            // Year Dropdown
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedYear,
                                decoration: InputDecoration(
                                  labelText: 'Năm',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ), // Rounded border
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.teal,
                                  ), // Added icon
                                ),
                                items:
                                    List.generate(
                                          10,
                                          (index) =>
                                              DateTime.now().year - 5 + index,
                                        )
                                        .map(
                                          (year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year.toString()),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                    // Clear date range when year is selected
                                    _startDate = null;
                                    _endDate = null;
                                    // Reset month when year changes
                                    _selectedMonth = null;
                                  });
                                  loadData();
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            // Month Dropdown (only shown if year is selected)
                            if (_selectedYear !=
                                null) // Only show month if a year is selected
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _selectedMonth,
                                  hint: Text('Tháng'),
                                  decoration: InputDecoration(
                                    labelText: 'Tháng',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ), // Rounded border
                                    prefixIcon: Icon(
                                      Icons.calendar_month,
                                      color: Colors.teal,
                                    ), // Added icon
                                  ),
                                  items: [
                                    // Add "Cả năm" option
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Cả năm'),
                                    ),
                                    // Existing month options
                                    ...List.generate(12, (index) => index + 1)
                                        .map(
                                          (month) => DropdownMenuItem(
                                            value: month,
                                            child: Text(month.toString()),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMonth = value;
                                      // Clear date range when month is selected
                                      _startDate = null;
                                      _endDate = null;
                                    });
                                    loadData();
                                  },
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Date Range Pickers (shown if no year is selected)
                        Column(
                          // Date Range Pickers
                          children: [
                            // From Date Picker
                            InkWell(
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  helpText: 'Chọn ngày bắt đầu',
                                  cancelText: 'Hủy',
                                  confirmText: 'Chọn',
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                  // If end date is before start date, reset end date
                                  if (_endDate != null &&
                                      _endDate!.isBefore(_startDate!)) {
                                    _endDate = null;
                                  }
                                  // Clear year/month when date range is selected
                                  _selectedYear = null;
                                  _selectedMonth = null;
                                  loadData();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Từ ngày (Tùy chọn)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.date_range,
                                    color: Colors.teal,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      _startDate == null
                                          ? 'Chọn ngày'
                                          : DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_startDate!),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // To Date Picker
                            InkWell(
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _endDate ??
                                      _startDate ??
                                      DateTime.now(), // Default to start date or now
                                  firstDate:
                                      _startDate ??
                                      DateTime(
                                        2000,
                                      ), // Cannot be before start date
                                  lastDate: DateTime(2100),
                                  helpText: 'Chọn ngày kết thúc',
                                  cancelText: 'Hủy',
                                  confirmText: 'Chọn',
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                  // Clear year/month when date range is selected
                                  _selectedYear = null;
                                  _selectedMonth = null;
                                  loadData();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Đến ngày (Tùy chọn)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.date_range,
                                    color: Colors.teal,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      _endDate == null
                                          ? 'Chọn ngày'
                                          : DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_endDate!),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          // Category Dropdown
                          value: _selectedDanhMucId,
                          hint: Text('Chọn danh mục'),
                          decoration: InputDecoration(
                            labelText: 'Danh mục',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ), // Rounded border
                            prefixIcon: Icon(
                              Icons.category,
                              color: Colors.teal,
                            ), // Added icon
                          ),
                          items:
                              _danhMucs
                                  .map(
                                    (dm) => DropdownMenuItem(
                                      value: dm.id,
                                      child: Text('${dm.icon} ${dm.ten}'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDanhMucId = value;
                              // // Clear date filters when category changes
                              // _selectedYear = null;
                              // _selectedMonth = null;
                              // _startDate = null;
                              // _endDate = null;
                            });
                            loadData();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Statistics
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thống kê',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ), // Added title for statistics
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng cộng:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_tongCong.toStringAsFixed(0)} đ',
                              style: TextStyle(
                                // Styled text with color
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cao nhất:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${_caoNhat.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                if (_periodCaoNhat != null) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    '(${_periodCaoNhat})',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thấp nhất:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${_thapNhat.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                if (_periodThapNhat != null) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    '(${_periodThapNhat})',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ), // Added title for list
                SizedBox(height: 16),
                _statItems
                        .isEmpty // Handle empty state for the list
                    ? Center(
                      child: Text(
                        'Không có dữ liệu thống kê',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true, // Added shrinkWrap
                      physics:
                          NeverScrollableScrollPhysics(), // Added physics to disable independent scrolling
                      itemCount: _statItems.length,
                      itemBuilder: (context, index) {
                        final item = _statItems[index];
                        return Card(
                          // Wrapped ListTile in Card
                          elevation: 2,
                          margin: EdgeInsets.symmetric(
                            vertical: 6,
                          ), // Added vertical margin
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ), // Rounded corners
                          child: ListTile(
                            leading: Icon(
                              // Added leading icon based on period type
                              _startDate != null && _endDate != null
                                  ? Icons.calendar_view_day
                                  : Icons.calendar_view_month,
                              color: Colors.teal,
                            ),
                            title: Text(
                              item.period,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ), // Bold title
                            trailing: Text(
                              '${item.total.toStringAsFixed(0)} đ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            ), // Styled trailing text
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final String period;
  final double total;

  _StatItem(this.period, this.total);
}
