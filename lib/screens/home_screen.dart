import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart';
import 'package:thuchi/db/backup_restore_helper.dart';
import 'package:thuchi/screens/all_months_summary_screen.dart';
import 'package:thuchi/screens/bar_chart_screen.dart';
import 'package:thuchi/screens/cartoon_puzzle_game.dart';
import 'package:thuchi/screens/danhngon/danh_ngon.dart';
import 'package:thuchi/screens/docsach/entity/screen/list_book.dart';
import 'package:thuchi/screens/docsach/entity/screen/list_book_listview.dart';
import 'package:thuchi/screens/input_items_screen.dart';
import 'package:thuchi/screens/spinner_screen.dart';
import 'package:thuchi/screens/thong_ke_danh_muc_nang_cao_screen.dart';
import 'package:thuchi/screens/thong_ke_danh_muc_screen.dart';
import 'package:thuchi/screens/todo_screen.dart';
import 'danh_muc_list_screen.dart';
import 'thong_ke_screen.dart';
import 'ngan_sach_screen.dart';
import 'thong_ke_chi_tieu_tu_ngay_screen.dart';
import 'lich_thu_chi_screen.dart';
import 'thong_ke_thu_chi_screen.dart';
import 'package:thuchi/screens/docsach/entity/book.dart';
import 'package:thuchi/screens/holiday/home_holiday.dart';
import 'thong_ke_nam_pie_screen.dart';
import 'bao_cao_tong_hop_screen.dart';
import 'phan_tich_danh_muc_screen.dart';
import 'giao_dich_theo_ngay_screen.dart';
import 'giao_dich_theo_thang_screen.dart';
import 'giao_dich_theo_nam_screen.dart';
import 'muc_tieu_thang_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý Thu Chi',
          style: TextStyle(fontSize: 'Quản lý Thu Chi'.length > 20 ? 16 : 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 90,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Quản lý Thu Chi',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kiểm soát tài chính cá nhân dễ dàng, trực quan và hiện đại',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 3 : 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.08,
                  children: [
                    _buildMenuCard(
                      context,
                      'Mục tiêu tháng',
                      Icons.flag,
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MucTieuThangScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Danh mục',
                      Icons.list,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DanhMucListScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Thống kê',
                      Icons.bar_chart,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThongKeScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Ngân sách',
                      Icons.account_balance,
                      Colors.green,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NganSachScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Báo cáo',
                      Icons.pie_chart,
                      Colors.purple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BarChartScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Tổng kết tháng',
                      Icons.calendar_month,
                      Colors.red,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllMonthsSummaryScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Thống kê thu chi theo danh mục',
                      Icons.category,
                      Colors.deepOrange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThongKeDanhMucScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Trò chơi',
                      Icons.gamepad,
                      Colors.purple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PuzzleGame()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Lịch thu chi',
                      Icons.calendar_month,
                      Colors.deepPurple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LichThuChiScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Thống kê từ ngày đến ngày',
                      Icons.date_range,
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ThongKeChiTieuTuNgayScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Thống kê nâng cao',
                      Icons.bar_chart,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ThongKeDanhMucNangCaoScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Thống kê thu nhập và chi phí',
                      Icons.analytics,
                      Colors.blueGrey,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThongKeThuChiScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Đọc sách',
                      Icons.book,
                      Colors.green,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ListBookListViewScreen(books: books),
                        ),
                      ),
                    ),

                    _buildMenuCard(
                      context,
                      'Ngày lễ',
                      Icons.holiday_village,
                      Colors.red,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HolidayListScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Danh ngôn',
                      Icons.format_quote,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DanhNgonScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Biểu đồ năm',
                      Icons.pie_chart,
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThongKeNamPieScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Quay số may mắn',
                      Icons.casino,
                      Colors.purple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputItemsScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Sao lưu',
                      Icons.backup,
                      Colors.indigo,
                      () async {
                        String? errorMsg;
                        bool? success;
                        try {
                          final account =
                              await BackupRestoreHelper.signInWithGoogle();
                          if (account != null) {
                            success =
                                await BackupRestoreHelper.backupToGoogleDrive(
                                  account,
                                );
                          } else {
                            success = false;
                            errorMsg = 'Không đăng nhập được Google.';
                          }
                        } catch (e) {
                          success = false;
                          errorMsg = e.toString();
                        }
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  success == true ? 'Thành công' : 'Thất bại',
                                ),
                                content: Text(
                                  success == true
                                      ? "✅ Sao lưu thành công"
                                      : "❌ Sao lưu thất bại" +
                                          (errorMsg != null
                                              ? "\n$errorMsg"
                                              : ""),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Đóng'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      'Khôi phục',
                      Icons.restore,
                      Colors.lightBlue,
                      () async {
                        String? errorMsg;
                        bool? success;
                        try {
                          final account =
                              await BackupRestoreHelper.signInWithGoogle();
                          if (account != null) {
                            success =
                                await BackupRestoreHelper.restoreFromGoogleDrive(
                                  account,
                                );
                          } else {
                            success = false;
                            errorMsg = 'Không đăng nhập được Google.';
                          }
                        } catch (e) {
                          success = false;
                          errorMsg = e.toString();
                        }
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  success == true ? 'Thành công' : 'Thất bại',
                                ),
                                content: Text(
                                  success == true
                                      ? "✅ Khôi phục thành công"
                                      : "❌ Khôi phục thất bại" +
                                          (errorMsg != null
                                              ? "\n$errorMsg"
                                              : ""),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Đóng'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      'Báo cáo tổng hợp',
                      Icons.analytics,
                      Colors.deepPurple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BaoCaoTongHopScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      'Phân tích danh mục',
                      Icons.analytics,
                      Colors.tealAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhanTichDanhMucScreenNew(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      'Công việc hằng ngày',
                      Icons.checklist,
                      Colors.deepPurple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TodoScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Giao dịch theo ngày',
                      Icons.today,
                      Colors.purple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GiaoDichTheoNgayScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Giao dịch theo tháng',
                      Icons.calendar_view_month,
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GiaoDichTheoThangScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Giao dịch theo năm',
                      Icons.event_note,
                      Colors.indigo,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GiaoDichTheoNamScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  '© 2024 Quản lý Thu Chi - Made with Flutter',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.18),
        highlightColor: color.withOpacity(0.10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.13),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: Colors.white),
              const SizedBox(height: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: title.length > 15 ? 14 : 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
