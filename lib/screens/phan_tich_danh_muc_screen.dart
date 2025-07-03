import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/danh_muc.dart';
import '../db/danh_muc_dao.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import 'package:intl/intl.dart';

class PhanTichDanhMucScreenNew extends StatefulWidget {
  @override
  State<PhanTichDanhMucScreenNew> createState() =>
      _PhanTichDanhMucScreenNewState();
}

class _PhanTichDanhMucScreenNewState extends State<PhanTichDanhMucScreenNew> {
  final DanhMucDao _dmDao = DanhMucDao();
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();

  int _loai = 2;
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  DanhMuc? _selectedDanhMuc;

  List<DanhMuc> _danhMucs = [];
  List<ChiTietChiTieuDanhMuc> _allTrans = [];
  Map<int, double> _tongTienMap = {};
  Map<int, List<double>> _soTienTheoThoiGian =
      {}; // id -> list số tiền theo thời gian
  double _tongTatCa = 0;

  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      _danhMucs = await _dmDao.getDanhMucByLoai(_loai);
      List<ChiTietChiTieuDanhMuc> all;
      if (_selectedMonth == null) {
        all = await _ctDao.getByYear(_selectedYear);
      } else {
        all = await _ctDao.getByMonth(_selectedMonth!, _selectedYear);
      }
      all = all.where((e) => e.danhMuc.loai == _loai).toList();

      // _allTrans: chỉ lọc theo danh mục nếu chọn 1 danh mục cụ thể
      if (_selectedDanhMuc != null) {
        _allTrans =
            all.where((e) => e.danhMuc.id == _selectedDanhMuc!.id).toList();
      } else {
        _allTrans = all;
      }

      // _tongTienMap: luôn tính tổng cho từng danh mục dựa trên all (không lọc theo danh mục)
      _tongTienMap = {};
      for (var dm in _danhMucs) {
        _tongTienMap[dm.id!] = all
            .where((e) => e.danhMuc.id == dm.id)
            .fold(0.0, (a, b) => a + b.chiTietChiTieu.soTien);
      }
      _tongTatCa = _tongTienMap.values.fold(0, (a, b) => a + b);

      // Tính _soTienTheoThoiGian cho từng danh mục
      _soTienTheoThoiGian = {};
      if (_selectedMonth == null) {
        // Theo tháng trong năm
        for (var dm in _danhMucs) {
          List<double> arr = [];
          for (int m = 1; m <= 12; m++) {
            final sum = all
                .where(
                  (e) =>
                      e.danhMuc.id == dm.id &&
                      DateTime.parse(e.chiTietChiTieu.ngay).month == m,
                )
                .fold(0.0, (a, b) => a + b.chiTietChiTieu.soTien);
            arr.add(sum);
          }
          _soTienTheoThoiGian[dm.id!] = arr;
        }
      } else {
        // Theo ngày trong tháng
        int days = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth!);
        for (var dm in _danhMucs) {
          List<double> arr = [];
          for (int d = 1; d <= days; d++) {
            final sum = all
                .where(
                  (e) =>
                      e.danhMuc.id == dm.id &&
                      DateTime.parse(e.chiTietChiTieu.ngay).day == d,
                )
                .fold(0.0, (a, b) => a + b.chiTietChiTieu.soTien);
            arr.add(sum);
          }
          _soTienTheoThoiGian[dm.id!] = arr;
        }
      }
    } catch (e, stack) {
      _errorMessage = e.toString();
      print('Lỗi khi load dữ liệu: $e');
      print(stack);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi load dữ liệu: $_errorMessage')),
        );
        _errorMessage = null;
      }
    });
    return Scaffold(
      backgroundColor: Color(0xFFF1F8F6),
      appBar: AppBar(
        title: const Text('Phân tích chi tiêu'),
        backgroundColor: Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFilterCard(),
                    const SizedBox(height: 16),
                    if (_allTrans.isEmpty)
                      _buildEmptyState()
                    else ...[
                      _buildPieChartCard(),
                      const SizedBox(height: 16),
                      _buildDanhMucListCard(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bộ lọc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDropdown<int>(
              label: 'Loại',
              value: _loai,
              icon: Icons.swap_horiz,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Thu nhập')),
                DropdownMenuItem(value: 2, child: Text('Chi phí')),
              ],
              onChanged: (val) {
                setState(() => _loai = val ?? 2);
                _selectedDanhMuc = null;
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown<int?>(
              label: 'Danh mục',
              value: _selectedDanhMuc?.id,
              icon: Icons.category,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ..._danhMucs.map(
                  (dm) => DropdownMenuItem(
                    value: dm.id,
                    child: Text('${dm.icon} ${dm.ten}'),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedDanhMuc = _danhMucs.firstWhere(
                    (e) => e.id == val,
                    orElse: () => DanhMuc(id: -1, ten: '', loai: _loai),
                  );
                });
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown<int>(
              label: 'Năm',
              value: _selectedYear,
              icon: Icons.calendar_today,
              items: List.generate(6, (i) {
                final y = DateTime.now().year - 3 + i;
                return DropdownMenuItem(value: y, child: Text('Năm $y'));
              }),
              onChanged: (val) {
                setState(() => _selectedYear = val ?? DateTime.now().year);
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown<int?>(
              label: 'Tháng',
              value: _selectedMonth,
              icon: Icons.calendar_view_month,
              items: [
                const DropdownMenuItem(value: null, child: Text('Cả năm')),
                ...List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Tháng ${i + 1}'),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedMonth = val);
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF00897B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: const [
        SizedBox(height: 32),
        Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Không có dữ liệu',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPieChartCard() {
    final filtered =
        _danhMucs.where((dm) => (_tongTienMap[dm.id] ?? 0) > 0).toList();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedMonth == null
                  ? 'Tổng chi năm $_selectedYear'
                  : 'Tổng chi tháng $_selectedMonth/$_selectedYear',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections:
                      filtered.map((dm) {
                        final value = _tongTienMap[dm.id]!;
                        final percent = value / _tongTatCa;
                        return PieChartSectionData(
                          value: value,
                          title: '${(percent * 100).toStringAsFixed(1)}%',
                          color: _getColor(dm.id!),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          radius: 60,
                        );
                      }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isNotEmpty) ...[
              Text(
                'Tổng tiền: ${_tongTatCa.toStringAsFixed(0)} đ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Builder(
                builder: (_) {
                  final sorted =
                      filtered.toList()..sort(
                        (a, b) => (_tongTienMap[b.id] ?? 0).compareTo(
                          _tongTienMap[a.id] ?? 0,
                        ),
                      );
                  final maxDm = sorted.first;
                  final minDm = sorted.last;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cao nhất: ${maxDm.icon ?? ''} ${maxDm.ten} (${(_tongTienMap[maxDm.id] ?? 0).toStringAsFixed(0)} đ)',
                        style: TextStyle(color: Colors.green[800]),
                      ),
                      Text(
                        'Thấp nhất: ${minDm.icon ?? ''} ${minDm.ten} (${(_tongTienMap[minDm.id] ?? 0).toStringAsFixed(0)} đ)',
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children:
                    filtered
                        .map(
                          (dm) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 8,
                                color: _getColor(dm.id!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dm.icon ?? ''} ${dm.ten}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDanhMucListCard() {
    final filtered =
        _danhMucs.where((dm) => (_tongTienMap[dm.id] ?? 0) > 0).toList();
    filtered.sort((a, b) => (_tongTienMap[b.id] ?? 0).compareTo(_tongTienMap[a.id] ?? 0));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Danh sách danh mục',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, idx) {
                final dm = filtered[idx];
                final value = _tongTienMap[dm.id] ?? 0;
                final percent = _tongTatCa > 0 ? value / _tongTatCa : 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColor(dm.id!).withOpacity(0.2),
                    child: Text(
                      dm.icon ?? '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    dm.ten,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Tổng: ${value.toStringAsFixed(0)} đ | ${(percent * 100).toStringAsFixed(1)}%',
                  ),
                  trailing: const Icon(
                    Icons.bar_chart,
                    color: Color(0xFF00897B),
                  ),
                  onTap: () => _showDanhMucDetail(dm),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDanhMucDetail(DanhMuc dm) {
    final trans =
        _allTrans.where((e) => e.danhMuc.id == dm.id).toList()..sort(
          (a, b) => b.chiTietChiTieu.ngay.compareTo(a.chiTietChiTieu.ngay),
        );
    final soTienList =
        (_soTienTheoThoiGian[dm.id] ?? []).where((e) => e > 0).toList();
    final value = _tongTienMap[dm.id] ?? 0;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder:
              (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.teal.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.teal.withOpacity(
                                    0.15,
                                  ),
                                  child: Text(
                                    dm.icon ?? '',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dm.ten,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Tổng: 	${value.toStringAsFixed(0)} đ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '${_tongTatCa > 0 ? ((value / _tongTatCa) * 100).toStringAsFixed(1) : '0'}%',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 200,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child:
                                  soTienList.isEmpty
                                      ? Center(
                                        child: Text(
                                          'Chưa có dữ liệu',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                      : LineChart(
                                        LineChartData(
                                          lineTouchData: LineTouchData(
                                            touchTooltipData:
                                                LineTouchTooltipData(
                                                  tooltipBgColor:
                                                      Colors.transparent,
                                                  getTooltipItems: (
                                                    touchedSpots,
                                                  ) {
                                                    return touchedSpots.map((
                                                      spot,
                                                    ) {
                                                      return LineTooltipItem(
                                                        '${spot.y.toInt()} đ',
                                                        const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      );
                                                    }).toList();
                                                  },
                                                ),
                                            touchCallback: (event, response) {
                                              // bạn có thể xử lý thêm ở đây nếu muốn
                                              // ví dụ in ra giá trị được chạm vào
                                              if (event is FlTapUpEvent &&
                                                  response != null &&
                                                  response.lineBarSpots !=
                                                      null) {
                                                final spot =
                                                    response
                                                        .lineBarSpots!
                                                        .first;
                                                print(
                                                  'Bạn đã chạm vào: x=${spot.x}, y=${spot.y}',
                                                );
                                              }
                                            },
                                            handleBuiltInTouches: true,
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: [
                                                for (
                                                  int i = 0;
                                                  i < soTienList.length;
                                                  i++
                                                )
                                                  FlSpot(
                                                    i.toDouble(),
                                                    soTienList[i],
                                                  ),
                                              ],
                                              isCurved: true,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.teal,
                                                  Colors.greenAccent,
                                                ],
                                              ),
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: true,
                                              ), // Bật chấm dữ liệu
                                              belowBarData: BarAreaData(
                                                show: true,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.teal.withOpacity(
                                                      0.3,
                                                    ),
                                                    Colors.greenAccent
                                                        .withOpacity(0.1),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ],
                                          minY: 0,
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            getDrawingHorizontalLine:
                                                (value) => FlLine(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  strokeWidth: 1,
                                                ),
                                            getDrawingVerticalLine:
                                                (value) => FlLine(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  strokeWidth: 1,
                                                ),
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                  if (!soTienList.contains(
                                                    value,
                                                  ))
                                                    return const SizedBox.shrink();
                                                  return Text(
                                                    value % 1 == 0
                                                        ? value.toStringAsFixed(
                                                          0,
                                                        )
                                                        : value.toStringAsFixed(
                                                          1,
                                                        ),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.teal,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    'T${value.toInt() + 1}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Danh sách giao dịch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: trans.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, idx) {
                        final gd = trans[idx];
                        return ListTile(
                          leading: Icon(
                            Icons.monetization_on,
                            color: Colors.teal,
                          ),
                          title: Text(
                            '${gd.chiTietChiTieu.soTien.toStringAsFixed(0)} đ',
                          ),
                          subtitle: Text(
                            '${gd.chiTietChiTieu.ngay} - ${gd.chiTietChiTieu.ghiChu}',
                          ),
                        );
                      },
                    ),
                    // TODO: Bổ sung bảng số liệu, thống kê cao/thấp nhất, ...
                  ],
                ),
              ),
        );
      },
    );
  }

  Color _getColor(int id) {
    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.indigo,
      Colors.green,
    ];
    return colors[id % colors.length];
  }

  double _getLeftInterval(List<double> soTienList) {
    if (soTienList.isEmpty) return 1;
    final max = soTienList.reduce((a, b) => a > b ? a : b);
    if (max <= 1000) return 200;
    if (max <= 10000) return 2000;
    if (max <= 50000) return 5000;
    return 10000;
  }
}
