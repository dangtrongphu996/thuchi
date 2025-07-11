import 'package:flutter/material.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import '../screens/them_chi_tiet_screen.dart';

class AllTransactionsScreen extends StatefulWidget {
  final int loai; // 1: thu, 2: chi
  final String title;
  final int? danhMucId;
  const AllTransactionsScreen({
    super.key,
    required this.loai,
    required this.title,
    this.danhMucId,
  });

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  List<dynamic> _list = [];
  List<DanhMuc> _danhMucs = [];
  double tongTien = 0;
  double maxTien = 0;
  double minTien = 0;
  double avgTien = 0;
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
    tongTien = 0;
    List filtered = list.where((e) => e.danhMuc.loai == widget.loai).toList();
    if (widget.danhMucId != null) {
      filtered =
          filtered.where((e) => e.danhMuc.id == widget.danhMucId).toList();
      // Sắp xếp theo số tiền giảm dần nếu lọc theo danh mục
      filtered.sort(
        (a, b) => b.chiTietChiTieu.soTien.compareTo(a.chiTietChiTieu.soTien),
      );
    }
    for (var item in filtered) {
      tongTien += item.chiTietChiTieu.soTien;
    }
    // Thống kê lớn nhất, nhỏ nhất, trung bình
    if (filtered.isNotEmpty) {
      List<double> soTiens =
          filtered.map((e) => e.chiTietChiTieu.soTien as double).toList();
      maxTien = soTiens.reduce((a, b) => a > b ? a : b);
      minTien = soTiens.reduce((a, b) => a < b ? a : b);
      avgTien = soTiens.reduce((a, b) => a + b) / soTiens.length;
    } else {
      maxTien = 0;
      minTien = 0;
      avgTien = 0;
    }
    setState(() {
      _list = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.loai == 1 ? Colors.green : Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadData,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: const Color.fromARGB(255, 231, 255, 253),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.loai == 1
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color:
                                    widget.loai == 1
                                        ? Colors.green
                                        : Colors.redAccent,
                                size: 32,
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.loai == 1 ? 'Tổng thu' : 'Tổng chi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tongTien.toStringAsFixed(0)} đ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color:
                                          widget.loai == 1
                                              ? Colors.green
                                              : Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Lớn nhất:',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${maxTien.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.trending_down,
                                        color: Colors.purple,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Thấp nhất:',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${minTien.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.bar_chart,
                                        color: Colors.teal,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Trung bình:',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${avgTien.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
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
                    Expanded(
                      child:
                          _list.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 48,
                                      color: Colors.grey.shade300,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Không có giao dịch nào',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                itemCount: _list.length,
                                separatorBuilder:
                                    (_, __) => SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  // Nếu lọc theo danh mục thì đã sắp xếp theo số tiền giảm dần ở loadData
                                  // Ngược lại, sắp xếp theo ngày mới nhất lên đầu
                                  final sortedList =
                                      (widget.danhMucId != null)
                                          ? _list
                                          : (List.from(_list)..sort(
                                            (a, b) =>
                                                b.chiTietChiTieu.ngay.compareTo(
                                                  a.chiTietChiTieu.ngay,
                                                ),
                                          ));
                                  final item = sortedList[index];
                                  final dm = item.danhMuc;
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                widget.loai == 1
                                                    ? Colors.green
                                                    : Colors.red,
                                            radius: 28,
                                            child: Text(
                                              dm.icon ?? '',
                                              style: TextStyle(fontSize: 28),
                                            ),
                                          ),
                                          SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dm.ten,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                if ((item
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
                                                      item
                                                              .chiTietChiTieu
                                                              .ghiChu ??
                                                          '',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors.grey[400],
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      item.chiTietChiTieu.ngay,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
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
                                                '${item.chiTietChiTieu.soTien.toStringAsFixed(0)} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color:
                                                      widget.loai == 1
                                                          ? Colors.green
                                                          : Colors.redAccent,
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
                                                                    item.chiTietChiTieu,
                                                                danhMuc: dm,
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
                                                                        Colors
                                                                            .red,
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
                                                      if (confirm == true) {
                                                        await _ctDao.delete(
                                                          item
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
                  ],
                ),
              ),
    );
  }
}
