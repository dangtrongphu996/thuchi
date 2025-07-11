import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'them_chi_tiet_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chi_tiet_danh_muc_screen.dart';
import 'thong_ke_nam_danh_muc_screen.dart';
import '../models/danh_muc.dart';

class GiaoDichTheoNamScreen extends StatefulWidget {
  const GiaoDichTheoNamScreen({Key? key}) : super(key: key);

  @override
  State<GiaoDichTheoNamScreen> createState() => _GiaoDichTheoNamScreenState();
}

class _GiaoDichTheoNamScreenState extends State<GiaoDichTheoNamScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  List<int> _years = [];
  Map<int, List<ChiTietChiTieuDanhMuc>> _dataByYear = {};
  bool _loading = true;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchYearsAndData();
  }

  Future<void> _fetchYearsAndData() async {
    final all = await _dao.getAll();
    final Set<int> yearSet = {};
    final Map<int, List<ChiTietChiTieuDanhMuc>> grouped = {};
    for (var e in all) {
      final year = DateTime.parse(e.chiTietChiTieu.ngay).year;
      yearSet.add(year);
      grouped.putIfAbsent(year, () => []).add(e);
    }
    final years = yearSet.toList();
    years.sort((a, b) => a.compareTo(b));
    final nowYear = DateTime.now().year;
    _initialPage = years.indexOf(nowYear);
    if (_initialPage < 0) _initialPage = years.length - 1;
    setState(() {
      _years = years;
      _dataByYear = grouped;
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
        title: const Text('Giao dịch theo năm'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _years.isEmpty
              ? const Center(child: Text('Không có dữ liệu giao dịch theo năm'))
              : PageView.builder(
                controller: PageController(initialPage: _initialPage),
                itemCount: _years.length,
                itemBuilder: (context, page) {
                  final year = _years[page];
                  final data = _dataByYear[year] ?? [];
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
                          // Header năm
                          Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.indigo.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.event_note,
                                      color: Colors.indigo,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      year.toString(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
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
                          const SizedBox(height: 10),
                          const Text(
                            'Danh mục Thu nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          _buildCategoryList(data, 1, tongThu),
                          const SizedBox(height: 8),
                          const Text(
                            'Danh mục Chi phí',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          _buildCategoryList(data, 2, tongChi),
                          const SizedBox(height: 60),
                          // // Danh sách thu nhập
                          // Text(
                          //   'Danh sách Thu nhập',
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 17,
                          //     color: Colors.green.shade700,
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          // thuNhap.isEmpty
                          //     ? _buildEmptyTransaction(
                          //       'Không có giao dịch thu nhập',
                          //       Colors.green,
                          //     )
                          //     : ListView.separated(
                          //       shrinkWrap: true,
                          //       physics: const NeverScrollableScrollPhysics(),
                          //       itemCount: thuNhap.length,
                          //       separatorBuilder:
                          //           (_, __) => const SizedBox(height: 10),
                          //       itemBuilder: (context, idx) {
                          //         final ct = thuNhap[idx].chiTietChiTieu;
                          //         final dm = thuNhap[idx].danhMuc;
                          //         return Card(
                          //           elevation: 2,
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(12),
                          //           ),
                          //           margin: const EdgeInsets.symmetric(
                          //             horizontal: 2,
                          //           ),
                          //           child: ListTile(
                          //             contentPadding:
                          //                 const EdgeInsets.symmetric(
                          //                   vertical: 8,
                          //                   horizontal: 16,
                          //                 ),
                          //             leading: CircleAvatar(
                          //               backgroundColor: Colors.green.shade100,
                          //               radius: 26,
                          //               child: Icon(
                          //                 _getTypeIcon(1),
                          //                 color: Colors.green,
                          //                 size: 28,
                          //               ),
                          //             ),
                          //             title: Text(
                          //               '${ct.soTien.toInt()} đ',
                          //               style: const TextStyle(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Colors.green,
                          //                 fontSize: 17,
                          //               ),
                          //             ),
                          //             subtitle: Text(
                          //               dm.ten +
                          //                   (ct.ghiChu.isNotEmpty
                          //                       ? ' - ${ct.ghiChu}'
                          //                       : ''),
                          //               style: const TextStyle(fontSize: 14),
                          //             ),
                          //             trailing: Row(
                          //               mainAxisSize: MainAxisSize.min,
                          //               children: [
                          //                 IconButton(
                          //                   icon: const Icon(
                          //                     Icons.edit,
                          //                     color: Colors.blue,
                          //                   ),
                          //                   onPressed: () async {
                          //                     await Navigator.push(
                          //                       context,
                          //                       MaterialPageRoute(
                          //                         builder:
                          //                             (_) => ThemChiTietScreen(
                          //                               chiTiet: ct,
                          //                               danhMuc: dm,
                          //                             ),
                          //                       ),
                          //                     );
                          //                     _fetchYearsAndData();
                          //                   },
                          //                 ),
                          //                 IconButton(
                          //                   icon: const Icon(
                          //                     Icons.delete,
                          //                     color: Colors.red,
                          //                   ),
                          //                   onPressed: () async {
                          //                     final confirm = await showDialog<
                          //                       bool
                          //                     >(
                          //                       context: context,
                          //                       builder:
                          //                           (context) => AlertDialog(
                          //                             title: const Text(
                          //                               'Xác nhận xóa',
                          //                             ),
                          //                             content: const Text(
                          //                               'Bạn có chắc chắn muốn xóa giao dịch này?',
                          //                             ),
                          //                             actions: [
                          //                               TextButton(
                          //                                 child: const Text(
                          //                                   'Hủy',
                          //                                 ),
                          //                                 onPressed:
                          //                                     () =>
                          //                                         Navigator.pop(
                          //                                           context,
                          //                                           false,
                          //                                         ),
                          //                               ),
                          //                               TextButton(
                          //                                 child: const Text(
                          //                                   'Xóa',
                          //                                   style: TextStyle(
                          //                                     color: Colors.red,
                          //                                   ),
                          //                                 ),
                          //                                 onPressed:
                          //                                     () =>
                          //                                         Navigator.pop(
                          //                                           context,
                          //                                           true,
                          //                                         ),
                          //                               ),
                          //                             ],
                          //                           ),
                          //                     );
                          //                     if (confirm == true) {
                          //                       await _dao.delete(ct.id!);
                          //                       _fetchYearsAndData();
                          //                     }
                          //                   },
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     ),
                          // const SizedBox(height: 10),
                          // // Danh sách chi phí
                          // Text(
                          //   'Danh sách Chi phí',
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 17,
                          //     color: Colors.red.shade700,
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          // chiPhi.isEmpty
                          //     ? _buildEmptyTransaction(
                          //       'Không có giao dịch chi phí',
                          //       Colors.red,
                          //     )
                          //     : ListView.separated(
                          //       shrinkWrap: true,
                          //       physics: const NeverScrollableScrollPhysics(),
                          //       itemCount: chiPhi.length,
                          //       separatorBuilder:
                          //           (_, __) => const SizedBox(height: 10),
                          //       itemBuilder: (context, idx) {
                          //         final ct = chiPhi[idx].chiTietChiTieu;
                          //         final dm = chiPhi[idx].danhMuc;
                          //         return Card(
                          //           elevation: 2,
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(12),
                          //           ),
                          //           margin: const EdgeInsets.symmetric(
                          //             horizontal: 2,
                          //           ),
                          //           child: ListTile(
                          //             contentPadding:
                          //                 const EdgeInsets.symmetric(
                          //                   vertical: 8,
                          //                   horizontal: 16,
                          //                 ),
                          //             leading: CircleAvatar(
                          //               backgroundColor: Colors.red.shade100,
                          //               radius: 26,
                          //               child: Icon(
                          //                 _getTypeIcon(2),
                          //                 color: Colors.red,
                          //                 size: 28,
                          //               ),
                          //             ),
                          //             title: Text(
                          //               '${ct.soTien.toInt()} đ',
                          //               style: const TextStyle(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Colors.red,
                          //                 fontSize: 17,
                          //               ),
                          //             ),
                          //             subtitle: Text(
                          //               dm.ten +
                          //                   (ct.ghiChu.isNotEmpty
                          //                       ? ' - ${ct.ghiChu}'
                          //                       : ''),
                          //               style: const TextStyle(fontSize: 14),
                          //             ),
                          //             trailing: Row(
                          //               mainAxisSize: MainAxisSize.min,
                          //               children: [
                          //                 IconButton(
                          //                   icon: const Icon(
                          //                     Icons.edit,
                          //                     color: Colors.blue,
                          //                   ),
                          //                   onPressed: () async {
                          //                     await Navigator.push(
                          //                       context,
                          //                       MaterialPageRoute(
                          //                         builder:
                          //                             (_) => ThemChiTietScreen(
                          //                               chiTiet: ct,
                          //                               danhMuc: dm,
                          //                             ),
                          //                       ),
                          //                     );
                          //                     _fetchYearsAndData();
                          //                   },
                          //                 ),
                          //                 IconButton(
                          //                   icon: const Icon(
                          //                     Icons.delete,
                          //                     color: Colors.red,
                          //                   ),
                          //                   onPressed: () async {
                          //                     final confirm = await showDialog<
                          //                       bool
                          //                     >(
                          //                       context: context,
                          //                       builder:
                          //                           (context) => AlertDialog(
                          //                             title: const Text(
                          //                               'Xác nhận xóa',
                          //                             ),
                          //                             content: const Text(
                          //                               'Bạn có chắc chắn muốn xóa giao dịch này?',
                          //                             ),
                          //                             actions: [
                          //                               TextButton(
                          //                                 child: const Text(
                          //                                   'Hủy',
                          //                                 ),
                          //                                 onPressed:
                          //                                     () =>
                          //                                         Navigator.pop(
                          //                                           context,
                          //                                           false,
                          //                                         ),
                          //                               ),
                          //                               TextButton(
                          //                                 child: const Text(
                          //                                   'Xóa',
                          //                                   style: TextStyle(
                          //                                     color: Colors.red,
                          //                                   ),
                          //                                 ),
                          //                                 onPressed:
                          //                                     () =>
                          //                                         Navigator.pop(
                          //                                           context,
                          //                                           true,
                          //                                         ),
                          //                               ),
                          //                             ],
                          //                           ),
                          //                     );
                          //                     if (confirm == true) {
                          //                       await _dao.delete(ct.id!);
                          //                       _fetchYearsAndData();
                          //                     }
                          //                   },
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     ),
                          // const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _years.isEmpty
              ? null
              : Builder(
                builder: (context) {
                  final pageController = PageController(
                    initialPage: _initialPage,
                  );
                  return FloatingActionButton(
                    backgroundColor: Colors.indigo,
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      // Lấy năm đang xem
                      final page =
                          (pageController.hasClients
                              ? pageController.page?.round()
                              : _initialPage) ??
                          _initialPage;
                      final year = _years[page];
                      final date = DateTime(year, 1, 1);
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
                      _fetchYearsAndData();
                    },
                    tooltip: 'Thêm giao dịch cho năm này',
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
      // year lấy từ giao dịch đầu tiên của danh mục
      final firstItem = data.firstWhere(
        (e) => e.danhMuc.id.toString() == id,
        orElse: () => data.first,
      );
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
            if (danhMucObj != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ThongKeNamDanhMucScreen(danhMuc: danhMucObj!),
                ),
              );
            }
          },
        ),
      );
    },
  );
}
