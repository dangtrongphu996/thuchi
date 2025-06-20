import 'package:flutter/material.dart';
import '../models/danh_muc.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'them_chi_tiet_screen.dart'; // Import ThemChiTietScreen

class LichSuGiaoDichDanhMucScreen extends StatefulWidget {
  final DanhMuc danhMuc;
  const LichSuGiaoDichDanhMucScreen({Key? key, required this.danhMuc})
    : super(key: key);

  @override
  _LichSuGiaoDichDanhMucScreenState createState() =>
      _LichSuGiaoDichDanhMucScreenState();
}

class _LichSuGiaoDichDanhMucScreenState
    extends State<LichSuGiaoDichDanhMucScreen> {
  final ChiTietChiTieuDao _chiTietDao =
      ChiTietChiTieuDao(); // Use private variable
  late Future<List<ChiTietChiTieuDanhMuc>>
  _transactionsFuture; // Use Future variable

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _loadTransactions(); // Load data initially
  }

  Future<List<ChiTietChiTieuDanhMuc>> _loadTransactions() async {
    final list = await _chiTietDao.getAll();
    final data = list.where((e) => e.danhMuc.id == widget.danhMuc.id).toList();
    // Sort by date descending
    data.sort(
      (a, b) => DateTime.parse(
        b.chiTietChiTieu.ngay,
      ).compareTo(DateTime.parse(a.chiTietChiTieu.ngay)),
    );
    return data;
  }

  // Function to handle deletion and refresh
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
      await _chiTietDao.delete(id);
      // Refresh the list after deletion
      setState(() {
        _transactionsFuture = _loadTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử: ${widget.danhMuc.ten}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ChiTietChiTieuDanhMuc>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          double tong = data.fold(
            0.0,
            (sum, e) => sum + e.chiTietChiTieu.soTien,
          );
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.danhMuc.icon ?? '',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.danhMuc.ten,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Tổng số tiền: ${tong.toInt()} đ',
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          widget.danhMuc.loai == 1 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 18),
                  data.isEmpty
                      ? Center(child: Text('Không có giao dịch nào'))
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        separatorBuilder:
                            (_, __) => SizedBox(
                              height: 12,
                            ), // Use SizedBox for spacing
                        itemBuilder: (context, idx) {
                          final ct = data[idx].chiTietChiTieu;
                          // Wrap ListTile in a Card
                          return Card(
                            elevation: 2,
                            margin:
                                EdgeInsets.zero, // Remove default card margin
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Icon(
                                Icons.monetization_on,
                                color: Colors.purple,
                              ),
                              title: Text(
                                '${ct.soTien.toInt()} đ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${ct.ngay}  |  ${ct.ghiChu}'),
                              trailing: Row(
                                // Add Row for buttons
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Navigate to edit screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ThemChiTietScreen(
                                                chiTiet: ct,
                                                danhMuc:
                                                    widget
                                                        .danhMuc, // Pass the danh muc object
                                              ),
                                        ),
                                      ).then((_) {
                                        // Refresh list after returning from edit screen
                                        setState(() {
                                          _transactionsFuture =
                                              _loadTransactions();
                                        });
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () {
                                      // Call delete function
                                      _deleteTransaction(ct.id!);
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
          );
        },
      ),
    );
  }
}
