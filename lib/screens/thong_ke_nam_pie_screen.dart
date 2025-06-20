import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import 'package:fl_chart/fl_chart.dart';

class ThongKeNamPieScreen extends StatefulWidget {
  const ThongKeNamPieScreen({super.key});

  @override
  State<ThongKeNamPieScreen> createState() => _ThongKeNamPieScreenState();
}

class _ThongKeNamPieScreenState extends State<ThongKeNamPieScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  int selectedYear = DateTime.now().year;
  List<int> allYears = [];
  List<_MonthStat> monthStats = [];
  bool isLoading = false;

  // Thống kê
  double maxThu = 0,
      minThu = 0,
      maxChi = 0,
      minChi = 0,
      maxConLai = 0,
      minConLai = 0;
  int maxThuMonth = 1,
      minThuMonth = 1,
      maxChiMonth = 1,
      minChiMonth = 1,
      maxConLaiMonth = 1,
      minConLaiMonth = 1;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final all = await _ctDao.getAll();
    Set<int> yearSet = {};
    Map<int, double> thuMap = {}, chiMap = {};
    for (var item in all) {
      final ngay = DateTime.tryParse(item.chiTietChiTieu.ngay);
      if (ngay == null) continue;
      yearSet.add(ngay.year);
      final isThu = item.danhMuc.loai == 1;
      if (ngay.year == selectedYear) {
        if (isThu) {
          thuMap[ngay.month] =
              (thuMap[ngay.month] ?? 0) + item.chiTietChiTieu.soTien;
        } else {
          chiMap[ngay.month] =
              (chiMap[ngay.month] ?? 0) + item.chiTietChiTieu.soTien;
        }
      }
    }
    allYears = yearSet.toList()..sort();
    monthStats =
        List.generate(12, (i) {
              final m = i + 1;
              final thu = thuMap[m] ?? 0;
              final chi = chiMap[m] ?? 0;
              return _MonthStat(m, thu, chi, thu - chi);
            })
            // Lọc chỉ giữ các tháng có dữ liệu
            .where((e) => e.thu > 0 || e.chi > 0)
            .toList();
    // Thống kê cao/thấp nhất
    maxThu = monthStats.map((e) => e.thu).reduce((a, b) => a > b ? a : b);
    minThu = monthStats.map((e) => e.thu).reduce((a, b) => a < b ? a : b);
    maxChi = monthStats.map((e) => e.chi).reduce((a, b) => a > b ? a : b);
    minChi = monthStats.map((e) => e.chi).reduce((a, b) => a < b ? a : b);
    maxConLai = monthStats.map((e) => e.conLai).reduce((a, b) => a > b ? a : b);
    minConLai = monthStats.map((e) => e.conLai).reduce((a, b) => a < b ? a : b);
    maxThuMonth = monthStats.firstWhere((e) => e.thu == maxThu).month;
    minThuMonth = monthStats.firstWhere((e) => e.thu == minThu).month;
    maxChiMonth = monthStats.firstWhere((e) => e.chi == maxChi).month;
    minChiMonth = monthStats.firstWhere((e) => e.chi == minChi).month;
    maxConLaiMonth = monthStats.firstWhere((e) => e.conLai == maxConLai).month;
    minConLaiMonth = monthStats.firstWhere((e) => e.conLai == minConLai).month;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
      Colors.pink,
      Colors.lime,
      Colors.brown,
      Colors.deepOrange,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Biểu đồ thu nhập/chi phí theo năm',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: DropdownButtonFormField<int>(
                                      value: selectedYear,
                                      decoration: InputDecoration(
                                        labelText: 'Năm',
                                        prefixIcon: Icon(
                                          Icons.date_range,
                                          color: Colors.teal,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.teal,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 0,
                                          horizontal: 8,
                                        ),
                                      ),
                                      items:
                                          allYears
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
                                            selectedYear = value;
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
                                  Text(
                                    'Thống kê',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  // Tổng thu nhập, chi phí, còn lại
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.savings,
                                        color: Colors.green,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tổng thu nhập:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        monthStats.isNotEmpty
                                            ? monthStats
                                                    .map((e) => e.thu)
                                                    .reduce((a, b) => a + b)
                                                    .toStringAsFixed(0) +
                                                ' đ'
                                            : '0 đ',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.money_off,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tổng chi phí:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        monthStats.isNotEmpty
                                            ? monthStats
                                                    .map((e) => e.chi)
                                                    .reduce((a, b) => a + b)
                                                    .toStringAsFixed(0) +
                                                ' đ'
                                            : '0 đ',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.teal,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Còn lại:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        monthStats.isNotEmpty
                                            ? (monthStats
                                                            .map((e) => e.thu)
                                                            .reduce(
                                                              (a, b) => a + b,
                                                            ) -
                                                        monthStats
                                                            .map((e) => e.chi)
                                                            .reduce(
                                                              (a, b) => a + b,
                                                            ))
                                                    .toStringAsFixed(0) +
                                                ' đ'
                                            : '0 đ',
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Thu nhập cao nhất:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${maxThu.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(tháng $maxThuMonth)',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Chi phí cao nhất:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${maxChi.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(tháng $maxChiMonth)',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.teal,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Còn lại cao nhất:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${maxConLai.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(tháng $maxConLaiMonth)',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Thu nhập thấp nhất:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${minThu.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(tháng $minThuMonth)',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Chi phí thấp nhất:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${minChi.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(tháng $minChiMonth)',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.teal,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Còn lại thấp nhất:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${minConLai.toStringAsFixed(0)} đ',
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(tháng $minConLaiMonth)',
                                        style: TextStyle(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            'Chi tiết theo tháng',
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
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: monthStats.length,
                              separatorBuilder: (_, __) => SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final stat = monthStats[index];
                                final total = stat.thu + stat.chi;
                                final thuPercent =
                                    total > 0 ? stat.thu / total * 100 : 0.0;
                                final chiPercent =
                                    total > 0 ? stat.chi / total * 100 : 0.0;
                                return Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: stat.thu,
                                              title:
                                                  thuPercent > 0
                                                      ? '${thuPercent.toStringAsFixed(0)}%'
                                                      : '',
                                              titleStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                              radius: 24,
                                            ),
                                            PieChartSectionData(
                                              color: Colors.red,
                                              value: stat.chi,
                                              title:
                                                  chiPercent > 0
                                                      ? '${chiPercent.toStringAsFixed(0)}%'
                                                      : '',
                                              titleStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                              radius: 24,
                                            ),
                                          ],
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 16,
                                        ),
                                      ),
                                    ),
                                    minVerticalPadding: 16,
                                    title: Text(
                                      'Tháng ${stat.month}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_upward,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Thu nhập: ',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              '${stat.thu.toStringAsFixed(0)} đ',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '(${thuPercent.toStringAsFixed(0)}%)',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_downward,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Chi phí: ',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            Text(
                                              '${stat.chi.toStringAsFixed(0)} đ',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '(${chiPercent.toStringAsFixed(0)}%)',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.teal,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Còn lại: ',
                                              style: TextStyle(
                                                color: Colors.teal,
                                              ),
                                            ),
                                            Text(
                                              '${stat.conLai.toStringAsFixed(0)} đ',
                                              style: TextStyle(
                                                color: Colors.teal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Thu nhập',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        SizedBox(
                                          height: 120,
                                          child: PieChart(
                                            PieChartData(
                                              sections: List.generate(
                                                monthStats.length,
                                                (i) {
                                                  final stat = monthStats[i];
                                                  final color =
                                                      colors[i % colors.length];
                                                  final total = monthStats.fold(
                                                    0.0,
                                                    (p, e) => p + e.thu,
                                                  );
                                                  final percent =
                                                      total > 0
                                                          ? stat.thu /
                                                              total *
                                                              100
                                                          : 0.0;
                                                  return PieChartSectionData(
                                                    color: color,
                                                    value: stat.thu,
                                                    title:
                                                        percent > 0
                                                            ? '${percent.toStringAsFixed(0)}%'
                                                            : '',
                                                    titleStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    radius: 40,
                                                  );
                                                },
                                              ),
                                              sectionsSpace: 2,
                                              centerSpaceRadius: 32,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            for (
                                              int i = 0;
                                              i < monthStats.length;
                                              i++
                                            )
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          colors[i %
                                                              colors.length],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Tháng ${monthStats[i].month}',
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Chi phí',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        SizedBox(
                                          height: 120,
                                          child: PieChart(
                                            PieChartData(
                                              sections: List.generate(
                                                monthStats.length,
                                                (i) {
                                                  final stat = monthStats[i];
                                                  final color =
                                                      colors[i % colors.length];
                                                  final total = monthStats.fold(
                                                    0.0,
                                                    (p, e) => p + e.chi,
                                                  );
                                                  final percent =
                                                      total > 0
                                                          ? stat.chi /
                                                              total *
                                                              100
                                                          : 0.0;
                                                  return PieChartSectionData(
                                                    color: color,
                                                    value: stat.chi,
                                                    title:
                                                        percent > 0
                                                            ? '${percent.toStringAsFixed(0)}%'
                                                            : '',
                                                    titleStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    radius: 40,
                                                  );
                                                },
                                              ),
                                              sectionsSpace: 2,
                                              centerSpaceRadius: 32,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            for (
                                              int i = 0;
                                              i < monthStats.length;
                                              i++
                                            )
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          colors[i %
                                                              colors.length],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Tháng ${monthStats[i].month}',
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
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
    );
  }
}

class _MonthStat {
  final int month;
  final double thu;
  final double chi;
  final double conLai;
  _MonthStat(this.month, this.thu, this.chi, this.conLai);
}
