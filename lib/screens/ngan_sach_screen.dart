import 'package:flutter/material.dart';
import '../db/ngan_sach_dao.dart';
import '../db/danh_muc_dao.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/ngan_sach.dart';
import '../models/danh_muc.dart';
import 'them_ngan_sach_screen.dart';

enum SortType { soTien, tenDanhMuc, trangThai }

class NganSachScreen extends StatefulWidget {
  const NganSachScreen({super.key});

  @override
  State<NganSachScreen> createState() => _NganSachScreenState();
}

class _NganSachScreenState extends State<NganSachScreen> {
  final NganSachDao _dao = NganSachDao();
  final DanhMucDao _danhMucDao = DanhMucDao();
  final ChiTietChiTieuDao _chiTieuDao = ChiTietChiTieuDao();

  List<NganSach> nganSachs = [];
  Map<int, DanhMuc> danhMucMap = {};
  Map<int, double> daChiMap = {}; // Lưu tổng chi tiêu từng danh mục

  int thang = DateTime.now().month;
  int nam = DateTime.now().year;

  SortType sortType = SortType.trangThai;
  bool isLoading = true;

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    nganSachs = await _dao.getByMonth(thang, nam);
    final danhMucs =
        await _danhMucDao.getAllDanhMucChiPhi(); // Chỉ lấy danh mục chi phí
    danhMucMap = {for (var dm in danhMucs) dm.id!: dm};
    // Lấy tổng chi tiêu từng danh mục
    daChiMap = {};
    for (var ns in nganSachs) {
      daChiMap[ns.danhMucId] = await _chiTieuDao.getTongChiTieuTheoDanhMuc(
        ns.danhMucId,
        thang,
        nam,
      );
    }
    _sortNganSachs();
    setState(() {
      isLoading = false;
    });
  }

  void _sortNganSachs() {
    switch (sortType) {
      case SortType.soTien:
        nganSachs.sort((a, b) => b.soTien.compareTo(a.soTien));
        break;
      case SortType.tenDanhMuc:
        nganSachs.sort(
          (a, b) => (danhMucMap[a.danhMucId]?.ten ?? '').compareTo(
            danhMucMap[b.danhMucId]?.ten ?? '',
          ),
        );
        break;
      case SortType.trangThai:
        nganSachs.sort((a, b) {
          final percentA =
              a.soTien > 0 ? (daChiMap[a.danhMucId] ?? 0) / a.soTien : 0.0;
          final percentB =
              b.soTien > 0 ? (daChiMap[b.danhMucId] ?? 0) / b.soTien : 0.0;
          return percentB.compareTo(percentA);
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    double tongNganSach = nganSachs.fold(0, (sum, ns) => sum + ns.soTien);
    // Danh sách tháng và năm
    final months = List.generate(12, (i) => i + 1);
    final now = DateTime.now();
    final years = List.generate(
      6,
      (i) => now.year - 3 + i,
    ); // 3 năm trước đến 2 năm sau
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ngân sách chi phí tháng $thang/$nam",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize:
                ("Ngân sách chi phí tháng $thang/$nam").length > 20 ? 16 : 22,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dropdown chọn tháng/năm (đẹp hơn)
              Card(
                color: Colors.green.shade50,
                elevation: 0,
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
                      // Dropdown tháng
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          value: thang,
                          decoration: InputDecoration(
                            labelText: 'Tháng',
                            prefixIcon: Icon(
                              Icons.calendar_month,
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
                              months
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text('Tháng $m'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                thang = value;
                              });
                              loadData();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      // Dropdown năm
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          value: nam,
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
                              years
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('Năm $y'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                nam = value;
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
              SizedBox(height: 10),
              // Card sắp xếp
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 10, right: 0),
                child: Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: DropdownButtonFormField<SortType>(
                            value:
                                SortType.values.contains(sortType)
                                    ? sortType
                                    : SortType.trangThai,
                            decoration: InputDecoration(
                              labelText: 'Sắp xếp theo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: SortType.trangThai,
                                child: Text('Trạng thái sử dụng'),
                              ),
                              DropdownMenuItem(
                                value: SortType.soTien,
                                child: Text('Số tiền'),
                              ),
                              DropdownMenuItem(
                                value: SortType.tenDanhMuc,
                                child: Text('Tên danh mục'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  sortType = value;
                                  _sortNganSachs();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: Colors.green.shade100,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Tổng ngân sách:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${tongNganSach.toStringAsFixed(0)} đ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),
              // Hiển thị loading hoặc danh sách
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Thêm ngân sách',
        onPressed: () async {
          final danhMucs = danhMucMap.values.toList();
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
                      itemCount: danhMucs.length,
                      itemBuilder: (context, idx) {
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
                      },
                    ),
                  ),
                ),
          );
          if (selected != null) {
            // Kiểm tra ngân sách đã tồn tại chưa
            final existed = await _dao.getByDanhMucAndMonth(
              selected!.id!,
              thang,
              nam,
            );
            if (existed != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Ngân sách đã tồn tại')));
              return;
            }
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ThemNganSachScreen(danhMuc: selected!),
              ),
            );
            loadData();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (nganSachs.isEmpty) {
      return Center(
        child: Text(
          'Chưa có ngân sách nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      return ListView.separated(
        itemCount: nganSachs.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ns = nganSachs[index];
          final dm = danhMucMap[ns.danhMucId];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                radius: 26,
                child: Text(dm?.icon ?? '💰', style: TextStyle(fontSize: 28)),
              ),
              title: Text(
                dm?.ten ?? "",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.green.shade400,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tháng $thang/$nam',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Giới hạn:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${ns.soTien.toStringAsFixed(0)} đ',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Builder(
                    builder: (_) {
                      final daChi = daChiMap[ns.danhMucId] ?? 0;
                      final percent =
                          ns.soTien > 0 ? (daChi / ns.soTien).clamp(0, 1) : 0.0;
                      final percentText =
                          ns.soTien > 0
                              ? ((daChi / ns.soTien) * 100)
                                  .clamp(0, 100)
                                  .toStringAsFixed(0)
                              : '0';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: percent.toDouble(),
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation(
                              percent < 0.5
                                  ? Colors.green
                                  : (percent < 0.8
                                      ? Colors.green.shade500
                                      : Colors.red),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Đã chi: ${daChi.toStringAsFixed(0)} đ (${percentText}%)',
                            style: TextStyle(
                              color: percent < 1 ? Colors.black87 : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Chỉnh sửa',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ThemNganSachScreen(
                                danhMuc: dm!,
                                nganSach: ns,
                              ),
                        ),
                      );
                      loadData();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Xóa',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('Xác nhận xóa'),
                              content: Text(
                                'Bạn có chắc muốn xóa ngân sách này?',
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Hủy'),
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                ),
                                ElevatedButton(
                                  child: Text('Xóa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await _dao.delete(ns.id!);
                        loadData();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
