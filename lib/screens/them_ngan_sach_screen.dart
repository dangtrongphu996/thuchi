import 'package:flutter/material.dart';
import '../models/danh_muc.dart';
import '../db/ngan_sach_dao.dart';
import '../models/ngan_sach.dart';
import 'package:flutter/services.dart';

class ThemNganSachScreen extends StatefulWidget {
  final DanhMuc danhMuc;
  final NganSach? nganSach;
  const ThemNganSachScreen({super.key, required this.danhMuc, this.nganSach});

  @override
  State<ThemNganSachScreen> createState() => _ThemNganSachScreenState();
}

class _ThemNganSachScreenState extends State<ThemNganSachScreen> {
  final _soTienController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final NganSachDao _dao = NganSachDao();

  @override
  void initState() {
    super.initState();
    if (widget.nganSach != null) {
      final soTien = widget.nganSach!.soTien;
      _soTienController.text =
          soTien % 1 == 0 ? soTien.toInt().toString() : soTien.toString();
      _selectedMonth = widget.nganSach!.thang;
      _selectedYear = widget.nganSach!.nam;
    }
  }

  void _save() async {
    if (_soTienController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Số tiền không được để trống')));
      return;
    }
    if (widget.nganSach == null) {
      // Kiểm tra trùng ngân sách
      final existed = await _dao.getByDanhMucAndMonth(
        widget.danhMuc.id!,
        _selectedMonth,
        _selectedYear,
      );
      if (existed != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ngân sách cho danh mục này đã tồn tại!')),
        );
        return;
      }
    }
    if (widget.nganSach != null) {
      final nganSach = NganSach(
        id: widget.nganSach!.id,
        danhMucId: widget.danhMuc.id!,
        thang: _selectedMonth,
        nam: _selectedYear,
        soTien: double.tryParse(_soTienController.text) ?? 0,
      );
      await _dao.update(nganSach);
    } else {
      final nganSach = NganSach(
        danhMucId: widget.danhMuc.id!,
        thang: _selectedMonth,
        nam: _selectedYear,
        soTien: double.tryParse(_soTienController.text) ?? 0,
      );
      await _dao.insert(nganSach);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nganSach != null ? 'Chỉnh sửa Ngân Sách' : 'Thêm Ngân Sách',
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh mục',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          widget.danhMuc.icon ?? '',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.danhMuc.ten,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Số tiền ngân sách',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _soTienController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Nhập số tiền',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Số tiền không được để trống';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            decoration: InputDecoration(
                              labelText: 'Tháng',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items:
                                List.generate(12, (i) => i + 1)
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text('Tháng $e'),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _selectedMonth = v!),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: InputDecoration(
                              labelText: 'Năm',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items:
                                List.generate(
                                      5,
                                      (i) => DateTime.now().year - 2 + i,
                                    )
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text('$e'),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _selectedYear = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text(
                  widget.nganSach != null
                      ? 'Cập nhật ngân sách'
                      : 'Lưu ngân sách',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
