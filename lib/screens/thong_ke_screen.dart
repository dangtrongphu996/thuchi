import 'package:flutter/material.dart';
import 'package:thuchi/db/database_helper.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import 'package:intl/intl.dart';
import 'them_chi_tiet_screen.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';

class ThongKeScreen extends StatefulWidget {
  const ThongKeScreen({super.key});

  @override
  State<ThongKeScreen> createState() => _ThongKeScreenState();
}

class _ThongKeScreenState extends State<ThongKeScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  double tongThu = 0;
  double tongChi = 0;
  double minThu = 0;
  double maxThu = 0;
  double avgThu = 0;
  double minChi = 0;
  double maxChi = 0;
  double avgChi = 0;
  String minThuDate = '';
  String maxThuDate = '';
  String minChiDate = '';
  String maxChiDate = '';
  List<ChiTietChiTieuDanhMuc> _list = [];

  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();

  Future<void> tinhTongThuChi() async {
    final list = await _ctDao.getByMonth(selectedMonth, selectedYear);
    final danhMucs = await _dmDao.getAllDanhMuc();

    tongThu = 0;
    tongChi = 0;
    List<double> thuList = [];
    List<double> chiList = [];
    List<ChiTietChiTieuDanhMuc> thuItems = [];
    List<ChiTietChiTieuDanhMuc> chiItems = [];

    // Sort list by date in descending order
    list.sort(
      (a, b) => DateTime.parse(
        b.chiTietChiTieu.ngay,
      ).compareTo(DateTime.parse(a.chiTietChiTieu.ngay)),
    );

    for (var item in list) {
      final dm = danhMucs.firstWhere(
        (e) => e.id == item.chiTietChiTieu.danhMucId,
      );
      if (dm.loai == 1) {
        tongThu += item.chiTietChiTieu.soTien;
        thuList.add(item.chiTietChiTieu.soTien);
        thuItems.add(item);
      } else {
        tongChi += item.chiTietChiTieu.soTien;
        chiList.add(item.chiTietChiTieu.soTien);
        chiItems.add(item);
      }
    }

    // Tính toán thống kê và ngày tháng
    minThu = thuList.isNotEmpty ? thuList.reduce((a, b) => a < b ? a : b) : 0;
    maxThu = thuList.isNotEmpty ? thuList.reduce((a, b) => a > b ? a : b) : 0;
    avgThu =
        thuList.isNotEmpty
            ? thuList.reduce((a, b) => a + b) / thuList.length
            : 0;
    minChi = chiList.isNotEmpty ? chiList.reduce((a, b) => a < b ? a : b) : 0;
    maxChi = chiList.isNotEmpty ? chiList.reduce((a, b) => a > b ? a : b) : 0;
    avgChi =
        chiList.isNotEmpty
            ? chiList.reduce((a, b) => a + b) / chiList.length
            : 0;

    minThuDate = '';
    maxThuDate = '';
    minChiDate = '';
    maxChiDate = '';
    if (thuList.isNotEmpty) {
      final minThuItem = thuItems.firstWhere(
        (e) => e.chiTietChiTieu.soTien == minThu,
        orElse: () => thuItems.first,
      );
      final maxThuItem = thuItems.firstWhere(
        (e) => e.chiTietChiTieu.soTien == maxThu,
        orElse: () => thuItems.first,
      );
      minThuDate = DatabaseHelper.convertDate(minThuItem.chiTietChiTieu.ngay);
      maxThuDate = DatabaseHelper.convertDate(maxThuItem.chiTietChiTieu.ngay);
    }
    if (chiList.isNotEmpty) {
      final minChiItem = chiItems.firstWhere(
        (e) => e.chiTietChiTieu.soTien == minChi,
        orElse: () => chiItems.first,
      );
      final maxChiItem = chiItems.firstWhere(
        (e) => e.chiTietChiTieu.soTien == maxChi,
        orElse: () => chiItems.first,
      );
      minChiDate = DatabaseHelper.convertDate(minChiItem.chiTietChiTieu.ngay);
      maxChiDate = DatabaseHelper.convertDate(maxChiItem.chiTietChiTieu.ngay);
    }

    setState(() {
      _list = list;
    });
  }

  Future<void> _deleteTransaction(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
            actions: [
              TextButton(
                child: Text('Hủy'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _ctDao.delete(id);
      tinhTongThuChi();
    }
  }

  @override
  void initState() {
    super.initState();
    tinhTongThuChi();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 2 + i);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thống kê Thu / Chi',
          style: TextStyle(
            fontSize: 'Thống kê Thu / Chi'.length > 20 ? 16 : 20,
          ),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () {
              tinhTongThuChi();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          value: selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'Chọn tháng',
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: Color(0xFF2196F3),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8,
                            ),
                          ),
                          items:
                              List.generate(12, (i) => i + 1)
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text("Tháng $e"),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedMonth = value;
                                tinhTongThuChi();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          value: selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Chọn năm',
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: Color(0xFF2196F3),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8,
                            ),
                          ),
                          items:
                              years
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text("$e"),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedYear = value;
                                tinhTongThuChi();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Tổng thu',
                      icon: Icons.arrow_upward,
                      amount: tongThu,
                      color: const Color(0xFF4CAF50),
                      background: const Color(0xFFE8F5E9),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Tổng chi',
                      icon: Icons.arrow_downward,
                      amount: tongChi,
                      color: const Color(0xFFF44336),
                      background: const Color(0xFFFFEBEE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Thống kê thu nhập và chi phí theo phong cách thong_ke_thang_danh_muc_screen.dart
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
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
                            Icons.arrow_upward,
                            color: Color(0xFF388E3C),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Thu nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
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
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Cao nhất:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${maxThu.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          if (maxThuDate.isNotEmpty) ...[
                            SizedBox(width: 8),
                            Text(
                              '($maxThuDate)',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_down,
                            color: Colors.purple,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Thấp nhất:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${minThu.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          if (minThuDate.isNotEmpty) ...[
                            SizedBox(width: 8),
                            Text(
                              '($minThuDate)',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: Colors.teal, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Trung bình:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${avgThu.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 28,
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Color(0xFFD32F2F),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Chi phí',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
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
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Cao nhất:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${maxChi.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          if (maxChiDate.isNotEmpty) ...[
                            SizedBox(width: 8),
                            Text(
                              '($maxChiDate)',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_down,
                            color: Colors.purple,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Thấp nhất:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${minChi.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          if (minChiDate.isNotEmpty) ...[
                            SizedBox(width: 8),
                            Text(
                              '($minChiDate)',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: Colors.teal, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Trung bình:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${avgChi.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi tiết giao dịch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _list.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _list[index];
                          final isThu = item.danhMuc.loai == 1;
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        isThu
                                            ? Color(0xFFE8F5E9)
                                            : Color(0xFFFFEBEE),
                                    radius: 20,
                                    child: Icon(
                                      isThu
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color:
                                          isThu
                                              ? Color(0xFF4CAF50)
                                              : Color(0xFFF44336),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.danhMuc.ten,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          DatabaseHelper.convertDate(
                                            item.chiTietChiTieu.ngay,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${item.chiTietChiTieu.soTien.toStringAsFixed(0)} đ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isThu
                                              ? Color(0xFF4CAF50)
                                              : Color(0xFFF44336),
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ThemChiTietScreen(
                                                chiTiet: item.chiTietChiTieu,
                                                danhMuc: item.danhMuc,
                                              ),
                                        ),
                                      ).then((_) {
                                        tinhTongThuChi();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _deleteTransaction(
                                        item.chiTietChiTieu.id!,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required double amount,
    required Color color,
    required Color background,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "${amount.toStringAsFixed(0)} đ",
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
