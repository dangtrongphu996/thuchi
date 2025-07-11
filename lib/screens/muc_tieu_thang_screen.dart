import 'package:flutter/material.dart';
import '../models/muc_tieu_thang.dart';
import '../db/muc_tieu_thang_dao.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';

class MucTieuThangScreen extends StatefulWidget {
  const MucTieuThangScreen({Key? key}) : super(key: key);

  @override
  State<MucTieuThangScreen> createState() => _MucTieuThangScreenState();
}

class _MucTieuThangScreenState extends State<MucTieuThangScreen> {
  final MucTieuThangDao _dao = MucTieuThangDao();
  final ChiTietChiTieuDao _giaoDichDao = ChiTietChiTieuDao();
  List<MucTieuThang> _list = [];
  Map<int, double> _daSuDungMap = {}; // key: mucTieu.id, value: đã sử dụng
  int? _selectedId;
  int _thang = DateTime.now().month;
  int _nam = DateTime.now().year;
  int _loai = 2; // 1: thu nhập, 2: chi phí
  final TextEditingController _soTienController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList() async {
    final list = await _dao.getAll();
    final Map<int, double> daSuDungMap = {};
    for (final mt in list) {
      // Lấy tổng số tiền đã sử dụng theo loại, tháng, năm
      final giaoDichList = await _giaoDichDao.getAll();
      double sum = 0;
      for (final gd in giaoDichList) {
        final ngay = DateTime.parse(gd.chiTietChiTieu.ngay);
        if (ngay.month == mt.thang &&
            ngay.year == mt.nam &&
            gd.danhMuc.loai == mt.loai) {
          sum += gd.chiTietChiTieu.soTien;
        }
      }
      daSuDungMap[mt.id ?? 0] = sum;
    }
    setState(() {
      _list = list;
      _daSuDungMap = daSuDungMap;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedId = null;
      _thang = DateTime.now().month;
      _nam = DateTime.now().year;
      _loai = 2;
      _soTienController.clear();
    });
  }

  Future<void> _save() async {
    final soTien = double.tryParse(_soTienController.text) ?? 0;
    if (soTien <= 0) return;
    final mucTieu = MucTieuThang(
      id: _selectedId,
      thang: _thang,
      nam: _nam,
      loai: _loai,
      soTien: soTien,
    );
    if (_selectedId == null) {
      await _dao.insert(mucTieu);
    } else {
      await _dao.update(mucTieu);
    }
    _clearForm();
    _fetchList();
  }

  Future<void> _delete(int id) async {
    await _dao.delete(id);
    if (_selectedId == id) _clearForm();
    _fetchList();
  }

  void _edit(MucTieuThang mucTieu) {
    setState(() {
      _selectedId = mucTieu.id;
      _thang = mucTieu.thang;
      _nam = mucTieu.nam;
      _loai = mucTieu.loai;
      _soTienController.text = mucTieu.soTien.toStringAsFixed(0);
    });
  }

  void _showFormDialog({MucTieuThang? mucTieu}) {
    int thang = mucTieu?.thang ?? DateTime.now().month;
    int nam = mucTieu?.nam ?? DateTime.now().year;
    int loai = mucTieu?.loai ?? 2;
    final TextEditingController soTienController = TextEditingController(
      text: mucTieu?.soTien != null ? mucTieu!.soTien.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              constraints: const BoxConstraints(maxWidth: 350, maxHeight: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        mucTieu?.loai == 1
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: mucTieu?.loai == 1 ? Colors.green : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        mucTieu == null ? 'Thêm mục tiêu' : 'Cập nhật mục tiêu',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 0,
                    color: Colors.teal.withOpacity(0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tháng',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    DropdownButton<int>(
                                      value: thang,
                                      isExpanded: true,
                                      items:
                                          List.generate(12, (i) => i + 1)
                                              .map(
                                                (m) => DropdownMenuItem(
                                                  value: m,
                                                  child: Text('Tháng $m'),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          (v) => v != null ? thang = v : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Năm',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    DropdownButton<int>(
                                      value: nam,
                                      isExpanded: true,
                                      items:
                                          List.generate(
                                                6,
                                                (i) =>
                                                    DateTime.now().year - 3 + i,
                                              )
                                              .map(
                                                (y) => DropdownMenuItem(
                                                  value: y,
                                                  child: Text('Năm $y'),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          (v) => v != null ? nam = v : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Loại mục tiêu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    DropdownButton<int>(
                                      value: loai,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 1,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.trending_up,
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                              SizedBox(width: 4),
                                              Text('Thu nhập'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 2,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.trending_down,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              SizedBox(width: 4),
                                              Text('Chi phí'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged:
                                          (v) => v != null ? loai = v : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số tiền mục tiêu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: soTienController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.attach_money,
                                    color: Colors.teal.shade400,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Nhập số tiền...',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final soTien =
                              double.tryParse(soTienController.text) ?? 0;
                          if (soTien <= 0) return;
                          final mucTieuMoi = MucTieuThang(
                            id: mucTieu?.id,
                            thang: thang,
                            nam: nam,
                            loai: loai,
                            soTien: soTien,
                          );
                          if (mucTieu == null) {
                            await _dao.insert(mucTieuMoi);
                          } else {
                            await _dao.update(mucTieuMoi);
                          }
                          Navigator.pop(context);
                          _fetchList();
                        },
                        icon: const Icon(Icons.save),
                        label: Text(
                          mucTieu == null ? 'Lưu' : 'Cập nhật',
                          style: const TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mục tiêu chi tiêu/tháng',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Danh sách mục tiêu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _list.isEmpty
                      ? const Center(
                        child: Text(
                          'Chưa có mục tiêu nào',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                      : ListView.separated(
                        itemCount: _list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final mt = _list[idx];
                          final isThu = mt.loai == 1;
                          final color = isThu ? Colors.green : Colors.red;
                          final icon =
                              isThu ? Icons.trending_up : Icons.trending_down;
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(icon, color: color, size: 26),
                              ),
                              title: Text(
                                isThu ? 'Thu nhập' : 'Chi phí',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 2,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            size: 16,
                                            color: Colors.teal.shade300,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tháng ${mt.thang}/${mt.nam}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.teal.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: color,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${mt.soTien.toInt()} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Builder(
                                    builder: (_) {
                                      final daDung =
                                          _daSuDungMap[mt.id ?? 0] ?? 0;
                                      final conLai = (mt.soTien - daDung).clamp(
                                        0,
                                        mt.soTien,
                                      );
                                      return Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 2,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 16,
                                                color: Colors.teal,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Đã sử dụng: ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.teal,
                                                ),
                                              ),
                                              Text(
                                                '${daDung.toInt()} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.timelapse,
                                                size: 16,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Còn lại: ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              Text(
                                                '${conLai.toInt()} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
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
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => _showFormDialog(mucTieu: mt),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _delete(mt.id!),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mục tiêu'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
