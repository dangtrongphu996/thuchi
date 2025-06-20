import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/danh_muc.dart';
import 'them_chi_tiet_screen.dart';

class LichThuChiScreen extends StatefulWidget {
  const LichThuChiScreen({super.key});

  @override
  State<LichThuChiScreen> createState() => _LichThuChiScreenState();
}

class _LichThuChiScreenState extends State<LichThuChiScreen> {
  final ChiTietChiTieuDao _ctDao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  Map<DateTime, List<ChiTietChiTieu>> _events = {};
  List<DanhMuc> danhMucs = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ChiTietChiTieu> _selectedEvents = [];
  bool isLoading = false;

  double tongThu = 0;
  double tongChi = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final all = await _ctDao.getAll();
    danhMucs = await _dmDao.getAllDanhMuc();
    Map<DateTime, List<ChiTietChiTieu>> events = {};
    for (var e in all) {
      final ngay = DateTime.tryParse(e.chiTietChiTieu.ngay);
      if (ngay != null) {
        final key = DateTime(ngay.year, ngay.month, ngay.day);
        events.putIfAbsent(key, () => []).add(e.chiTietChiTieu);
      }
    }
    setState(() {
      _events = events;
      _selectedEvents = _events[_selectedDay] ?? [];
      _updateStats();
      isLoading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    setState(() {
      _selectedDay = normalizedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _events[normalizedDay] ?? [];
      _updateStats();
    });
  }

  void _updateStats() {
    tongThu = 0;
    tongChi = 0;
    for (var ct in _selectedEvents) {
      final dm = danhMucs.firstWhere(
        (d) => d.id == ct.danhMucId,
        orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
      );
      if (dm.loai == 1) {
        tongThu += ct.soTien;
      } else if (dm.loai == 2) {
        tongChi += ct.soTien;
      }
    }
  }

  List<Widget> _buildEventMarkers(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _events[normalizedDay] ?? [];
    bool hasThu = false;
    bool hasChi = false;
    for (var ct in events) {
      final dm = danhMucs.firstWhere(
        (d) => d.id == ct.danhMucId,
        orElse: () => DanhMuc(id: 0, ten: '', icon: '', loai: 2),
      );
      if (dm.loai == 1) hasThu = true;
      if (dm.loai == 2) hasChi = true;
    }
    List<Widget> markers = [];
    if (hasThu) {
      markers.add(
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    if (hasChi) {
      markers.add(
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        ),
      );
    }
    return markers;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch thu chi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  TableCalendar<ChiTietChiTieu>(
                    firstDay: DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 3,
                      1,
                    ),
                    lastDay: DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 3,
                      31,
                    ),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    eventLoader:
                        (day) =>
                            _events[DateTime(day.year, day.month, day.day)] ??
                            [],
                    onDaySelected: _onDaySelected,
                    locale: 'vi',
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 2,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        final markers = _buildEventMarkers(day);
                        if (markers.isEmpty) return null;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: markers,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      color: Colors.deepPurple.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.arrow_upward, color: Colors.green),
                                SizedBox(width: 6),
                                Text(
                                  'Thu nhập:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  tongThu.toStringAsFixed(0) + ' đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.arrow_downward, color: Colors.red),
                                SizedBox(width: 6),
                                Text(
                                  'Chi phí:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  tongChi.toStringAsFixed(0) + ' đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
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
                        _selectedEvents.isEmpty
                            ? Center(
                              child: Text(
                                'Không có giao dịch nào trong ngày này',
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _selectedEvents.length,
                              separatorBuilder: (_, __) => SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final ct = _selectedEvents[index];
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
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          isThu
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                      child: Text(
                                        dm.icon ?? '',
                                        style: TextStyle(fontSize: 20),
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
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          color: Colors.blue,
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        ThemChiTietScreen(
                                                          chiTiet: ct,
                                                          danhMuc: dm,
                                                        ),
                                              ),
                                            );
                                            loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () async {
                                            final bool
                                            confirmDelete = await showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'Xác nhận xóa',
                                                    ),
                                                    content: const Text(
                                                      'Bạn có chắc chắn muốn xóa giao dịch này?',
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(false),
                                                        child: const Text(
                                                          'Hủy',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(true),
                                                        child: const Text(
                                                          'Xóa',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            if (confirmDelete) {
                                              await _ctDao.delete(ct.id!);
                                              loadData();
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
                ],
              ),
    );
  }
}
