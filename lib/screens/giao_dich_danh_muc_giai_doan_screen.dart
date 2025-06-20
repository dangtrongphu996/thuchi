import 'package:flutter/material.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'them_chi_tiet_screen.dart';
import 'package:intl/intl.dart';

class GiaoDichDanhMucGiaiDoanScreen extends StatefulWidget {
  final int danhMucId;
  final String tenDanhMuc;
  final int loai;
  final DateTime start;
  final DateTime end;
  const GiaoDichDanhMucGiaiDoanScreen({
    super.key,
    required this.danhMucId,
    required this.tenDanhMuc,
    required this.loai,
    required this.start,
    required this.end,
  });

  @override
  State<GiaoDichDanhMucGiaiDoanScreen> createState() =>
      _GiaoDichDanhMucGiaiDoanScreenState();
}

class _GiaoDichDanhMucGiaiDoanScreenState
    extends State<GiaoDichDanhMucGiaiDoanScreen> {
  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  List<ChiTietChiTieuDanhMuc> _list = [];
  double tongTien = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final all = await _dao.getAll();
    final filtered =
        all.where((e) {
          final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
          return e.danhMuc.id == widget.danhMucId &&
              ngay != null &&
              !ngay.isBefore(widget.start) &&
              !ngay.isAfter(widget.end);
        }).toList();
    filtered.sort(
      (a, b) => b.chiTietChiTieu.soTien.compareTo(a.chiTietChiTieu.soTien),
    );
    tongTien = filtered.fold(0.0, (p, e) => p + e.chiTietChiTieu.soTien);
    setState(() {
      _list = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = widget.loai == 1 ? Colors.green : Colors.redAccent;
    final bgColor =
        widget.loai == 1 ? Colors.green.shade50 : Colors.red.shade50;
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenDanhMuc),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: bgColor,
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
                              color: mainColor,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng số tiền',
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
                                    color: mainColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Từ ${dateFormat.format(widget.start)} đến ${dateFormat.format(widget.end)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
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
                              separatorBuilder: (_, __) => SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _list[index];
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
                                          backgroundColor: bgColor,
                                          radius: 28,
                                          child: Text(
                                            item.danhMuc.icon ?? '',
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
                                                item.danhMuc.ten,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if ((item.chiTietChiTieu.ghiChu ??
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
                                        Text(
                                          '${item.chiTietChiTieu.soTien.toStringAsFixed(0)} đ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: mainColor,
                                          ),
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
    );
  }
}
