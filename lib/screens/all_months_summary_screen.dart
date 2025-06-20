import 'package:flutter/material.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import 'chi_tiet_theo_thang.dart';

class AllMonthsSummaryScreen extends StatefulWidget {
  const AllMonthsSummaryScreen({super.key});

  @override
  State<AllMonthsSummaryScreen> createState() => _AllMonthsSummaryScreenState();
}

class _AllMonthsSummaryScreenState extends State<AllMonthsSummaryScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  bool isLoading = true;
  List<Map<String, dynamic>> monthList = [];
  // Thống kê
  double tongThu = 0;
  double tongChi = 0;
  double tongConLai = 0;
  double trungBinhThu = 0;
  double trungBinhChi = 0;
  double soDuLonNhat = 0;
  double soDuNhoNhat = 0;
  Map<String, dynamic>? thangThuNhieuNhat;
  Map<String, dynamic>? thangThuItNhat;

  // Bộ lọc nâng cao
  int? selectedYear;
  int? selectedMonthFrom;
  int? selectedMonthTo;
  bool filterThu = true;
  bool filterChi = true;
  List<int> allYears = [];

  List<Map<String, dynamic>> allMonthList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final list = await _ctDao.getAll();
    final danhMucs = await _dmDao.getAllDanhMuc();
    // Group by month/year
    final Map<String, List<dynamic>> grouped = {};
    Set<int> yearSet = {};
    for (var item in list) {
      final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay);
      if (ngay == null) continue;
      yearSet.add(ngay.year);
      final key = '${ngay.year}-${ngay.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    allYears = yearSet.toList()..sort();
    // Tạo danh sách tháng
    allMonthList =
        grouped.entries.map((e) {
          double thu = 0, chi = 0;
          for (var item in e.value) {
            final dm = danhMucs.firstWhere(
              (d) => d.id == item.chiTietChiTieu.danhMucId,
              orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
            );
            if (dm.loai == 1) {
              thu += item.chiTietChiTieu.soTien;
            } else {
              chi += item.chiTietChiTieu.soTien;
            }
          }
          final parts = e.key.split('-');
          return {
            'year': int.parse(parts[0]),
            'month': int.parse(parts[1]),
            'thu': thu,
            'chi': chi,
            'tong': thu - chi,
          };
        }).toList();
    // Sắp xếp giảm dần theo thời gian
    allMonthList.sort((a, b) {
      if (a['year'] != b['year']) return b['year'].compareTo(a['year']);
      return b['month'].compareTo(a['month']);
    });
    applyFilters();
  }

  void applyFilters() {
    // Lọc theo năm
    List<Map<String, dynamic>> filtered = List.from(allMonthList);
    if (selectedYear != null) {
      filtered = filtered.where((m) => m['year'] == selectedYear).toList();
    }
    // Lọc theo khoảng tháng
    if (selectedMonthFrom != null) {
      filtered =
          filtered.where((m) => m['month'] >= selectedMonthFrom!).toList();
    }
    if (selectedMonthTo != null) {
      filtered = filtered.where((m) => m['month'] <= selectedMonthTo!).toList();
    }
    // Lọc theo loại giao dịch
    if (filterThu && !filterChi) {
      filtered =
          filtered
              .where(
                (m) => (m['thu'] as double) > 0 && (m['chi'] as double) == 0,
              )
              .toList();
    } else if (!filterThu && filterChi) {
      filtered =
          filtered
              .where(
                (m) => (m['chi'] as double) > 0 && (m['thu'] as double) == 0,
              )
              .toList();
    } else if (!filterThu && !filterChi) {
      filtered = [];
    }
    monthList = filtered;
    // Tính toán thống kê như cũ
    tongThu = monthList.fold(0, (p, e) => p + (e['thu'] as double));
    tongChi = monthList.fold(0, (p, e) => p + (e['chi'] as double));
    tongConLai = tongThu - tongChi;
    trungBinhThu = monthList.isNotEmpty ? tongThu / monthList.length : 0;
    trungBinhChi = monthList.isNotEmpty ? tongChi / monthList.length : 0;
    soDuLonNhat = 0;
    soDuNhoNhat = 0;
    if (monthList.isNotEmpty) {
      soDuLonNhat = monthList[0]['tong'] as double;
      soDuNhoNhat = monthList[0]['tong'] as double;
      for (var m in monthList) {
        if ((m['tong'] as double) > soDuLonNhat)
          soDuLonNhat = m['tong'] as double;
        if ((m['tong'] as double) < soDuNhoNhat)
          soDuNhoNhat = m['tong'] as double;
      }
    }
    thangThuNhieuNhat = null;
    thangThuItNhat = null;
    if (monthList.isNotEmpty) {
      thangThuNhieuNhat = monthList[0];
      thangThuItNhat = monthList[0];
      for (var m in monthList) {
        final double? thuMax = thangThuNhieuNhat?['thu'] as double?;
        final double? thuMin = thangThuItNhat?['thu'] as double?;
        final double? thuM = m?['thu'] as double?;
        if (thuMax != null && thuM != null && thuM > thuMax) {
          thangThuNhieuNhat = m;
        }
        if (thuMin != null && thuM != null && thuM < thuMin) {
          thangThuItNhat = m;
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng hợp các tháng'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bộ lọc nâng cao
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dòng 1: Năm
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Năm',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: selectedYear,
                                            hint: Text(
                                              'Tất cả',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            items:
                                                allYears
                                                    .map(
                                                      (y) => DropdownMenuItem(
                                                        value: y,
                                                        child: Text(
                                                          '$y',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (v) {
                                              setState(() {
                                                selectedYear = v;
                                              });
                                              applyFilters();
                                            },
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Dòng 2: Từ tháng - Đến tháng
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          color: Colors.deepOrange,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Từ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.shade100,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value: selectedMonthFrom,
                                              hint: Text(
                                                'Bất kỳ',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              items:
                                                  List.generate(
                                                        12,
                                                        (i) => i + 1,
                                                      )
                                                      .map(
                                                        (m) => DropdownMenuItem(
                                                          value: m,
                                                          child: Text(
                                                            'Tháng $m',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (v) {
                                                setState(() {
                                                  selectedMonthFrom = v;
                                                });
                                                applyFilters();
                                              },
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Đến',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.shade100,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value: selectedMonthTo,
                                              hint: Text(
                                                'Bất kỳ',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              items:
                                                  List.generate(
                                                        12,
                                                        (i) => i + 1,
                                                      )
                                                      .map(
                                                        (m) => DropdownMenuItem(
                                                          value: m,
                                                          child: Text(
                                                            'Tháng $m',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (v) {
                                                setState(() {
                                                  selectedMonthTo = v;
                                                });
                                                applyFilters();
                                              },
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Dòng 3: Loại giao dịch
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.filter_alt,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: filterThu,
                                            activeColor: Colors.green,
                                            onChanged: (v) {
                                              setState(() {
                                                filterThu = v!;
                                              });
                                              applyFilters();
                                            },
                                          ),
                                          Text(
                                            'Chỉ thu',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: filterChi,
                                            activeColor: Colors.red,
                                            onChanged: (v) {
                                              setState(() {
                                                filterChi = v!;
                                              });
                                              applyFilters();
                                            },
                                          ),
                                          Text(
                                            'Chỉ chi',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (monthList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Card(
                              color: Colors.orange.shade50,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.savings,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tổng thu: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${tongThu.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.money_off,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tổng chi: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${tongChi.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          color:
                                              tongConLai >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tổng còn lại: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${tongConLai.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color:
                                                tongConLai >= 0
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 18),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tháng thu nhập nhiều nhất: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32.0,
                                      ),
                                      child: Text(
                                        thangThuNhieuNhat != null &&
                                                thangThuNhieuNhat?['month'] !=
                                                    null &&
                                                thangThuNhieuNhat?['year'] !=
                                                    null &&
                                                thangThuNhieuNhat?['thu'] !=
                                                    null
                                            ? 'Tháng ${thangThuNhieuNhat?['month']}/${thangThuNhieuNhat?['year']} (${(thangThuNhieuNhat?['thu'] as double).toStringAsFixed(0)} đ)'
                                            : '-',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_down,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tháng thu nhập thấp nhất: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32.0,
                                      ),
                                      child: Text(
                                        thangThuItNhat != null &&
                                                thangThuItNhat?['month'] !=
                                                    null &&
                                                thangThuItNhat?['year'] !=
                                                    null &&
                                                thangThuItNhat?['thu'] != null
                                            ? 'Tháng ${thangThuItNhat?['month']}/${thangThuItNhat?['year']} (${(thangThuItNhat?['thu'] as double).toStringAsFixed(0)} đ)'
                                            : '-',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Divider(height: 18),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Trung bình thu: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${trungBinhThu.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Trung bình chi: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${trungBinhChi.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 18),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Colors.purple,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Số dư lớn nhất: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${soDuLonNhat.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Colors.brown,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Số dư nhỏ nhất: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${soDuNhoNhat.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.brown,
                                            fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      'Danh sách tháng',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  monthList.isEmpty
                                      ? Center(
                                        child: Text(
                                          'Không có dữ liệu giao dịch',
                                        ),
                                      )
                                      : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemCount: monthList.length,
                                        separatorBuilder:
                                            (_, __) => SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final m = monthList[index];
                                          return ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 0,
                                                ),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.orange.shade100,
                                              child: Text(
                                                '${m['month']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              'Tháng ${m['month']} - ${m['year']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_downward,
                                                      color: Colors.green,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Thu nhập: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${m['thu'].toStringAsFixed(0)} đ',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_upward,
                                                      color: Colors.redAccent,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Chi phí: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${m['chi'].toStringAsFixed(0)} đ',
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Tổng cộng',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '${m['tong'].toStringAsFixed(0)} đ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        m['tong'] >= 0
                                                            ? Colors.green
                                                            : Colors.red,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          ChiTietTheoThangScreen(
                                                            selectedMonth:
                                                                m['month'],
                                                            selectedYear:
                                                                m['year'],
                                                          ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                ],
                              ),
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
