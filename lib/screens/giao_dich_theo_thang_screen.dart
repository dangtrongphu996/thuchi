import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thuchi/screens/thong_ke_thang_danh_muc_screen.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'them_chi_tiet_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chi_tiet_danh_muc_screen.dart';
import 'chi_tiet_theo_thang.dart';
import '../models/danh_muc.dart';
import '../db/muc_tieu_thang_dao.dart';
import '../models/muc_tieu_thang.dart';

class GiaoDichTheoThangScreen extends StatefulWidget {
  const GiaoDichTheoThangScreen({Key? key}) : super(key: key);

  @override
  State<GiaoDichTheoThangScreen> createState() =>
      _GiaoDichTheoThangScreenState();
}

class _GiaoDichTheoThangScreenState extends State<GiaoDichTheoThangScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  final MucTieuThangDao _mucTieuDao = MucTieuThangDao();
  List<DateTime> _months = [];
  Map<String, List<ChiTietChiTieuDanhMuc>> _dataByMonth = {};
  bool _loading = true;
  int _initialPage = 0;

  MucTieuThang? _mucTieuThu;
  MucTieuThang? _mucTieuChi;

  @override
  void initState() {
    super.initState();
    _fetchMonthsAndData();
  }

  Future<void> _fetchMonthsAndData() async {
    final all = await _dao.getAll();
    final Set<String> monthKeys = {};
    final Map<String, List<ChiTietChiTieuDanhMuc>> grouped = {};
    for (var e in all) {
      final ngay = DateTime.parse(e.chiTietChiTieu.ngay);
      final key = '${ngay.year}-${ngay.month.toString().padLeft(2, '0')}';
      monthKeys.add(key);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final months =
        monthKeys.map((k) {
          final parts = k.split('-');
          return DateTime(int.parse(parts[0]), int.parse(parts[1]));
        }).toList();
    months.sort((a, b) => a.compareTo(b)); // đảo thứ tự: cũ -> mới
    final nowKey =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    _initialPage = months.indexWhere(
      (m) => '${m.year}-${m.month.toString().padLeft(2, '0')}' == nowKey,
    );
    if (_initialPage < 0) _initialPage = months.length - 1;
    // Lấy mục tiêu tháng hiện tại
    if (months.isNotEmpty) {
      final currentMonth = months[_initialPage];
      _mucTieuThu = await _mucTieuDao.getByMonthAndType(
        currentMonth.month,
        currentMonth.year,
        1,
      );
      _mucTieuChi = await _mucTieuDao.getByMonthAndType(
        currentMonth.month,
        currentMonth.year,
        2,
      );
    } else {
      _mucTieuThu = null;
      _mucTieuChi = null;
    }
    setState(() {
      _months = months;
      _dataByMonth = grouped;
      _loading = false;
    });
  }

  Color _getTypeColor(int loai) => loai == 1 ? Colors.green : Colors.red;
  IconData _getTypeIcon(int loai) =>
      loai == 1 ? Icons.arrow_upward : Icons.arrow_downward;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch theo tháng'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _months.isEmpty
              ? const Center(
                child: Text('Không có dữ liệu giao dịch theo tháng'),
              )
              : PageView.builder(
                controller: PageController(initialPage: _initialPage),
                itemCount: _months.length,
                itemBuilder: (context, page) {
                  final month = _months[page];
                  final key =
                      '${month.year}-${month.month.toString().padLeft(2, '0')}';
                  final data = _dataByMonth[key] ?? [];
                  final thuNhap =
                      data.where((e) => e.danhMuc.loai == 1).toList();
                  final chiPhi =
                      data.where((e) => e.danhMuc.loai == 2).toList();
                  thuNhap.sort(
                    (a, b) => b.chiTietChiTieu.soTien.compareTo(
                      a.chiTietChiTieu.soTien,
                    ),
                  );
                  chiPhi.sort(
                    (a, b) => b.chiTietChiTieu.soTien.compareTo(
                      a.chiTietChiTieu.soTien,
                    ),
                  );
                  final tongThu = thuNhap.fold(
                    0.0,
                    (sum, e) => sum + e.chiTietChiTieu.soTien,
                  );
                  final tongChi = chiPhi.fold(
                    0.0,
                    (sum, e) => sum + e.chiTietChiTieu.soTien,
                  );
                  final conLai = tongThu - tongChi;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header tháng
                          Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.teal.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: Colors.teal,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      DateFormat('MM/yyyy').format(month),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Biểu đồ PieChart
                          if (tongThu > 0 || tongChi > 0)
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Tỷ lệ Thu/Chi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      height: 110,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: tongThu,
                                              title:
                                                  tongThu + tongChi > 0
                                                      ? 'Thu ${(tongThu / (tongThu + tongChi) * 100).toStringAsFixed(0)}%'
                                                      : 'Thu',
                                              radius: 38,
                                              titleStyle: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            PieChartSectionData(
                                              color: Colors.red,
                                              value: tongChi,
                                              title:
                                                  tongThu + tongChi > 0
                                                      ? 'Chi ${(tongChi / (tongThu + tongChi) * 100).toStringAsFixed(0)}%'
                                                      : 'Chi',
                                              radius: 38,
                                              titleStyle: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Legend
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              color: Colors.green,
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                            ),
                                            const Text(
                                              'Thu nhập',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 18),
                                        Row(
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              color: Colors.red,
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                            ),
                                            const Text(
                                              'Chi phí',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          // Tổng hợp số tiền và tổng số giao dịch
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 18,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Thu nhập',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        '${tongThu.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        'Số giao dịch: ${thuNhap.length}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                        ),
                                      ),
                                      if (_mucTieuThu != null)
                                        _buildProgressBar(
                                          tongThu,
                                          _mucTieuThu!.soTien,
                                          Colors.green,
                                          'Mục tiêu thu nhập',
                                        ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.shade300,
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Chi phí',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        '${tongChi.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        'Số giao dịch: ${chiPhi.length}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                      if (_mucTieuChi != null)
                                        _buildProgressBar(
                                          tongChi,
                                          _mucTieuChi!.soTien,
                                          Colors.red,
                                          'Mục tiêu chi phí',
                                        ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.shade300,
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Còn lại',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        '${conLai.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Danh sách danh mục thu nhập và chi phí
                          const SizedBox(height: 18),
                          const Text(
                            'Danh mục Thu nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          _buildCategoryList(data, 1, tongThu),
                          const SizedBox(height: 12),
                          const Text(
                            'Danh mục Chi phí',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          _buildCategoryList(data, 2, tongChi),
                          const SizedBox(height: 18),
                          // Danh sách thu nhập
                          Text(
                            'Danh sách Thu nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          thuNhap.isEmpty
                              ? _buildEmptyTransaction(
                                'Không có giao dịch thu nhập',
                                Colors.green,
                              )
                              : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: thuNhap.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, idx) {
                                  final ct = thuNhap[idx].chiTietChiTieu;
                                  final dm = thuNhap[idx].danhMuc;
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green.shade100,
                                        radius: 26,
                                        child: Icon(
                                          _getTypeIcon(1),
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                      ),
                                      title: Text(
                                        '${ct.soTien.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 17,
                                        ),
                                      ),
                                      subtitle: Text(
                                        dm.ten +
                                            (ct.ghiChu.isNotEmpty
                                                ? ' - ${ct.ghiChu}'
                                                : ''),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => ThemChiTietScreen(
                                                        chiTiet: ct,
                                                        danhMuc: dm,
                                                      ),
                                                ),
                                              );
                                              _fetchMonthsAndData();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'Xác nhận xóa',
                                                      ),
                                                      content: const Text(
                                                        'Bạn có chắc chắn muốn xóa giao dịch này?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: const Text(
                                                            'Hủy',
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            'Xóa',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                await _dao.delete(ct.id!);
                                                _fetchMonthsAndData();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          const SizedBox(height: 10),
                          // Danh sách chi phí
                          Text(
                            'Danh sách Chi phí',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          chiPhi.isEmpty
                              ? _buildEmptyTransaction(
                                'Không có giao dịch chi phí',
                                Colors.red,
                              )
                              : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chiPhi.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, idx) {
                                  final ct = chiPhi[idx].chiTietChiTieu;
                                  final dm = chiPhi[idx].danhMuc;
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        radius: 26,
                                        child: Icon(
                                          _getTypeIcon(2),
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                      ),
                                      title: Text(
                                        '${ct.soTien.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 17,
                                        ),
                                      ),
                                      subtitle: Text(
                                        dm.ten +
                                            (ct.ghiChu.isNotEmpty
                                                ? ' - ${ct.ghiChu}'
                                                : ''),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => ThemChiTietScreen(
                                                        chiTiet: ct,
                                                        danhMuc: dm,
                                                      ),
                                                ),
                                              );
                                              _fetchMonthsAndData();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'Xác nhận xóa',
                                                      ),
                                                      content: const Text(
                                                        'Bạn có chắc chắn muốn xóa giao dịch này?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: const Text(
                                                            'Hủy',
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            'Xóa',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                await _dao.delete(ct.id!);
                                                _fetchMonthsAndData();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _months.isEmpty
              ? null
              : Builder(
                builder: (context) {
                  final pageController = PageController(
                    initialPage: _initialPage,
                  );
                  return FloatingActionButton(
                    backgroundColor: Colors.teal,
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      // Lấy tháng đang xem
                      final page =
                          (pageController.hasClients
                              ? pageController.page?.round()
                              : _initialPage) ??
                          _initialPage;
                      final month = _months[page];
                      final date = DateTime(month.year, month.month, 1);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ThemChiTietScreen(
                                chiTiet: null,
                                danhMuc: null,
                              ),
                        ),
                      );
                      _fetchMonthsAndData();
                    },
                    tooltip: 'Thêm giao dịch cho tháng này',
                  );
                },
              ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              '${value.toInt()} đ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransaction(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    double value,
    double target,
    Color color,
    String label,
  ) {
    final percent = target > 0 ? (value / target).clamp(0, 1) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SizedBox(
          width: 110,
          child: LinearProgressIndicator(
            value: percent.toDouble(),
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$label: ${value.toInt()} / ${target.toInt()} đ (${(percent * 100).toStringAsFixed(1)}%)',
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

Widget _buildCategoryList(
  List<ChiTietChiTieuDanhMuc> data,
  int loai,
  double tongSoTien,
) {
  // Gom nhóm theo danh mục
  final Map<String, double> tongTienTheoDanhMuc = {};
  final Map<String, String> tenDanhMuc = {};
  for (var e in data) {
    if (e.danhMuc.loai == loai) {
      tongTienTheoDanhMuc[e.danhMuc.id.toString()] =
          (tongTienTheoDanhMuc[e.danhMuc.id.toString()] ?? 0) +
          e.chiTietChiTieu.soTien;
      tenDanhMuc[e.danhMuc.id.toString()] = e.danhMuc.ten;
    }
  }
  final sorted =
      tongTienTheoDanhMuc.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  if (sorted.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        loai == 1 ? 'Không có danh mục thu nhập' : 'Không có danh mục chi phí',
        style: TextStyle(color: loai == 1 ? Colors.green : Colors.red),
      ),
    );
  }
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: sorted.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, idx) {
      final id = sorted[idx].key;
      final ten = tenDanhMuc[id] ?? '';
      final soTien = sorted[idx].value;
      final percent = tongSoTien > 0 ? (soTien / tongSoTien * 100) : 0;
      final color = loai == 1 ? Colors.green : Colors.red;
      final icon = loai == 1 ? Icons.arrow_upward : Icons.arrow_downward;
      // Lấy icon emoji nếu có
      String? emoji;
      DanhMuc? danhMucObj;
      for (var e in data) {
        if (e.danhMuc.id.toString() == id) {
          if (e.danhMuc.icon != null && e.danhMuc.icon!.isNotEmpty) {
            emoji = e.danhMuc.icon;
          }
          danhMucObj = e.danhMuc;
          break;
        }
      }
      // Lấy tháng/năm từ giao dịch đầu tiên của danh mục
      final firstItem = data.firstWhere(
        (e) => e.danhMuc.id.toString() == id,
        orElse: () => data.first,
      );
      final month =
          firstItem.chiTietChiTieu.ngay.length >= 7
              ? DateTime.parse(firstItem.chiTietChiTieu.ngay).month
              : DateTime.now().month;
      final year =
          firstItem.chiTietChiTieu.ngay.length >= 7
              ? DateTime.parse(firstItem.chiTietChiTieu.ngay).year
              : DateTime.now().year;
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child:
                emoji != null
                    ? Text(emoji, style: const TextStyle(fontSize: 20))
                    : Icon(icon, color: color, size: 22),
          ),
          title: Text(
            ten,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${soTien.toInt()} đ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              Text(
                '(${percent.toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.blue, fontSize: 13),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ThongKeThangDanhMucScreen(
                      selectedMonth: month,
                      selectedYear: year,
                      danhMuc: danhMucObj!,
                    ),
              ),
            );
          },
        ),
      );
    },
  );
}
