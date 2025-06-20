import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/chi_tiet_chi_tieu_dao.dart';
import '../db/danh_muc_dao.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/danh_muc.dart';

class ThemChiTietScreen extends StatefulWidget {
  final DanhMuc? danhMuc;
  final ChiTietChiTieu? chiTiet;
  const ThemChiTietScreen({super.key, this.danhMuc, this.chiTiet});

  @override
  State<ThemChiTietScreen> createState() => _ThemChiTietScreenState();
}

class _ThemChiTietScreenState extends State<ThemChiTietScreen> {
  final _soTienController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final FocusNode _soTienFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  int? _selectedDanhMucId;

  final ChiTietChiTieuDao _dao = ChiTietChiTieuDao();
  final DanhMucDao _dmDao = DanhMucDao();
  List<DanhMuc> _danhMucs = [];

  Future<void> loadDanhMucs() async {
    final all = await _dmDao.getDanhMucByLoai(1);
    final all2 = await _dmDao.getDanhMucByLoai(2);
    final danhMucs = [...all, ...all2];
    setState(() {
      _danhMucs = danhMucs;
      if (_danhMucs.isNotEmpty) {
        if (widget.danhMuc != null) {
          final found = _danhMucs.firstWhere(
            (e) => e.id == widget.danhMuc!.id,
            orElse: () => _danhMucs.first,
          );
          _selectedDanhMucId = found.id;
        } else {
          _selectedDanhMucId = _danhMucs.first.id;
        }
      }
    });
  }

  void _save() async {
    final ngay = _selectedDate;
    if (_selectedDanhMucId == null || _soTienController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn danh mục và nhập số tiền')),
      );
      return;
    }
    try {
      if (widget.chiTiet != null) {
        // Update
        final ct = ChiTietChiTieu(
          id: widget.chiTiet!.id,
          danhMucId: _selectedDanhMucId!,
          soTien: double.parse(_soTienController.text),
          ghiChu: _ghiChuController.text,
          ngay: ngay.toString().substring(0, 10),
        );
        await _dao.update(ct);
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false, // User must tap OK
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Thành công'),
                ],
              ),
              content: Text('Giao dịch đã được lưu thành công.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss dialog
                    Navigator.pop(context); // Pop screen
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Insert
        final ct = ChiTietChiTieu(
          danhMucId: _selectedDanhMucId!,
          soTien: double.parse(_soTienController.text),
          ghiChu: _ghiChuController.text,
          ngay: ngay.toString().substring(0, 10),
        );
        await _dao.insert(ct);
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false, // User must tap OK
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Thành công'),
                ],
              ),
              content: Text('Giao dịch đã được lưu thành công.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss dialog only
                  },
                ),
              ],
            );
          },
        );
        // Reset các trường nhập liệu (số tiền, ghi chú)
        setState(() {
          _soTienController.clear();
          _ghiChuController.clear();
          // _selectedDate giữ nguyên
          // _selectedDanhMucId giữ nguyên
        });

        _soTienFocusNode.requestFocus();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.chiTiet != null) {
      final soTien = widget.chiTiet!.soTien;
      _soTienController.text =
          soTien % 1 == 0 ? soTien.toInt().toString() : soTien.toString();
      _ghiChuController.text = widget.chiTiet!.ghiChu;
      _selectedDate = DateTime.tryParse(widget.chiTiet!.ngay) ?? DateTime.now();
      _selectedDanhMucId = widget.chiTiet!.danhMucId;
    }
    loadDanhMucs();
  }

  @override
  void dispose() {
    _soTienController.dispose();
    _ghiChuController.dispose();
    _soTienFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chiTiet != null ? "Chỉnh sửa Giao Dịch" : "Thêm Giao Dịch",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
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
                          'Thông tin giao dịch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedDanhMucId,
                          hint: Text('Chọn danh mục'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items:
                              _danhMucs
                                  .map(
                                    (e) => DropdownMenuItem<int>(
                                      value: e.id,
                                      child: Text('${e.icon} ${e.ten}'),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedDanhMucId = value),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _soTienController,
                          focusNode: _soTienFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: "Số tiền",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Số tiền không được để trống';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _ghiChuController,
                          decoration: InputDecoration(
                            labelText: "Ghi chú",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.note),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
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
                          'Ngày giao dịch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue.shade700,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _selectedDate.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ],
                            ),
                          ),
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
                      "Lưu giao dịch",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
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
        ),
      ),
    );
  }
}
