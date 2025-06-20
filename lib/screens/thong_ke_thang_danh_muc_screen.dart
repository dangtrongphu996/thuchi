import 'package:flutter/material.dart';
import 'package:thuchi/screens/them_chi_tiet_screen.dart';
import '../models/danh_muc.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'package:intl/intl.dart';

class ThongKeThangDanhMucScreen extends StatefulWidget {
  final DanhMuc danhMuc;
  final int? selectedMonth;
  final int? selectedYear;
  const ThongKeThangDanhMucScreen({
    super.key,
    required this.danhMuc,
    this.selectedMonth,
    this.selectedYear,
  });

  @override
  State<ThongKeThangDanhMucScreen> createState() =>
      _ThongKeThangDanhMucScreenState();
}

class _ThongKeThangDanhMucScreenState extends State<ThongKeThangDanhMucScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  List<ChiTietChiTieuDanhMuc> list = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.selectedMonth ?? DateTime.now().month;
    selectedYear = widget.selectedYear ?? DateTime.now().year;
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final all = await _dao.getAll();
    list =
        all
            .where(
              (ct) =>
                  ct.danhMuc.id == widget.danhMuc.id &&
                  DateTime.parse(ct.chiTietChiTieu.ngay).year == selectedYear &&
                  DateTime.parse(ct.chiTietChiTieu.ngay).month == selectedMonth,
            )
            .toList();
    list.sort(
      (a, b) => DateTime.parse(
        b.chiTietChiTieu.ngay,
      ).compareTo(DateTime.parse(a.chiTietChiTieu.ngay)),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final values = list.map((e) => e.chiTietChiTieu.soTien).toList();
    final maxValue =
        values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;
    final minValue =
        values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0.0;
    final avgValue =
        values.isNotEmpty
            ? values.reduce((a, b) => a + b) / values.length
            : 0.0;
    String? maxDate;
    String? minDate;
    if (values.isNotEmpty) {
      final maxItem = list.firstWhere(
        (e) => e.chiTietChiTieu.soTien == maxValue,
      );
      final minItem = list.firstWhere(
        (e) => e.chiTietChiTieu.soTien == minValue,
      );
      maxDate = dateFormat.format(DateTime.parse(maxItem.chiTietChiTieu.ngay));
      minDate = dateFormat.format(DateTime.parse(minItem.chiTietChiTieu.ngay));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thống kê tháng: ${widget.danhMuc.ten}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
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
                    color: Colors.orange.shade50,
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
                            child: DropdownButtonFormField<int>(
                              value: selectedMonth,
                              decoration: InputDecoration(
                                labelText: 'Tháng',
                                prefixIcon: Icon(
                                  Icons.calendar_month,
                                  color: Colors.orange,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 8,
                                ),
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
                                if (v != null) {
                                  setState(() {
                                    selectedMonth = v;
                                  });
                                  loadData();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
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
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 8,
                                ),
                              ),
                              items:
                                  List.generate(
                                        10,
                                        (i) => DateTime.now().year - 5 + i,
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
                                  setState(() {
                                    selectedYear = v;
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
                                Icons.category,
                                color: Colors.orange,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Danh mục:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.danhMuc.icon ?? '',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.danhMuc.ten,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
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
                                '${values.fold(0.0, (a, b) => a + b).toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
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
                                '${maxValue.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              if (maxDate != null) ...[
                                SizedBox(width: 8),
                                Text(
                                  '($maxDate)',
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
                                '${minValue.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              if (minDate != null) ...[
                                SizedBox(width: 8),
                                Text(
                                  '($minDate)',
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
                                Icons.bar_chart,
                                color: Colors.teal,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Trung bình:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${avgValue.toStringAsFixed(0)} đ',
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Danh sách giao dịch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.orange,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        isLoading
                            ? Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : (list.isEmpty
                                ? Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text('Không có dữ liệu'),
                                  ),
                                )
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(12),
                                  itemCount: list.length,
                                  separatorBuilder:
                                      (_, __) => SizedBox(height: 10),
                                  itemBuilder: (context, idx) {
                                    final ct = list[idx];
                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.receipt_long,
                                          color: Colors.orange,
                                        ),
                                        title: Text(
                                          '${ct.chiTietChiTieu.soTien.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          dateFormat.format(
                                            DateTime.parse(
                                              ct.chiTietChiTieu.ngay,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ThemChiTietScreen(
                                                          chiTiet:
                                                              ct.chiTietChiTieu,
                                                          danhMuc: ct.danhMuc,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
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
                                                        title: Text(
                                                          'Xác nhận xóa',
                                                        ),
                                                        content: Text(
                                                          'Bạn có chắc chắn muốn xóa giao dịch này?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: Text('Hủy'),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              'Xóa',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
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
                                                  await _dao.delete(
                                                    ct.chiTietChiTieu.id!,
                                                  );
                                                  loadData();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )),
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
