import 'package:flutter/material.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chi_tiet_chi_tieu.dart';
import 'chi_tiet_danh_muc_screen.dart';
import 'phan_tich_danh_muc_screen.dart';

class ThongKeDanhMucScreen extends StatefulWidget {
  const ThongKeDanhMucScreen({super.key});

  @override
  State<ThongKeDanhMucScreen> createState() => _ThongKeDanhMucScreenState();
}

class _ThongKeDanhMucScreenState extends State<ThongKeDanhMucScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  int? selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<int> allYears = [];
  List<Map<String, dynamic>> danhMucStats =
      []; // Changed from Object to dynamic
  double tongThu = 0;
  double tongChi = 0;
  double tongConLai = 0;
  Map<String, dynamic>? dmThuMax; // Changed from Object to dynamic
  Map<String, dynamic>? dmThuMin;
  Map<String, dynamic>? dmChiMax;
  Map<String, dynamic>? dmChiMin;
  bool isLoading = true;

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
    Set<int> yearSet = {};
    for (var item in list) {
      final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay);
      if (ngay != null) yearSet.add(ngay.year);
    }
    allYears = yearSet.toList()..sort();

    // Lọc theo tháng/năm
    final filtered =
        list.where((item) {
          final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay);
          return ngay != null &&
              (selectedMonth == null || ngay.month == selectedMonth) &&
              ngay.year == selectedYear;
        }).toList();

    // Gom nhóm theo danh mục
    Map<int, double> tongTienTheoDanhMuc = {};
    Map<int, DanhMuc> danhMucMap = {for (var dm in danhMucs) dm.id!: dm};

    for (var item in filtered) {
      final id = item.chiTietChiTieu.danhMucId;
      tongTienTheoDanhMuc[id] =
          (tongTienTheoDanhMuc[id] ?? 0) + item.chiTietChiTieu.soTien;
    }

    danhMucStats =
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

    // Sắp xếp giảm dần theo số tiền
    danhMucStats.sort(
      (a, b) => (b['tong'] as double).compareTo(a['tong'] as double),
    );

    // Thống kê tổng thu/chi
    tongThu = danhMucStats
        .where((e) => e['loai'] == 1)
        .fold(0.0, (p, e) => p + (e['tong'] as double));
    tongChi = danhMucStats
        .where((e) => e['loai'] == 2)
        .fold(0.0, (p, e) => p + (e['tong'] as double));
    tongConLai = tongThu - tongChi;

    // Tìm max/min
    final thuList = danhMucStats.where((e) => e['loai'] == 1).toList();
    final chiList = danhMucStats.where((e) => e['loai'] == 2).toList();
    // Tìm max/min thu
    dmThuMax = null;
    dmThuMin = null;
    if (thuList.isNotEmpty) {
      dmThuMax = thuList[0];
      dmThuMin = thuList[0];
      for (var m in thuList) {
        if ((m['tong'] as double) > (dmThuMax?['tong'] as double)) dmThuMax = m;
        if ((m['tong'] as double) < (dmThuMin?['tong'] as double)) dmThuMin = m;
      }
    }
    // Tìm max/min chi
    dmChiMax = null;
    dmChiMin = null;
    if (chiList.isNotEmpty) {
      dmChiMax = chiList[0];
      dmChiMin = chiList[0];
      for (var m in chiList) {
        if ((m['tong'] as double) > (dmChiMax?['tong'] as double)) dmChiMax = m;
        if ((m['tong'] as double) < (dmChiMin?['tong'] as double)) dmChiMin = m;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showChiTietDanhMuc(
    BuildContext context,
    Map<String, dynamic> dm,
  ) async {
    final list = await _ctDao.getAll();
    final filtered =
        list.where((item) {
          final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay);
          return ngay != null &&
              ngay.month == selectedMonth &&
              ngay.year == selectedYear &&
              item.chiTietChiTieu.danhMucId == dm['id'];
        }).toList();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(dm['icon'] ?? '', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  dm['ten'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dm['loai'] == 2) ...[
                  Text(
                    'Tiến độ sử dụng ngân sách:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: tongChi > 0 ? (dm['tong'] as double) / tongChi : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                  ),
                  SizedBox(height: 10),
                ],
                Text(
                  'Danh sách giao dịch:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                filtered.isEmpty
                    ? Text(
                      'Không có giao dịch nào',
                      style: TextStyle(color: Colors.grey),
                    )
                    : SizedBox(
                      height: 220,
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 6),
                        itemBuilder: (context, idx) {
                          final ct = filtered[idx].chiTietChiTieu;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${ct.soTien.toStringAsFixed(0)} đ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    dm['loai'] == 1 ? Colors.green : Colors.red,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((ct.ghiChu ?? '').isNotEmpty)
                                  Text(
                                    ct.ghiChu ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      ct.ngay,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê thu chi theo danh mục',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics, color: Colors.teal),
            tooltip: 'Phân tích danh mục',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhanTichDanhMucScreenNew()),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: Colors.orange.shade50,
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
                              // Dropdown tháng
                              Flexible(
                                child: DropdownButtonFormField<int?>(
                                  value: selectedMonth,
                                  decoration: InputDecoration(
                                    labelText: 'Tháng',
                                    prefixIcon: Icon(
                                      Icons.calendar_month,
                                      color: Colors.orange,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 8,
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('Cả năm'),
                                    ),
                                    ...List.generate(12, (i) => i + 1)
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text('Tháng $m'),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMonth = value;
                                    });
                                    loadData();
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              // Dropdown năm
                              Flexible(
                                child: DropdownButtonFormField<int>(
                                  value: selectedYear,
                                  decoration: InputDecoration(
                                    labelText: 'Năm',
                                    prefixIcon: Icon(
                                      Icons.date_range,
                                      color: Colors.orange,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 8,
                                    ),
                                  ),
                                  items:
                                      allYears
                                          .map(
                                            (y) => DropdownMenuItem(
                                              value: y,
                                              child: Text('Năm $y'),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedYear = value;
                                      });
                                      loadData();
                                    }
                                  },
                                ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            color: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tổng thu:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        tongThu.toStringAsFixed(0) + ' đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tổng chi:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        tongChi.toStringAsFixed(0) + ' đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.deepOrange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Còn lại:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        tongConLai.toStringAsFixed(0) + ' đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              tongConLai > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  if (dmThuMax != null)
                                    Row(
                                      children: [
                                        Text(
                                          dmThuMax!['icon'] ?? '',
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Danh mục thu nhiều nhất:',
                                          style: TextStyle(
                                            color: Colors.green[900],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${dmThuMax!['ten']} (${(dmThuMax!['tong'] as double).toStringAsFixed(0)} đ)',
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (dmThuMin != null)
                                    Row(
                                      children: [
                                        Text(
                                          dmThuMin!['icon'] ?? '',
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Danh mục thu ít nhất:',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${dmThuMin!['ten']} (${(dmThuMin!['tong'] as double).toStringAsFixed(0)} đ)',
                                          style: TextStyle(
                                            color: Colors.green[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (dmChiMax != null)
                                    Row(
                                      children: [
                                        Text(
                                          dmChiMax!['icon'] ?? '',
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Danh mục chi nhiều nhất:',
                                          style: TextStyle(
                                            color: Colors.red[900],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${dmChiMax!['ten']} (${(dmChiMax!['tong'] as double).toStringAsFixed(0)} đ)',
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (dmChiMin != null)
                                    Row(
                                      children: [
                                        Text(
                                          dmChiMin!['icon'] ?? '',
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Danh mục chi ít nhất:',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${dmChiMin!['ten']} (${(dmChiMin!['tong'] as double).toStringAsFixed(0)} đ)',
                                          style: TextStyle(
                                            color: Colors.red[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          // Pie chart tỷ lệ thu/chi theo danh mục
                          if (danhMucStats.isNotEmpty) ...[
                            // Pie chart thu nhập
                            if (danhMucStats.any((e) => e['loai'] == 1))
                              Card(
                                color: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tỷ lệ thu nhập theo danh mục',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        height: 180,
                                        child: Builder(
                                          builder: (context) {
                                            final thuList =
                                                danhMucStats
                                                    .where(
                                                      (e) => e['loai'] == 1,
                                                    )
                                                    .toList();
                                            final colors = [
                                              Colors.green,
                                              Colors.blue,
                                              Colors.orange,
                                              Colors.teal,
                                              Colors.purple,
                                              Colors.amber,
                                              Colors.cyan,
                                              Colors.indigo,
                                              Colors.pink,
                                              Colors.lime,
                                            ];
                                            return PieChart(
                                              PieChartData(
                                                sections: List.generate(
                                                  thuList.length,
                                                  (i) {
                                                    final e = thuList[i];
                                                    final color =
                                                        colors[i %
                                                            colors.length];
                                                    final total = tongThu;
                                                    final percent =
                                                        total > 0
                                                            ? (e['tong']
                                                                    as double) /
                                                                total *
                                                                100
                                                            : 0.0;
                                                    return PieChartSectionData(
                                                      color: color,
                                                      value:
                                                          e['tong'] as double,
                                                      title:
                                                          percent > 0
                                                              ? '${percent.toStringAsFixed(0)}%'
                                                              : '',
                                                      titleStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      radius: 60,
                                                    );
                                                  },
                                                ),
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 32,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        children: [
                                          for (
                                            int i = 0;
                                            i <
                                                danhMucStats
                                                    .where(
                                                      (e) => e['loai'] == 1,
                                                    )
                                                    .length;
                                            i++
                                          )
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 14,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        [
                                                          Colors.green,
                                                          Colors.blue,
                                                          Colors.orange,
                                                          Colors.teal,
                                                          Colors.purple,
                                                          Colors.amber,
                                                          Colors.cyan,
                                                          Colors.indigo,
                                                          Colors.pink,
                                                          Colors.lime,
                                                        ][i % 10],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${danhMucStats.where((e) => e['loai'] == 1).toList()[i]['icon']} ${danhMucStats.where((e) => e['loai'] == 1).toList()[i]['ten']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
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
                            // Pie chart chi phí
                            if (danhMucStats.any((e) => e['loai'] == 2))
                              Card(
                                color: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tỷ lệ chi phí theo danh mục',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[800],
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        height: 180,
                                        child: Builder(
                                          builder: (context) {
                                            final chiList =
                                                danhMucStats
                                                    .where(
                                                      (e) => e['loai'] == 2,
                                                    )
                                                    .toList();
                                            final colors = [
                                              Colors.redAccent,
                                              Colors.blue,
                                              Colors.orange,
                                              Colors.teal,
                                              Colors.purple,
                                              Colors.amber,
                                              Colors.cyan,
                                              Colors.indigo,
                                              Colors.pink,
                                              Colors.lime,
                                            ];
                                            return PieChart(
                                              PieChartData(
                                                sections: List.generate(
                                                  chiList.length,
                                                  (i) {
                                                    final e = chiList[i];
                                                    final color =
                                                        colors[i %
                                                            colors.length];
                                                    final total = tongChi;
                                                    final percent =
                                                        total > 0
                                                            ? (e['tong']
                                                                    as double) /
                                                                total *
                                                                100
                                                            : 0.0;
                                                    return PieChartSectionData(
                                                      color: color,
                                                      value:
                                                          e['tong'] as double,
                                                      title:
                                                          percent > 0
                                                              ? '${percent.toStringAsFixed(0)}%'
                                                              : '',
                                                      titleStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      radius: 60,
                                                    );
                                                  },
                                                ),
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 32,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        children: [
                                          for (
                                            int i = 0;
                                            i <
                                                danhMucStats
                                                    .where(
                                                      (e) => e['loai'] == 2,
                                                    )
                                                    .length;
                                            i++
                                          )
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 14,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        [
                                                          Colors.redAccent,
                                                          Colors.blue,
                                                          Colors.orange,
                                                          Colors.teal,
                                                          Colors.purple,
                                                          Colors.amber,
                                                          Colors.cyan,
                                                          Colors.indigo,
                                                          Colors.pink,
                                                          Colors.lime,
                                                        ][i % 10],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${danhMucStats.where((e) => e['loai'] == 2).toList()[i]['icon']} ${danhMucStats.where((e) => e['loai'] == 2).toList()[i]['ten']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
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
                          ],
                          SizedBox(height: 10),
                          // Bar chart so sánh số tiền giữa các danh mục
                          if (danhMucStats.isNotEmpty)
                            Card(
                              color: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'So sánh số tiền giữa các danh mục',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    AspectRatio(
                                      aspectRatio: 1.5, // Adjust as needed
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY:
                                              danhMucStats.isNotEmpty
                                                  ? danhMucStats
                                                          .map(
                                                            (e) =>
                                                                e['tong']
                                                                    as double,
                                                          )
                                                          .reduce(
                                                            (a, b) =>
                                                                a > b ? a : b,
                                                          ) *
                                                      1.2
                                                  : 100, // Default maxY if no data
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            touchTooltipData: BarTouchTooltipData(
                                              tooltipBgColor:
                                                  Colors.transparent,
                                              getTooltipItem: (
                                                group,
                                                groupIndex,
                                                rod,
                                                rodIndex,
                                              ) {
                                                final value = rod.toY;
                                                final displayValue =
                                                    value.truncateToDouble() ==
                                                            value
                                                        ? value
                                                            .toInt()
                                                            .toString()
                                                        : value.toString();
                                                return BarTooltipItem(
                                                  '$displayValue đ',
                                                  const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  final idx = value.toInt();
                                                  if (idx < 0 ||
                                                      idx >=
                                                          danhMucStats.length)
                                                    return SizedBox();
                                                  final e = danhMucStats[idx];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 4.0,
                                                        ),
                                                    child: Text(
                                                      e['icon'] ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                reservedSize: 32,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),

                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          barGroups: [
                                            for (
                                              int i = 0;
                                              i < danhMucStats.length;
                                              i++
                                            )
                                              BarChartGroupData(
                                                x: i,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY:
                                                        (danhMucStats[i]['tong']
                                                            as double),
                                                    color:
                                                        danhMucStats[i]['loai'] ==
                                                                1
                                                            ? Colors.green
                                                            : Colors.redAccent,
                                                    width: 18,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    rodStackItems: [],
                                                  ),
                                                ],
                                                showingTooltipIndicators: [],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 12,
                                      children: [
                                        for (var e in danhMucStats)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color:
                                                      e['loai'] == 1
                                                          ? Colors.green
                                                          : Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${e['icon']} ${e['ten']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          danhMucStats.isEmpty
                              ? Center(child: Text('Không có dữ liệu'))
                              : ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                itemCount: danhMucStats.length,
                                separatorBuilder:
                                    (_, __) => SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final dm = danhMucStats[index];
                                  final isThu = dm['loai'] == 1;
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            isThu
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                        child: Text(
                                          dm['icon'] ?? '',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      title: Text(
                                        dm['ten'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${(dm['tong'] as double).toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isThu ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      onTap:
                                          selectedMonth == null
                                              ? null
                                              : () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          _,
                                                        ) => ChiTietDanhMucScreen(
                                                          danhMucId: dm['id'],
                                                          tenDanhMuc: dm['ten'],
                                                          icon: dm['icon'],
                                                          loai: dm['loai'],
                                                          tong: dm['tong'],
                                                          month: selectedMonth!,
                                                          year: selectedYear,
                                                          tongChi: tongChi,
                                                        ),
                                                  ),
                                                );
                                              },
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
