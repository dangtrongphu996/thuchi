import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/danh_muc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chi_tiet_theo_thang.dart';

class ThongKeThuChiScreen extends StatefulWidget {
  const ThongKeThuChiScreen({super.key});

  @override
  State<ThongKeThuChiScreen> createState() => _ThongKeThuChiScreenState();
}

class _ThongKeThuChiScreenState extends State<ThongKeThuChiScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();

  int _selectedType = 1; // 1 for Thu nhập, 2 for Chi phí
  int _selectedYear = DateTime.now().year;
  List<_MonthlyStat> _monthlyStats = [];
  List<DanhMuc> _danhMucs = []; // To get category type

  double _totalAmount = 0;
  double _maxAmount = 0;
  double _minAmount = 0;
  double _averageAmount = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final allTransactions = await _ctDao.getAll();
    _danhMucs = await _dmDao.getAllDanhMuc();

    // Filter transactions by year and type
    final filteredTransactions =
        allTransactions.where((ctdm) {
          final date = DateTime.parse(ctdm.chiTietChiTieu.ngay);
          final category = _danhMucs.firstWhere(
            (dm) => dm.id == ctdm.chiTietChiTieu.danhMucId,
            orElse:
                () => DanhMuc(
                  id: 0,
                  ten: '',
                  icon: '',
                  loai: 0,
                ), // Default orElse
          );
          return date.year == _selectedYear && category.loai == _selectedType;
        }).toList();

    // Calculate monthly totals
    final Map<int, double> monthlyTotals = {};
    for (var ctdm in filteredTransactions) {
      final month = DateTime.parse(ctdm.chiTietChiTieu.ngay).month;
      monthlyTotals.update(
        month,
        (value) => value + ctdm.chiTietChiTieu.soTien,
        ifAbsent: () => ctdm.chiTietChiTieu.soTien,
      );
    }

    // Populate monthly stats list
    _monthlyStats =
        monthlyTotals.entries.map((e) => _MonthlyStat(e.key, e.value)).toList();
    _monthlyStats.sort((a, b) => b.month.compareTo(a.month));

    // Calculate additional statistics
    _totalAmount = filteredTransactions.fold(
      0.0,
      (sum, item) => sum + item.chiTietChiTieu.soTien,
    );
    if (_monthlyStats.isNotEmpty) {
      _maxAmount = _monthlyStats
          .map((e) => e.total)
          .reduce((a, b) => a > b ? a : b);
      _minAmount = _monthlyStats
          .map((e) => e.total)
          .reduce((a, b) => a < b ? a : b);
      _averageAmount = _totalAmount / _monthlyStats.length;
    } else {
      _maxAmount = 0;
      _minAmount = 0;
      _averageAmount = 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM', 'vi');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê thu nhập và chi phí',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    color: Colors.blueGrey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedType == 1
                                    ? Icons.savings
                                    : Icons.money_off,
                                color:
                                    _selectedType == 1
                                        ? Colors.green
                                        : Colors.redAccent,
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              Text(
                                _selectedType == 1
                                    ? 'Tổng quan thu nhập'
                                    : 'Tổng quan chi phí',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.summarize,
                                color: Colors.blue,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Tổng cộng:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_totalAmount.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedType == 1
                                          ? Colors.green
                                          : Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Colors.orange,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Cao nhất:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_maxAmount.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedType == 1
                                          ? Colors.green
                                          : Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: Colors.purple,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Thấp nhất:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_minAmount.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedType == 1
                                          ? Colors.green
                                          : Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                color: Colors.teal,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Trung bình:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_averageAmount.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedType == 1
                                          ? Colors.green
                                          : Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.blueGrey,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Năm:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _selectedYear,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 0,
                                    ),
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
                                    if (value != null) {
                                      setState(() {
                                        _selectedYear = value;
                                      });
                                      loadData();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: Colors.blueGrey,
                                size: 22,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<int>(
                                        value: 1,
                                        groupValue: _selectedType,
                                        title: Text(
                                          'Thu nhập',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedType = value;
                                            });
                                            loadData();
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<int>(
                                        value: 2,
                                        groupValue: _selectedType,
                                        title: Text(
                                          'Chi phí',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedType = value;
                                            });
                                            loadData();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Chi tiết theo tháng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    color: Colors.blueGrey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        _monthlyStats.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'Không có dữ liệu thống kê cho năm này',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                            : ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: _monthlyStats.length,
                              separatorBuilder: (_, __) => SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final stat = _monthlyStats[index];
                                return Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _selectedType == 1
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                      child: Icon(
                                        Icons.calendar_view_month,
                                        color:
                                            _selectedType == 1
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    title: Text(
                                      'Tháng ${stat.month}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: Text(
                                      '${stat.total.toStringAsFixed(0)} đ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _selectedType == 1
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ChiTietTheoThangScreen(
                                                selectedMonth: stat.month,
                                                selectedYear: _selectedYear,
                                                type: _selectedType,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyStat {
  final int month;
  final double total;

  _MonthlyStat(this.month, this.total);
}
