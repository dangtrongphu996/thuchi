import 'package:flutter/material.dart';
import 'package:thuchi/screens/them_chi_tiet_screen.dart';
import 'package:thuchi/screens/chi_tiet_theo_thang.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import 'them_danh_muc_screen.dart';
import 'them_ngan_sach_screen.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import '../screens/lich_su_giao_dich_danh_muc_screen.dart';
import 'package:thuchi/screens/thong_ke_nam_danh_muc_screen.dart';
import 'package:thuchi/screens/thong_ke_thang_danh_muc_screen.dart';
import 'phan_tich_danh_muc_screen.dart';

class DanhMucListScreen extends StatefulWidget {
  const DanhMucListScreen({super.key});

  @override
  State<DanhMucListScreen> createState() => _DanhMucListScreenState();
}

class _DanhMucListScreenState extends State<DanhMucListScreen> {
  final DanhMucDao _dao = DanhMucDao();
  final ChiTietChiTieuDao _chiTietDao = ChiTietChiTieuDao();
  List<DanhMuc> danhMucs = [];
  List<DanhMuc> filteredDanhMucs = [];
  TextEditingController _searchController = TextEditingController();
  Map<int, double> tongSoTienMap = {};
  bool isLoading = false;

  Future<void> loadDanhMucs() async {
    setState(() {
      isLoading = true;
    });
    final list = await _dao.getAllDanhMuc();
    danhMucs = list;
    filteredDanhMucs = list;
    await loadTongSoTien();
    // Sắp xếp mặc định khi load
    filteredDanhMucs.sort((a, b) {
      if (a.loai != b.loai) {
        return a.loai.compareTo(b.loai);
      }
      final tongA = tongSoTienMap[a.id!] ?? 0;
      final tongB = tongSoTienMap[b.id!] ?? 0;
      return tongB.compareTo(tongA);
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadTongSoTien() async {
    tongSoTienMap.clear();
    final now = DateTime.now();
    for (var dm in danhMucs) {
      double tong = await _chiTietDao.getTongTienTheoDanhMuc(dm.id!);
      tongSoTienMap[dm.id!] = tong;
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredDanhMucs =
          danhMucs.where((dm) => dm.ten.toLowerCase().contains(query)).toList();
      // Sắp xếp: thu nhập trước, chi phí sau, trong mỗi nhóm giảm dần theo tổng số tiền
      filteredDanhMucs.sort((a, b) {
        if (a.loai != b.loai) {
          return a.loai.compareTo(b.loai); // loai==1 (thu nhập) lên trước
        }
        final tongA = tongSoTienMap[a.id!] ?? 0;
        final tongB = tongSoTienMap[b.id!] ?? 0;
        return tongB.compareTo(tongA); // giảm dần theo số tiền
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    loadDanhMucs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh mục',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 'Danh mục'.length > 20 ? 16 : 20,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  loadDanhMucs();
                  break;
                case 'settings':
                  // TODO: Implement settings
                  break;
                case 'add':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ThemChiTietScreen()),
                  ).then((_) => loadDanhMucs());
                  break;
                case 'chi_tiet':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChiTietTheoThangScreen(
                            selectedMonth: DateTime.now().month,
                            selectedYear: DateTime.now().year,
                          ),
                    ),
                  ).then((_) => loadDanhMucs());
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Làm mới'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Cài đặt'),
                      ],
                    ),
                  ),

                  PopupMenuItem<String>(
                    value: 'chi_tiet',
                    child: Row(
                      children: [
                        Icon(Icons.list, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Chi tiết theo tháng'),
                      ],
                    ),
                  ),
                ],
          ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm danh mục...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredDanhMucs.length,
                        itemBuilder: (context, index) {
                          final dm = filteredDanhMucs[index];
                          final tongSoTien = tongSoTienMap[dm.id!] ?? 0;
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  dm.icon ?? '',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              title: Text(
                                dm.ten,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Tổng tiền: ${tongSoTien.toInt()} đ',
                                style: TextStyle(
                                  color:
                                      dm.loai == 1 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Bạn muốn làm gì?',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 24),
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.add),
                                                label: Text('Thêm thu chi'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade700,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              ThemChiTietScreen(
                                                                danhMuc: dm,
                                                              ),
                                                    ),
                                                  ).then((_) => loadDanhMucs());
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.history),
                                                label: Text(
                                                  'Lịch sử giao dịch',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  _navigateToLichSuGiaoDich(dm);
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.bar_chart),
                                                label: Text('Thống kê năm'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              ThongKeNamDanhMucScreen(
                                                                danhMuc: dm,
                                                              ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: Icon(
                                                  Icons.calendar_month,
                                                ),
                                                label: Text('Thống kê tháng'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.lightBlueAccent,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              ThongKeThangDanhMucScreen(
                                                                danhMuc: dm,
                                                              ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: Icon(
                                                  Icons.account_balance_wallet,
                                                ),
                                                label: Text('Thêm Ngân Sách'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              ThemNganSachScreen(
                                                                danhMuc: dm,
                                                              ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 16),
                                              TextButton(
                                                child: Text(
                                                  'Đóng',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                );
                              },
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ThemDanhMucScreen(
                                                loai: dm.loai,
                                                danhMuc: dm,
                                              ),
                                        ),
                                      ).then((_) => loadDanhMucs());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text('Xác nhận xóa'),
                                              content: Text(
                                                'Bạn có chắc chắn muốn xóa danh mục này?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('Hủy'),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    'Xóa',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
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
                                        await _dao.deleteDanhMuc(dm.id!);
                                        loadDanhMucs();
                                      }
                                    },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chọn loại danh mục',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildOptionCard(
                                title: 'Thu nhập',
                                icon: Icons.arrow_downward,
                                color: Colors.green,
                                onTap: () => _navigateToAddScreen(1),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildOptionCard(
                                title: 'Chi phí',
                                icon: Icons.arrow_upward,
                                color: Colors.red,
                                onTap: () => _navigateToAddScreen(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          );
        },
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navigateToAddScreen(int loai) {
    Navigator.pop(context); // Close dialog first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThemDanhMucScreen(loai: loai)),
    ).then((_) => loadDanhMucs());
  }

  void _navigateToLichSuGiaoDich(DanhMuc dm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LichSuGiaoDichDanhMucScreen(danhMuc: dm),
      ),
    );
  }
}
