import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/ngan_sach_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';
import '../models/ngan_sach.dart';
import 'home_screen.dart';
import 'them_chi_tiet_screen.dart';
import 'all_months_summary_screen.dart';
import 'income_categories_screen.dart';
import 'expense_categories_screen.dart';
import 'them_danh_muc_screen.dart';
import '../db/backup_restore_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'danh_muc_list_screen.dart';
import 'chi_tiet_theo_thang.dart';
import 'package:thuchi/screens/vocabulary/screen/vocabulary_menu_screen.dart';
// import 'muc_tieu_thang_screen.dart';
import 'phan_tich_tong_hop_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final NganSachDao _nganSachDao = NganSachDao();
  final DanhMucDao _danhMucDao = DanhMucDao();

  double tongThu = 0;
  double tongChi = 0;
  double soDu = 0;
  List<NganSach> nganSachList = [];
  Map<int, double> daChiMap = {};
  List<Map<String, dynamic>> pieData = [];
  bool isLoading = true;
  List<String> canhBao = [];
  List<dynamic> chi7NgayGanNhat = [];
  List<DanhMuc> _danhMucs = [];

  double _tongThu7Days = 0;
  double _tongChi7Days = 0;
  double _soDu7Days = 0;

  int thang = DateTime.now().month;
  int nam = DateTime.now().year;

  double thuThang = 0;
  double chiThang = 0;

  double thuThangTruoc = 0;
  double chiThangTruoc = 0;

  double percentTietKiem = 0;

  String? _userName;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    loadData();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName =
          prefs.getString('profile_name')?.trim().isNotEmpty == true
              ? prefs.getString('profile_name')
              : 'Người dùng';
      _avatarPath = prefs.getString('profile_avatar');
    });
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final list = await _ctDao.getAll();
    final danhMucs = await _danhMucDao.getAllDanhMuc();
    _danhMucs = danhMucs;
    nganSachList = await _nganSachDao.getByMonth(thang, nam);
    tongThu = 0;
    tongChi = 0;
    daChiMap = {};
    pieData = [];
    canhBao = [];
    // Lọc giao dịch 7 ngày gần nhất (cả thu và chi)
    final now = DateTime.now();
    chi7NgayGanNhat =
        list.where((item) {
          final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay) ?? now;
          return ngay.isAfter(now.subtract(Duration(days: 7))) &&
              !ngay.isAfter(now);
        }).toList();
    // Calculate total income, expense, and balance for the last 7 days
    _tongThu7Days = 0;
    _tongChi7Days = 0;
    _soDu7Days = 0;
    for (var item in chi7NgayGanNhat) {
      final dm = danhMucs.firstWhere(
        (e) => e.id == item.chiTietChiTieu.danhMucId,
        orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
      );
      if (dm.loai == 1) {
        _tongThu7Days += item.chiTietChiTieu.soTien;
      } else {
        _tongChi7Days += item.chiTietChiTieu.soTien;
      }
    }
    _soDu7Days = _tongThu7Days - _tongChi7Days;
    // Tính thu nhập và chi phí tháng hiện tại cho pie chart nhỏ
    thuThang = 0;
    chiThang = 0;
    // Tính thu nhập và chi phí tháng trước
    final thangTruoc = thang == 1 ? 12 : thang - 1;
    final namTruoc = thang == 1 ? nam - 1 : nam;
    thuThangTruoc = 0;
    chiThangTruoc = 0;
    for (var item in list) {
      final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay) ?? now;
      final dm = danhMucs.firstWhere(
        (e) => e.id == item.chiTietChiTieu.danhMucId,
        orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
      );
      if (ngay.month == thang && ngay.year == nam) {
        if (dm.loai == 1) {
          thuThang += item.chiTietChiTieu.soTien;
        } else {
          chiThang += item.chiTietChiTieu.soTien;
        }
      }
      if (ngay.month == thangTruoc && ngay.year == namTruoc) {
        if (dm.loai == 1) {
          thuThangTruoc += item.chiTietChiTieu.soTien;
        } else {
          chiThangTruoc += item.chiTietChiTieu.soTien;
        }
      }
    }
    // Tính phần trăm tiết kiệm
    if (chiThangTruoc > 0) {
      percentTietKiem = ((thuThangTruoc - chiThangTruoc) / thuThangTruoc) * 100;
    } else {
      percentTietKiem = 0;
    }
    chi7NgayGanNhat.sort((a, b) {
      final ngayA = DateTime.tryParse(a.chiTietChiTieu.ngay) ?? DateTime(2000);
      final ngayB = DateTime.tryParse(b.chiTietChiTieu.ngay) ?? DateTime(2000);
      return ngayB.compareTo(ngayA);
    });
    for (var item in list) {
      final dm = danhMucs.firstWhere(
        (e) => e.id == item.chiTietChiTieu.danhMucId,
        orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
      );
      if (dm.loai == 1) {
        tongThu += item.chiTietChiTieu.soTien;
      } else {
        tongChi += item.chiTietChiTieu.soTien;
        daChiMap[dm.id!] = (daChiMap[dm.id!] ?? 0) + item.chiTietChiTieu.soTien;
      }
    }
    soDu = tongThu - tongChi;
    // Pie chart data
    if (tongThu > 0)
      pieData.add({'label': 'Thu', 'value': tongThu, 'color': Colors.green});
    if (tongChi > 0)
      pieData.add({
        'label': 'Chi',
        'value': tongChi,
        'color': Colors.redAccent,
      });
    // Cảnh báo vượt ngân sách
    for (var ns in nganSachList) {
      final daChi = daChiMap[ns.danhMucId] ?? 0;
      if (ns.soTien > 0 && daChi > ns.soTien) {
        final dm = danhMucs.firstWhere(
          (e) => e.id == ns.danhMucId,
          orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
        );
        canhBao.add('⚠️ Danh mục "${dm.ten}" đã vượt ngân sách!');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepOrange),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Menu',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.deepOrange),
              title: Text('Tổng quan', style: GoogleFonts.montserrat()),
              selected: true,
              onTap: () {
                Navigator.pop(context); // Đã ở màn này, chỉ đóng Drawer
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category, color: Colors.orange),
              title: Text('Các chức năng', style: GoogleFonts.montserrat()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics, color: Colors.teal),
              title: Text(
                'Phân tích tổng hợp',
                style: GoogleFonts.montserrat(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PhanTichTongHopScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.school, color: Colors.indigo),
              title: Text('Từ vựng', style: GoogleFonts.montserrat()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VocabularyMenuScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.backup, color: Colors.blue),
              title: Text('Sao lưu dữ liệu', style: GoogleFonts.montserrat()),
              onTap: () async {
                Navigator.pop(context);
                final account = await BackupRestoreHelper.signInWithGoogle();
                if (account == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đăng nhập Google thất bại!\n${BackupRestoreHelper.lastError ?? ''}'
                            .trim(),
                      ),
                    ),
                  );
                  return;
                }
                final ok = await BackupRestoreHelper.backupToGoogleDrive(
                  account,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Sao lưu thành công!'
                          : 'Sao lưu thất bại!\n${BackupRestoreHelper.lastError ?? ''}'
                              .trim(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.restore, color: Colors.teal),
              title: Text('Khôi phục dữ liệu', style: GoogleFonts.montserrat()),
              onTap: () async {
                Navigator.pop(context);
                final account = await BackupRestoreHelper.signInWithGoogle();
                if (account == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đăng nhập Google thất bại!\n${BackupRestoreHelper.lastError ?? ''}'
                            .trim(),
                      ),
                    ),
                  );
                  return;
                }
                final ok = await BackupRestoreHelper.restoreFromGoogleDrive(
                  account,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Khôi phục thành công! Vui lòng khởi động lại ứng dụng.'
                          : 'Khôi phục thất bại!\n${BackupRestoreHelper.lastError ?? ''}'
                              .trim(),
                    ),
                  ),
                );
                if (ok) {
                  // Optionally reload data or force restart
                  // loadData();
                }
              },
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadData,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // HEADER GRADIENT + AVATAR + SỐ DƯ
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF7043)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 36),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(
                                builder:
                                    (context) => IconButton(
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                      ),
                                      onPressed:
                                          () =>
                                              Scaffold.of(context).openDrawer(),
                                    ),
                              ),
                              Text(
                                'Tổng quan',
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Builder(
                                builder:
                                    (context) => IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                                      onPressed: isLoading ? null : loadData,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                              if (updated == true) _loadProfile();
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _avatarPath != null
                                      ? FileImage(File(_avatarPath!))
                                      : null,
                              child:
                                  _avatarPath == null
                                      ? Icon(
                                        Icons.account_circle,
                                        size: 54,
                                        color: Colors.deepOrange,
                                      )
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _userName ?? 'Người dùng',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 18,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Số dư hiện tại',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[900],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${soDu.toStringAsFixed(0)} đ',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    color:
                                        soDu >= 0
                                            ? Colors.green[800]
                                            : Colors.red[700],
                                    shadows: [
                                      Shadow(
                                        blurRadius: 12,
                                        color:
                                            soDu >= 0
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // TabBar hiện đại
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 18,
                    //     vertical: 8,
                    //   ),
                    //   child: Container(
                    //     height: 64,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(18),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.orangeAccent.withOpacity(0.08),
                    //           blurRadius: 8,
                    //           offset: const Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //     child: DefaultTabController(
                    //       length: 4,
                    //       child: TabBar(
                    //         labelColor: Colors.deepOrange,
                    //         unselectedLabelColor: Colors.grey,
                    //         indicator: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(12),
                    //           color: Colors.orange.shade50,
                    //         ),
                    //         labelStyle: GoogleFonts.montserrat(
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 10,
                    //         ),
                    //         tabs: const [
                    //           Tab(
                    //             text: 'Tổng quan',
                    //             icon: Icon(Icons.dashboard),
                    //           ),
                    //           Tab(
                    //             text: 'Thu nhập',
                    //             icon: Icon(Icons.arrow_downward),
                    //           ),
                    //           Tab(
                    //             text: 'Chi phí',
                    //             icon: Icon(Icons.arrow_upward),
                    //           ),
                    //           Tab(
                    //             text: 'Ngân sách',
                    //             icon: Icon(Icons.account_balance),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // ),
                    const SizedBox(height: 18),
                    // Tổng thu/chi hiện đại
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // Lấy danh sách danh mục thu nhập và tổng tiền từng danh mục
                                final thuDanhMucs =
                                    _danhMucs
                                        .where((dm) => dm.loai == 1)
                                        .toList();
                                final Map<int, double> tongThuTheoDanhMuc = {};
                                for (var dm in thuDanhMucs) {
                                  tongThuTheoDanhMuc[dm.id!] = 0;
                                }
                                final list = await _ctDao.getAll();
                                for (var item in list) {
                                  final dmId = item.chiTietChiTieu.danhMucId;
                                  final dm = thuDanhMucs.firstWhere(
                                    (e) => e.id == dmId,
                                    orElse:
                                        () => DanhMuc(
                                          id: 0,
                                          ten: '',
                                          icon: '',
                                          loai: 2,
                                        ),
                                  );
                                  if (dm.loai == 1) {
                                    tongThuTheoDanhMuc[dmId] =
                                        (tongThuTheoDanhMuc[dmId] ?? 0) +
                                        item.chiTietChiTieu.soTien;
                                  }
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => IncomeCategoriesScreen(
                                          danhMucs: thuDanhMucs,
                                          tongThuTheoDanhMuc:
                                              tongThuTheoDanhMuc,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF43E97B),
                                      Color(0xFF38F9D7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(
                                        0.15,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 22,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Icon(
                                        Icons.arrow_downward,
                                        color: Colors.green,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tổng thu',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tongThu.toStringAsFixed(0)} đ',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // Lấy danh sách danh mục chi phí và tổng chi từng danh mục
                                final chiDanhMucs =
                                    _danhMucs
                                        .where((dm) => dm.loai == 2)
                                        .toList();
                                final Map<int, double> tongChiTheoDanhMuc = {};
                                for (var dm in chiDanhMucs) {
                                  tongChiTheoDanhMuc[dm.id!] = 0;
                                }
                                final list = await _ctDao.getAll();
                                for (var item in list) {
                                  final dmId = item.chiTietChiTieu.danhMucId;
                                  final dm = chiDanhMucs.firstWhere(
                                    (e) => e.id == dmId,
                                    orElse:
                                        () => DanhMuc(
                                          id: 0,
                                          ten: '',
                                          icon: '',
                                          loai: 1,
                                        ),
                                  );
                                  if (dm.loai == 2) {
                                    tongChiTheoDanhMuc[dmId] =
                                        (tongChiTheoDanhMuc[dmId] ?? 0) +
                                        item.chiTietChiTieu.soTien;
                                  }
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ExpenseCategoriesScreen(
                                          danhMucs: chiDanhMucs,
                                          tongChiTheoDanhMuc:
                                              tongChiTheoDanhMuc,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF5858),
                                      Color(0xFFFFAE53),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 22,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Icon(
                                        Icons.arrow_upward,
                                        color: Colors.redAccent,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tổng chi',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.red[900],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tongChi.toStringAsFixed(0)} đ',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.red[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Pie chart thu/chi hiện đại
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.orangeAccent.withOpacity(0.15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 8,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Tỷ lệ thu/chi',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 180,
                                child:
                                    pieData.isEmpty
                                        ? const Center(
                                          child: Text('Không có dữ liệu'),
                                        )
                                        : PieChart(
                                          PieChartData(
                                            sections:
                                                pieData
                                                    .map(
                                                      (
                                                        e,
                                                      ) => PieChartSectionData(
                                                        color: e['color'],
                                                        value: e['value'],
                                                        title:
                                                            '${((e['value'] / (tongThu + tongChi)) * 100).toStringAsFixed(0)}%',
                                                        titleStyle:
                                                            GoogleFonts.montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                            ),
                                                        radius: 60,
                                                      ),
                                                    )
                                                    .toList(),
                                            sectionsSpace: 2,
                                            centerSpaceRadius: 32,
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    pieData
                                        .map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 14,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color: e['color'],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  e['label'],
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Widget Tips/Goals
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Card(
                        color: Colors.lightBlue.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                thuThangTruoc >= chiThangTruoc * 1.6
                                    ? Icons.emoji_events
                                    : Icons.info_outline,
                                color:
                                    thuThangTruoc >= chiThangTruoc * 1.6
                                        ? Colors.green
                                        : Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mẹo tiết kiệm',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      percentTietKiem >= 60
                                          ? 'Bạn đã hoàn thành kế hoạch tiết kiệm tháng trước! 🎉'
                                          : 'Bạn chưa hoàn thành kế hoạch tiết kiệm tháng trước \nHãy cố gắng tiết kiệm nhiều hơn!',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color:
                                            percentTietKiem >= 60
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Thu nhập tháng trước: '
                                      '${thuThangTruoc.toStringAsFixed(0)} đ',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      'Chi phí tháng trước: '
                                      '${chiThangTruoc.toStringAsFixed(0)} đ',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chiThangTruoc > 0
                                          ? 'Bạn đã tiết kiệm được ${percentTietKiem.toStringAsFixed(1)}% so với chi phí tháng trước.'
                                          : 'Không có chi phí tháng trước để tính phần trăm tiết kiệm.',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // CardView tổng hợp tháng hiện tại
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMonthsSummaryScreen(),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.orange.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Row(
                            children: [
                              // Bên trái
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tháng $thang - $nam',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: thuThang,
                                              title:
                                                  thuThang + chiThang > 0 &&
                                                          thuThang > 0
                                                      ? '${((thuThang / (thuThang + chiThang)) * 100).toStringAsFixed(0)}%'
                                                      : '',
                                              titleStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              radius: 18,
                                            ),
                                            PieChartSectionData(
                                              color: Colors.redAccent,
                                              value: chiThang,
                                              title:
                                                  thuThang + chiThang > 0 &&
                                                          chiThang > 0
                                                      ? '${((chiThang / (thuThang + chiThang)) * 100).toStringAsFixed(0)}%'
                                                      : '',
                                              titleStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              radius: 18,
                                            ),
                                          ],
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Bên phải
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Thu nhập:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${thuThang.toStringAsFixed(0)} đ',
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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Chi phí:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${chiThang.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          color:
                                              (thuThang - chiThang) >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Tổng cộng:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${(thuThang - chiThang).toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (thuThang - chiThang) >= 0
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Cảnh báo vượt ngân sách
                    if (canhBao.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Card(
                            color: Colors.red.shade50,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cảnh báo ngân sách',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...canhBao.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Text(
                                              e,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.red[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    // Danh sách chi tiêu 7 ngày gần nhất
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, color: Colors.deepOrange),
                                SizedBox(width: 8),
                                Text(
                                  'Chi tiêu 7 ngày gần nhất',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Summary for last 7 days
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng thu:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${_tongThu7Days.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng chi:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${_tongChi7Days.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Còn lại:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${_soDu7Days.toStringAsFixed(0)} đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _soDu7Days >= 0
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            chi7NgayGanNhat.isEmpty
                                ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Không có giao dịch chi tiêu nào trong 7 ngày qua',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: chi7NgayGanNhat.length,
                                  separatorBuilder:
                                      (_, __) => SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = chi7NgayGanNhat[index];
                                    final dm = _danhMucs.firstWhere(
                                      (e) =>
                                          e.id == item.chiTietChiTieu.danhMucId,
                                      orElse:
                                          () => DanhMuc(
                                            id: 0,
                                            ten: '',
                                            icon: '',
                                            loai: 2,
                                          ),
                                    );
                                    final isThu = dm.loai == 1;
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
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                              radius: 20,
                                              child: Text(
                                                dm.icon ?? '',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    dm.ten,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        size: 12,
                                                        color: Colors.grey[400],
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        item
                                                            .chiTietChiTieu
                                                            .ngay,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
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
                                                        ? Colors.green
                                                        : Colors.redAccent,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 20,
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
                                                size: 20,
                                              ),
                                              tooltip: 'Xóa',
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
                                                          'Bạn có chắc muốn xóa giao dịch này?',
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
                                                          ElevatedButton(
                                                            child: Text('Xóa'),
                                                            style:
                                                                ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
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
                                                  await _ctDao.delete(
                                                    item.chiTietChiTieu.id!,
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
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            int? loai;
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Chọn loại giao dịch'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.arrow_upward,
                            color: Colors.redAccent,
                          ),
                          title: Text('Chi phí'),
                          onTap: () {
                            loai = 2;
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.arrow_downward,
                            color: Colors.green,
                          ),
                          title: Text('Thu nhập'),
                          onTap: () {
                            loai = 1;
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
            );
            if (loai != null) {
              // Lấy danh mục tương ứng
              final danhMucs = await _danhMucDao.getDanhMucByLoai(loai!);
              DanhMuc? selected;
              await showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Chọn danh mục'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: danhMucs.length + 1,
                          itemBuilder: (context, idx) {
                            if (idx < danhMucs.length) {
                              final dm = danhMucs[idx];
                              return ListTile(
                                leading: Text(
                                  dm.icon ?? '',
                                  style: TextStyle(fontSize: 24),
                                ),
                                title: Text(dm.ten),
                                onTap: () {
                                  selected = dm;
                                  Navigator.pop(context);
                                },
                              );
                            } else {
                              return ListTile(
                                leading: Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.blue,
                                ),
                                title: Text('Thêm danh mục mới'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ThemDanhMucScreen(loai: loai!),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
              );
              if (selected != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ThemChiTietScreen(danhMuc: selected!),
                  ),
                ).then((_) => loadData());
              } else {
                loadData();
              }
            }
          },
          icon: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
          label: Text(
            '',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green[800],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 28),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category, size: 28),
              label: 'Danh mục',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, size: 28),
              label: 'Báo cáo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 28),
              label: 'Cài đặt',
            ),
          ],
          currentIndex: 0,
          onTap: (i) {
            if (i == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DanhMucListScreen()),
              );
            } else if (i == 2) {
              final now = DateTime.now();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ChiTietTheoThangScreen(
                        selectedMonth: now.month,
                        selectedYear: now.year,
                        type: null,
                      ),
                ),
              );
            }
            // TODO: Thêm các màn hình khác nếu muốn
          },
        ),
      ),
    );
  }
}
