import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/danh_muc.dart';
import '../screens/them_chi_tiet_screen.dart';

class ThongKeChiTieuTuNgayScreen extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  const ThongKeChiTieuTuNgayScreen({super.key, this.fromDate, this.toDate});

  @override
  State<ThongKeChiTieuTuNgayScreen> createState() =>
      _ThongKeChiTieuTuNgayScreenState();
}

class _ThongKeChiTieuTuNgayScreenState
    extends State<ThongKeChiTieuTuNgayScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  DateTime? fromDate;
  DateTime? toDate;
  List<ChiTietChiTieu> giaoDichList = [];
  List<DanhMuc> danhMucs = [];
  bool isLoading = false;

  double tongThu = 0;
  double tongChi = 0;
  ChiTietChiTieu? maxThu;
  ChiTietChiTieu? minThu;
  ChiTietChiTieu? maxChi;
  ChiTietChiTieu? minChi;

  @override
  void initState() {
    super.initState();
    if (widget.fromDate != null && widget.toDate != null) {
      fromDate = widget.fromDate;
      toDate = widget.toDate;
    } else {
      final now = DateTime.now();
      fromDate = DateTime(now.year, now.month, 1);
      toDate = now;
    }
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final all = await _ctDao.getAll();
    danhMucs = await _dmDao.getAllDanhMuc();
    giaoDichList =
        all
            .where((e) {
              final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
              return ngay != null &&
                  !ngay.isBefore(fromDate!) &&
                  !ngay.isAfter(toDate!);
            })
            .map((e) => e.chiTietChiTieu)
            .toList();
    giaoDichList.sort((a, b) => b.ngay.compareTo(a.ngay));
    // Thống kê
    tongThu = 0;
    tongChi = 0;
    maxThu = null;
    minThu = null;
    maxChi = null;
    minChi = null;
    for (var ct in giaoDichList) {
      final dm = danhMucs.firstWhere(
        (d) => d.id == ct.danhMucId,
        orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
      );
      if (dm.loai == 1) {
        tongThu += ct.soTien;
        if (maxThu == null || ct.soTien > maxThu!.soTien) maxThu = ct;
        if (minThu == null || ct.soTien < minThu!.soTien) minThu = ct;
      } else if (dm.loai == 2) {
        tongChi += ct.soTien;
        if (maxChi == null || ct.soTien > maxChi!.soTien) maxChi = ct;
        if (minChi == null || ct.soTien < minChi!.soTien) minChi = ct;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate! : toDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(fromDate!)) toDate = fromDate;
        } else {
          toDate = picked;
          if (fromDate != null && fromDate!.isAfter(toDate!)) fromDate = toDate;
        }
      });
      loadData();
    }
  }

  String _getDanhMucText(int danhMucId) {
    final dm = danhMucs.firstWhere(
      (d) => d.id == danhMucId,
      orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
    );
    return '${dm.icon ?? ''} ${dm.ten}';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi tiêu'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            color: Colors.teal.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.teal,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Từ ngày:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () => _pickDate(isFrom: true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.teal.shade100,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: Colors.teal,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateFormat.format(fromDate!),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.teal,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Đến ngày:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () => _pickDate(isFrom: false),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.teal.shade100,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: Colors.teal,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateFormat.format(toDate!),
                                                ),
                                              ],
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
                                        Icons.arrow_upward,
                                        color: Colors.green,
                                        size: 28,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Tổng thu nhập:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        tongThu.toStringAsFixed(0) + ' đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Tổng chi tiêu:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        tongChi.toStringAsFixed(0) + ' đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  if (maxThu != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: Colors.green[800],
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Giao dịch thu nhập lớn nhất:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${maxThu!.soTien.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (maxThu != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        '${_getDanhMucText(maxThu!.danhMucId)} - ${dateFormat.format(DateTime.parse(maxThu!.ngay))}',
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  if (minThu != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_down,
                                          color: Colors.green[400],
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Giao dịch thu nhập nhỏ nhất:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${minThu!.soTien.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.green[400],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (minThu != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        '${_getDanhMucText(minThu!.danhMucId)} - ${dateFormat.format(DateTime.parse(minThu!.ngay))}',
                                        style: TextStyle(
                                          color: Colors.green[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  if (maxChi != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: Colors.red[800],
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Giao dịch chi phí lớn nhất:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${maxChi!.soTien.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (maxChi != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        '${_getDanhMucText(maxChi!.danhMucId)} - ${dateFormat.format(DateTime.parse(maxChi!.ngay))}',
                                        style: TextStyle(
                                          color: Colors.red[800],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  if (minChi != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_down,
                                          color: Colors.red[400],
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Giao dịch chi phí nhỏ nhất:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${minChi!.soTien.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            color: Colors.red[400],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (minChi != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        '${_getDanhMucText(minChi!.danhMucId)} - ${dateFormat.format(DateTime.parse(minChi!.ngay))}',
                                        style: TextStyle(
                                          color: Colors.red[400],
                                          fontSize: 13,
                                        ),
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
                            vertical: 8,
                          ),
                          child: Text(
                            'Danh sách giao dịch',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: Colors.teal.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                giaoDichList.isEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Center(
                                        child: Text(
                                          'Không có giao dịch nào trong khoảng thời gian này',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    )
                                    : ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(12),
                                      itemCount: giaoDichList.length,
                                      separatorBuilder:
                                          (_, __) => SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final ct = giaoDichList[index];
                                        final dm = danhMucs.firstWhere(
                                          (d) => d.id == ct.danhMucId,
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  isThu
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                              child: Text(
                                                dm.icon ?? '',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            title: Text(
                                              dm.ten,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              dateFormat.format(
                                                DateTime.parse(ct.ngay),
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${ct.soTien.toStringAsFixed(0)} đ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isThu
                                                            ? Colors.green
                                                            : Colors.red,
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
                                                            (_) =>
                                                                ThemChiTietScreen(
                                                                  chiTiet: ct,
                                                                  danhMuc: dm,
                                                                ),
                                                      ),
                                                    );
                                                    loadData(); // Refresh data after editing
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
                                                        ct.id!,
                                                      );
                                                      loadData(); // Refresh data after deleting
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
