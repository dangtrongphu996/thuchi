import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'them_chi_tiet_screen.dart';

class GiaoDichTheoNgayScreen extends StatefulWidget {
  const GiaoDichTheoNgayScreen({Key? key}) : super(key: key);

  @override
  State<GiaoDichTheoNgayScreen> createState() => _GiaoDichTheoNgayScreenState();
}

class _GiaoDichTheoNgayScreenState extends State<GiaoDichTheoNgayScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  List<DateTime> _days = [];
  Map<String, List<ChiTietChiTieuDanhMuc>> _dataByDay = {};
  bool _loading = true;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchDaysAndData();
  }

  Future<void> _fetchDaysAndData() async {
    final all = await _dao.getAll();
    final Set<String> dayKeys = {};
    final Map<String, List<ChiTietChiTieuDanhMuc>> grouped = {};
    for (var e in all) {
      final ngay = e.chiTietChiTieu.ngay;
      dayKeys.add(ngay);
      grouped.putIfAbsent(ngay, () => []).add(e);
    }
    final days = dayKeys.map((k) => DateTime.parse(k)).toList();
    days.sort((a, b) => a.compareTo(b));
    final nowKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _initialPage = days.indexWhere(
      (d) => DateFormat('yyyy-MM-dd').format(d) == nowKey,
    );
    if (_initialPage < 0) _initialPage = days.length - 1;
    setState(() {
      _days = days;
      _dataByDay = grouped;
      _loading = false;
    });
  }

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Color _getTypeColor(int loai) {
    return loai == 1 ? Colors.green : Colors.red;
  }

  IconData _getTypeIcon(int loai) {
    return loai == 1 ? Icons.arrow_upward : Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch theo ngày'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _days.isEmpty
              ? const Center(
                child: Text('Không có dữ liệu giao dịch theo ngày'),
              )
              : PageView.builder(
                controller: PageController(initialPage: _initialPage),
                itemCount: _days.length,
                itemBuilder: (context, page) {
                  final date = _days[page];
                  final key = _dateKey(date);
                  final data = _dataByDay[key] ?? [];
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
                          Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.purple.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.purple,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormat(
                                        'EEEE, dd/MM/yyyy',
                                        'vi',
                                      ).format(date),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildSummaryCard(
                                'Thu nhập',
                                tongThu,
                                Colors.green,
                                Icons.arrow_downward,
                              ),
                              _buildSummaryCard(
                                'Chi phí',
                                tongChi,
                                Colors.red,
                                Icons.arrow_upward,
                              ),
                              _buildSummaryCard(
                                'Còn lại',
                                conLai,
                                Colors.blue,
                                Icons.account_balance_wallet,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Danh sách Thu nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                    (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, idx) {
                                  final ct = thuNhap[idx].chiTietChiTieu;
                                  final dm = thuNhap[idx].danhMuc;
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green.shade100,
                                        child: Icon(
                                          _getTypeIcon(1),
                                          color: Colors.green,
                                        ),
                                      ),
                                      title: Text(
                                        '${ct.soTien.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      subtitle: Text(
                                        dm.ten +
                                            (ct.ghiChu.isNotEmpty
                                                ? ' - ${ct.ghiChu}'
                                                : ''),
                                      ),
                                      trailing: IconButton(
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
                                          _fetchDaysAndData();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                          const SizedBox(height: 18),
                          Text(
                            'Danh sách Chi phí',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                    (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, idx) {
                                  final ct = chiPhi[idx].chiTietChiTieu;
                                  final dm = chiPhi[idx].danhMuc;
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        child: Icon(
                                          _getTypeIcon(2),
                                          color: Colors.red,
                                        ),
                                      ),
                                      title: Text(
                                        '${ct.soTien.toInt()} đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      subtitle: Text(
                                        dm.ten +
                                            (ct.ghiChu.isNotEmpty
                                                ? ' - ${ct.ghiChu}'
                                                : ''),
                                      ),
                                      trailing: IconButton(
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
                                          _fetchDaysAndData();
                                        },
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
