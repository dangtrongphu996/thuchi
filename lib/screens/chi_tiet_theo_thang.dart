import 'package:flutter/material.dart';
import 'package:thuchi/screens/thong_ke_thang_danh_muc_screen.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../screens/them_chi_tiet_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import 'thong_ke_nam_danh_muc_screen.dart';

class ChiTietTheoThangScreen extends StatefulWidget {
  final int? selectedMonth;
  final int selectedYear;
  final int? type; // 1: income, 2: expense, null: both
  const ChiTietTheoThangScreen({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    this.type,
  });

  @override
  State<ChiTietTheoThangScreen> createState() => _ChiTietTheoThangScreenState();
}

class _ChiTietTheoThangScreenState extends State<ChiTietTheoThangScreen> {
  late int? selectedMonth;
  late int selectedYear;
  late int? type;
  List<ChiTietChiTieuDanhMuc> _list = [];
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  double tongThu = 0;
  double tongChi = 0;
  bool showThu = true;
  bool showChi = true;
  final DanhMucDao _danhMucDao = DanhMucDao();
  Map<int, double> tongTienTheoDanhMuc = {};
  List<DanhMuc> danhMucs = [];
  bool isLoading = true;

  List<ChiTietChiTieuDanhMuc> get _filteredList {
    return _list.where((ct) {
      final isThu = ct.danhMuc.loai == 1;
      if (type == 1) return isThu;
      if (type == 2) return !isThu;
      if (isThu && showThu) return true;
      if (!isThu && showChi) return true;
      return false;
    }).toList();
  }

  Future<void> loadData() async {
    final data =
        selectedMonth == null
            ? await _dao.getByYear(selectedYear)
            : await _dao.getByMonth(selectedMonth!, selectedYear);
    data.sort(
      (a, b) => DateTime.parse(
        b.chiTietChiTieu.ngay,
      ).compareTo(DateTime.parse(a.chiTietChiTieu.ngay)),
    );
    setState(() {
      _list = data;
      tongThu = 0;
      tongChi = 0;
      for (var ct in _list) {
        if (ct.danhMuc.loai == 1) {
          tongThu += ct.chiTietChiTieu.soTien;
        } else {
          tongChi += ct.chiTietChiTieu.soTien;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.selectedMonth;
    selectedYear = widget.selectedYear;
    type = widget.type;
    initializeDateFormatting('vi').then((_) => loadData());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final allDanhMuc = await _danhMucDao.getAllDanhMuc();
    final allTrans = await _dao.getAll();
    final filtered =
        allTrans.where((e) {
          final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
          if (ngay == null) return false;
          if (selectedMonth != null && ngay.month != selectedMonth)
            return false;
          if (ngay.year != selectedYear) return false;
          if (type != null && e.danhMuc.loai != type) return false;
          return true;
        }).toList();
    tongTienTheoDanhMuc.clear();
    for (var e in filtered) {
      tongTienTheoDanhMuc[e.danhMuc.id!] =
          (tongTienTheoDanhMuc[e.danhMuc.id!] ?? 0) + e.chiTietChiTieu.soTien;
    }
    danhMucs =
        allDanhMuc.where((dm) => tongTienTheoDanhMuc[dm.id] != null).toList();
    // Sắp xếp giảm dần theo số tiền
    danhMucs.sort(
      (a, b) => (tongTienTheoDanhMuc[b.id] ?? 0).compareTo(
        tongTienTheoDanhMuc[a.id] ?? 0,
      ),
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách năm mặc định
    List<int> years = List.generate(5, (i) => 2020 + i);
    if (!years.contains(selectedYear)) {
      years.add(selectedYear);
      years.sort();
    }
    // Pie chart data
    Map<int, String> tenDanhMuc = {};
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    // Filter _list for pie chart according to mode
    List<ChiTietChiTieuDanhMuc> pieList = _list;
    if (type == 1) {
      pieList = _list.where((ct) => ct.danhMuc.loai == 1).toList();
    } else if (type == 2) {
      pieList = _list.where((ct) => ct.danhMuc.loai == 2).toList();
    }
    // Xây dựng tenDanhMuc từ danhMucs đã lọc
    for (var dm in danhMucs) {
      tenDanhMuc[dm.id!] = '${dm.icon ?? ''} ${dm.ten}';
    }
    final double tongAll = tongTienTheoDanhMuc.values.fold(
      0.0,
      (a, b) => a + b,
    );
    final pieSections =
        tongTienTheoDanhMuc.entries.map((e) {
          final idx = tongTienTheoDanhMuc.keys.toList().indexOf(e.key);
          final percent = tongAll > 0 ? (e.value / tongAll * 100) : 0;
          final name = tenDanhMuc[e.key] ?? '';
          return PieChartSectionData(
            title: '$name\n${percent.toStringAsFixed(0)}%',
            value: e.value,
            color: colors[idx % colors.length],
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();
    String pieTitle;
    if (type == 1) {
      pieTitle = 'Tỷ lệ thu nhập theo danh mục';
    } else if (type == 2) {
      pieTitle = 'Tỷ lệ chi phí theo danh mục';
    } else {
      pieTitle = 'Tỷ lệ thu/chi theo danh mục';
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          type == 1
              ? 'Chi tiết thu nhập theo ' +
                  (selectedMonth == null ? 'năm' : 'tháng')
              : type == 2
              ? 'Chi tiết chi phí theo ' +
                  (selectedMonth == null ? 'năm' : 'tháng')
              : 'Chi tiết theo ' + (selectedMonth == null ? 'năm' : 'tháng'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize:
                (type == 1
                                ? 'Chi tiết thu nhập theo ' +
                                    (selectedMonth == null ? 'năm' : 'tháng')
                                : type == 2
                                ? 'Chi tiết chi phí theo ' +
                                    (selectedMonth == null ? 'năm' : 'tháng')
                                : 'Chi tiết theo ' +
                                    (selectedMonth == null ? 'năm' : 'tháng'))
                            .length >
                        20
                    ? 16
                    : 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () async {
              setState(() => isLoading = true);
              await _loadData();
              await loadData();
              setState(() => isLoading = false);
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            elevation: 5,
                            shadowColor: Colors.blue.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.blue.shade700,
                                  ),
                                  SizedBox(width: 8),
                                  DropdownButton<int?>(
                                    value: selectedMonth,
                                    underline: SizedBox(),
                                    items: [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text('Cả năm'),
                                      ),
                                      ...List.generate(12, (i) => i + 1)
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                'Tháng $e',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ],
                                    onChanged: (value) async {
                                      setState(() => isLoading = true);
                                      selectedMonth = value;
                                      await _loadData();
                                      await loadData();
                                      setState(() => isLoading = false);
                                    },
                                  ),
                                  SizedBox(width: 16),
                                  DropdownButton<int>(
                                    value: selectedYear,
                                    underline: SizedBox(),
                                    items:
                                        years
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  '$e',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) async {
                                      setState(() => isLoading = true);
                                      selectedYear = value!;
                                      await _loadData();
                                      await loadData();
                                      setState(() => isLoading = false);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade100,
                                    Colors.blue.shade50,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade50.withOpacity(
                                      0.2,
                                    ),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (type == null || type == 1)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.savings,
                                                color: Colors.green,
                                                size: 22,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Tổng thu',
                                                style: TextStyle(
                                                  color: Colors.green.shade800,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            '${tongThu.toStringAsFixed(0)} đ',
                                            style: TextStyle(
                                              color: Colors.green.shade900,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if ((type == null || type == 1) &&
                                        (type == null || type == 2))
                                      Container(
                                        width: 1,
                                        height: 38,
                                        color: Colors.grey.shade300,
                                      ),
                                    if (type == null || type == 2)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.money_off,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Tổng chi',
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            '${tongChi.toStringAsFixed(0)} đ',
                                            style: TextStyle(
                                              color: Colors.red.shade900,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (type == null) ...[
                                Checkbox(
                                  value: showThu,
                                  activeColor: Colors.green,
                                  onChanged: (val) {
                                    setState(() {
                                      showThu = val!;
                                    });
                                  },
                                ),
                                Text(
                                  'Thu nhập',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Checkbox(
                                  value: showChi,
                                  activeColor: Colors.red,
                                  onChanged: (val) {
                                    setState(() {
                                      showChi = val!;
                                    });
                                  },
                                ),
                                Text(
                                  'Chi phí',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        if (pieSections.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Card(
                              elevation: 3,
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      pieTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      height: 180,
                                      child: PieChart(
                                        PieChartData(
                                          sections: pieSections,
                                          centerSpaceRadius: 40,
                                          sectionsSpace: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Danh sách tổng số tiền đã sử dụng cho từng danh mục trong tháng/năm được chọn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                danhMucs.isEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Center(
                                        child: Text(
                                          'Không có danh mục nào',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    : ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(12),
                                      itemCount: danhMucs.length,
                                      separatorBuilder:
                                          (_, __) => SizedBox(height: 10),
                                      itemBuilder: (context, idx) {
                                        final dm = danhMucs[idx];
                                        final tong =
                                            tongTienTheoDanhMuc[dm.id] ?? 0;
                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: ListTile(
                                            leading: Text(
                                              dm.icon ?? '',
                                              style: TextStyle(fontSize: 28),
                                            ),
                                            title: Text(
                                              dm.ten,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            trailing: Text(
                                              '${tong.toStringAsFixed(0)} đ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    dm.loai == 1
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          ThongKeThangDanhMucScreen(
                                                            danhMuc: dm,
                                                            selectedMonth:
                                                                selectedMonth,
                                                            selectedYear:
                                                                selectedYear,
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
                        SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Danh sách giao dịch',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                _filteredList.isEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Center(
                                        child: Text(
                                          'Không có giao dịch nào',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    : ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(12),
                                      itemCount: _filteredList.length,
                                      separatorBuilder:
                                          (_, __) => SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final ct = _filteredList[index];
                                        final isThu = ct.danhMuc.loai == 1;
                                        final Color mainColor =
                                            isThu
                                                ? Colors.green
                                                : Colors.redAccent;
                                        final Color bgColor =
                                            isThu
                                                ? Colors.green.shade100
                                                : Colors.red.shade100;
                                        return Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                                    ct.danhMuc.icon ?? '',
                                                    style: TextStyle(
                                                      fontSize: 28,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        ct.danhMuc.ten,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      if ((ct
                                                                  .chiTietChiTieu
                                                                  .ghiChu ??
                                                              '')
                                                          .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 2.0,
                                                              ),
                                                          child: Text(
                                                            ct
                                                                    .chiTietChiTieu
                                                                    .ghiChu ??
                                                                '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .grey[700],
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 14,
                                                            color:
                                                                Colors
                                                                    .grey[400],
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            ct
                                                                .chiTietChiTieu
                                                                .ngay,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${ct.chiTietChiTieu.soTien.toStringAsFixed(0)} đ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: mainColor,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Colors.blue,
                                                          ),
                                                          tooltip: 'Chỉnh sửa',
                                                          onPressed: () async {
                                                            await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      _,
                                                                    ) => ThemChiTietScreen(
                                                                      chiTiet:
                                                                          ct.chiTietChiTieu,
                                                                      danhMuc:
                                                                          ct.danhMuc,
                                                                    ),
                                                              ),
                                                            );
                                                            loadData();
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          tooltip: 'Xóa',
                                                          onPressed: () async {
                                                            final confirm = await showDialog<
                                                              bool
                                                            >(
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => AlertDialog(
                                                                    title: Text(
                                                                      'Xác nhận xóa',
                                                                    ),
                                                                    content: Text(
                                                                      'Bạn có chắc muốn xóa giao dịch này?',
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        child: Text(
                                                                          'Hủy',
                                                                        ),
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              context,
                                                                              false,
                                                                            ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        child: Text(
                                                                          'Xóa',
                                                                        ),
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                        ),
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              context,
                                                                              true,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            );
                                                            if (confirm ==
                                                                true) {
                                                              await _dao.delete(
                                                                ct
                                                                    .chiTietChiTieu
                                                                    .id!,
                                                              );
                                                              loadData();
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
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
