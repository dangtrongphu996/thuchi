import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/danh_muc.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  State<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  List<PieChartSectionData> sections = [];

  Future<void> loadData() async {
    final list = await _ctDao.getByMonth(
      DateTime.now().month,
      DateTime.now().year,
    );
    final danhMucs = await _dmDao.getAllDanhMuc();

    Map<String, double> tongTienTheoDanhMuc = {};

    for (var item in list) {
      final dm = danhMucs.firstWhere((e) => e.id == item.danhMuc.id);
      if (dm.loai == 2) {
        // Chỉ vẽ biểu đồ chi
        tongTienTheoDanhMuc.update(
          dm.ten,
          (value) => value + item.chiTietChiTieu.soTien,
          ifAbsent: () => item.chiTietChiTieu.soTien,
        );
      }
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
    ];

    sections =
        tongTienTheoDanhMuc.entries.map((e) {
          final index = tongTienTheoDanhMuc.keys.toList().indexOf(e.key);
          return PieChartSectionData(
            title: e.key,
            value: e.value,
            color: colors[index % colors.length],
            radius: 70,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biểu đồ chi tiêu')),
      body:
          sections.isEmpty
              ? Center(child: CircularProgressIndicator())
              : PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
    );
  }
}
