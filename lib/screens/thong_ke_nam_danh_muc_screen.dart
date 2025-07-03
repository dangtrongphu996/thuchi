import 'package:flutter/material.dart';
import '../models/danh_muc.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import 'package:intl/intl.dart';
import 'thong_ke_thang_danh_muc_screen.dart';

class ThongKeNamDanhMucScreen extends StatefulWidget {
  final DanhMuc danhMuc;
  const ThongKeNamDanhMucScreen({super.key, required this.danhMuc});

  @override
  State<ThongKeNamDanhMucScreen> createState() =>
      _ThongKeNamDanhMucScreenState();
}

class _ThongKeNamDanhMucScreenState extends State<ThongKeNamDanhMucScreen> {
  int selectedYear = DateTime.now().year;
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  Map<int, double> tongTienTheoThang = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    tongTienTheoThang.clear();
    final all = await _dao.getAll();
    final filtered =
        all.where((ct) => ct.danhMuc.id == widget.danhMuc.id).toList();
    for (var ct in filtered) {
      final date = DateTime.parse(ct.chiTietChiTieu.ngay);
      if (date.year == selectedYear) {
        tongTienTheoThang.update(
          date.month,
          (v) => v + ct.chiTietChiTieu.soTien,
          ifAbsent: () => ct.chiTietChiTieu.soTien,
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final values = tongTienTheoThang.values.toList();
    final months = tongTienTheoThang.keys.toList();
    final maxValue =
        values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;
    final minValue =
        values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0.0;
    final avgValue =
        values.isNotEmpty
            ? values.reduce((a, b) => a + b) / values.length
            : 0.0;
    int? maxMonth;
    int? minMonth;
    if (values.isNotEmpty) {
      maxMonth =
          tongTienTheoThang.entries.firstWhere((e) => e.value == maxValue).key;
      minMonth =
          tongTienTheoThang.entries.firstWhere((e) => e.value == minValue).key;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê năm: ${widget.danhMuc.ten}'),
        backgroundColor: Colors.green,
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
                    color: Colors.green.shade50,
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
                              value: selectedYear,
                              decoration: InputDecoration(
                                labelText: 'Năm',
                                prefixIcon: Icon(
                                  Icons.date_range,
                                  color: Colors.green,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.green),
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
                                color: Colors.green,
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
                                  color: Colors.green,
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
                                color: Colors.orange,
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
                                  color: Colors.green,
                                ),
                              ),
                              if (maxMonth != null) ...[
                                SizedBox(width: 8),
                                Text(
                                  '(Tháng $maxMonth)',
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
                                  color: Colors.green,
                                ),
                              ),
                              if (minMonth != null) ...[
                                SizedBox(width: 8),
                                Text(
                                  '(Tháng $minMonth)',
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
                                  color: Colors.green,
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
                      color: Colors.green,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        isLoading
                            ? Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : (tongTienTheoThang.isEmpty
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
                                  itemCount: tongTienTheoThang.length,
                                  separatorBuilder:
                                      (_, __) => SizedBox(height: 10),
                                  itemBuilder: (context, idx) {
                                    final month =
                                        tongTienTheoThang.keys.toList()..sort();
                                    final m = month[idx];
                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.calendar_month,
                                          color: Colors.green,
                                        ),
                                        title: Text(
                                          'Tháng $m',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Text(
                                          '${tongTienTheoThang[m]!.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ThongKeThangDanhMucScreen(
                                                        danhMuc: widget.danhMuc,
                                                        selectedMonth: m,
                                                        selectedYear:
                                                            selectedYear,
                                                      ),
                                            ),
                                          );
                                        },
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
