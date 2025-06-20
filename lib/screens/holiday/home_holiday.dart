// holiday/home_holiday.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thuchi/screens/holiday/add_holiday.dart';
import 'package:path_provider/path_provider.dart';
import 'holiday.dart';
import 'package:thuchi/screens/demnguoctet/dem_nguoc_tet.dart';

class HolidayListScreen extends StatefulWidget {
  const HolidayListScreen({super.key});

  @override
  _HolidayListScreenState createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends State<HolidayListScreen> {
  List<Holiday> holidays = [];

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/holidays.txt');
  }

  Future<void> _loadHolidays() async {
    try {
      final file = await _getFile();
      final contents = await file.readAsLines();
      setState(() {
        holidays = contents.map((line) => Holiday.fromString(line)).toList();
        holidays.sort((a, b) => a.date.compareTo(b.date));
      });
    } catch (e) {
      print('Không thể tải dữ liệu: $e');
    }
  }

  Future<void> _saveHolidays() async {
    final file = await _getFile();
    final content = holidays.map((h) => h.toString()).join('\n');
    await file.writeAsString(content);
  }

  void _addOrEditHoliday({Holiday? holiday}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditHolidayScreen(holiday: holiday),
      ),
    );

    if (result != null) {
      setState(() {
        if (holiday != null) {
          holidays.remove(holiday);
        }
        holidays.add(result);
        holidays.sort((a, b) => a.date.compareTo(b.date));
      });
      _saveHolidays();
    }
  }

  void _deleteHoliday(Holiday holiday) {
    setState(() {
      holidays.remove(holiday);
    });
    _saveHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Danh sách ngày nghỉ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 'Danh sách ngày nghỉ'.length > 20 ? 16 : 26,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.pink[400],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink[300]!, Colors.pink[500]!],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          holidays.isEmpty
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[100]!, Colors.grey[50]!],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          size: 80,
                          color: Colors.pink[300],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Chưa có ngày nghỉ nào',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          'Nhấn nút + để thêm ngày nghỉ mới',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[100]!, Colors.grey[50]!],
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  itemCount: holidays.length,
                  itemBuilder: (context, index) {
                    final holiday = holidays[index];
                    final daysLeft =
                        holiday.date
                            .difference(DateTime.now().toLocal())
                            .inDays;
                    return FutureBuilder<bool>(
                      future: checkImageExists(holiday.imagePath),
                      builder: (context, snapshot) {
                        bool hasImage = snapshot.data ?? false;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (holiday.imagePath != null && hasImage)
                                  Stack(
                                    children: [
                                      Hero(
                                        tag: 'holiday_image_${holiday.name}',
                                        child: Image.file(
                                          File(holiday.imagePath!),
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.8),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        left: 20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            holiday.name,
                                            style: TextStyle(
                                              color: Colors.pink[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (holiday.imagePath == null ||
                                          !hasImage)
                                        Text(
                                          holiday.name,
                                          style: TextStyle(
                                            color: Colors.pink[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue[400]!,
                                              Colors.blue[600]!,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue[200]!
                                                  .withOpacity(0.5),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Còn $daysLeft ngày',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.holiday_village,
                                            color: Colors.amber[700]!,
                                            label: 'Đếm ngược',
                                            onPressed:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            CountdownScreen(
                                                              holiday: holiday,
                                                            ),
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildActionButton(
                                            icon: Icons.edit,
                                            color: Colors.blue[700]!,
                                            label: 'Chỉnh sửa',
                                            onPressed:
                                                () => _addOrEditHoliday(
                                                  holiday: holiday,
                                                ),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildActionButton(
                                            icon: Icons.delete,
                                            color: Colors.red[600]!,
                                            label: 'Xóa',
                                            onPressed:
                                                () => _deleteHoliday(holiday),
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
                    );
                  },
                ),
              ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[300]!, Colors.pink[500]!],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.pink[300]!.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _addOrEditHoliday(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 28),
          label: const Text(
            'Thêm ngày nghỉ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkImageExists(String? path) async {
    if (path == null) return false;
    final file = File(path);
    return await file.exists();
  }
}
