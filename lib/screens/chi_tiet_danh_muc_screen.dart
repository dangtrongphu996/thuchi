import 'package:flutter/material.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';

class ChiTietDanhMucScreen extends StatefulWidget {
  final int danhMucId;
  final String tenDanhMuc;
  final String icon;
  final int loai;
  final double tong;
  final int month;
  final int year;
  final double tongChi;
  const ChiTietDanhMucScreen({
    super.key,
    required this.danhMucId,
    required this.tenDanhMuc,
    required this.icon,
    required this.loai,
    required this.tong,
    required this.month,
    required this.year,
    required this.tongChi,
  });

  @override
  State<ChiTietDanhMucScreen> createState() => _ChiTietDanhMucScreenState();
}

class _ChiTietDanhMucScreenState extends State<ChiTietDanhMucScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  List<ChiTietChiTieu> giaoDichList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final list = await _ctDao.getAll();
    giaoDichList =
        list
            .where((item) {
              final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay);
              return ngay != null &&
                  ngay.month == widget.month &&
                  ngay.year == widget.year &&
                  item.chiTietChiTieu.danhMucId == widget.danhMucId;
            })
            .map((e) => e.chiTietChiTieu)
            .toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.icon, style: TextStyle(fontSize: 26)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.tenDanhMuc,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card tổng quan
                      Card(
                        color: Colors.orange.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.loai == 2) ...[
                                Text(
                                  'Tiến độ sử dụng ngân sách:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value:
                                      widget.tongChi > 0
                                          ? widget.tong / widget.tongChi
                                          : 0.0,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.redAccent,
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.orange,
                                    size: 22,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tổng số tiền:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${widget.tong.toStringAsFixed(0)} đ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          widget.loai == 1
                                              ? Colors.green
                                              : Colors.red,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    color: Colors.blueGrey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Số giao dịch:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${giaoDichList.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Danh sách giao dịch',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      giaoDichList.isEmpty
                          ? Center(
                            child: Text(
                              'Không có giao dịch nào',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: giaoDichList.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final ct = giaoDichList[idx];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            widget.loai == 1
                                                ? Colors.green
                                                : Colors.red,
                                        radius: 22,
                                        child: Icon(
                                          widget.loai == 1
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color:
                                              widget.loai == 1
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${ct.soTien.toStringAsFixed(0)} đ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    widget.loai == 1
                                                        ? Colors.green
                                                        : Colors.red,
                                                fontSize: 17,
                                              ),
                                            ),
                                            if ((ct.ghiChu ?? '').isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2.0,
                                                  bottom: 2.0,
                                                ),
                                                child: Text(
                                                  ct.ghiChu ?? '',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 13,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  ct.ngay,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blueGrey,
                                                    fontWeight: FontWeight.w500,
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
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
