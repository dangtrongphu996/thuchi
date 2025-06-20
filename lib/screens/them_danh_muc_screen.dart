import 'package:flutter/material.dart';
import '../db/danh_muc_dao.dart';
import '../models/danh_muc.dart';

class ThemDanhMucScreen extends StatefulWidget {
  final int loai;
  final DanhMuc? danhMuc;

  const ThemDanhMucScreen({super.key, required this.loai, this.danhMuc});

  @override
  State<ThemDanhMucScreen> createState() => _ThemDanhMucScreenState();
}

class _ThemDanhMucScreenState extends State<ThemDanhMucScreen> {
  final _tenController = TextEditingController();
  String _selectedIcon = '💰';
  final DanhMucDao _dao = DanhMucDao();
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> iconOptions = [
    '💰', '💵', '💸', '💳', '🏦', '🧾', // Tiền tệ
    '🍔', '🍕', '🍜', '🍱', '🍎', '🥗', // Đồ ăn
    '🛒', '🛍️', '🎁', '👔', '👗', // Mua sắm
    '🎉', '🎊', '🎭', '🎨', // Giải trí
    '🚗', '✈️', '🚌', '🚲', '⛽', // Di chuyển & Nhiên liệu
    '📚', '💻', '📱', '🎓', // Học tập
    '🏠', '🏢', '🏡', // Nhà cửa
    '🏥', '💊', '🏋️', '🧘', '⚕️', // Sức khỏe
    '👕', '👖', '👗', '👟', // Quần áo
    '🐶', '🐱', '🐠', // Thú cưng
    '🌳', '🌺', '🌵', // Cây cối
    '⚡', '💧', '🔥', // Tiện ích
    '📱', '📞', '💻', // Điện tử
    '🔧', '🔩', '🔨', // Sửa chữa
    '📚', '📰', '📖', // Sách báo
    '✈️', '🏨', // Du lịch
  ];

  @override
  void initState() {
    super.initState();
    if (widget.danhMuc != null) {
      _isEditing = true;
      _tenController.text = widget.danhMuc!.ten;
      _selectedIcon = widget.danhMuc!.icon ?? iconOptions.first;
    }
  }

  void _saveDanhMuc() async {
    if (_formKey.currentState!.validate()) {
      final dm = DanhMuc(
        id: _isEditing ? widget.danhMuc!.id : null,
        ten: _tenController.text.trim(),
        icon: _selectedIcon,
        loai: widget.loai,
      );
      if (_isEditing) {
        await _dao.updateDanhMuc(dm);
      } else {
        await _dao.insertDanhMuc(dm);
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Chỉnh sửa danh mục ' +
                  (widget.loai == 1 ? '(Thu nhập)' : '(Chi phí)')
              : 'Thêm danh mục ' +
                  (widget.loai == 1 ? '(Thu nhập)' : '(Chi phí)'),
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
            child: Form(
              key: _formKey,
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
                            'Thông tin danh mục',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _tenController,
                            decoration: InputDecoration(
                              labelText: 'Tên danh mục',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.category),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tên danh mục không được để trống';
                              }
                              return null;
                            },
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
                            'Chọn biểu tượng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  iconOptions.map((icon) {
                                    return GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => _selectedIcon = icon,
                                          ),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedIcon == icon
                                                  ? Colors.blue.shade100
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                _selectedIcon == icon
                                                    ? Colors.blue.shade700
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          icon,
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _saveDanhMuc,
                      icon: Icon(Icons.save),
                      label: Text(
                        _isEditing ? 'Cập nhật danh mục' : 'Lưu danh mục',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
