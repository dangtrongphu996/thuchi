import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'holiday.dart';

class AddEditHolidayScreen extends StatefulWidget {
  final Holiday? holiday;

  const AddEditHolidayScreen({super.key, this.holiday});

  @override
  _AddEditHolidayScreenState createState() => _AddEditHolidayScreenState();
}

class _AddEditHolidayScreenState extends State<AddEditHolidayScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.holiday?.name ?? '');
    _selectedDate = widget.holiday?.date ?? DateTime.now().toLocal();
    _imagePath = widget.holiday?.imagePath;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh từ camera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh từ thư viện: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.holiday == null ? 'Thêm ngày nghỉ' : 'Chỉnh sửa ngày nghỉ',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink[400],
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(),
                const SizedBox(height: 24),
                _buildDatePicker(),
                const SizedBox(height: 32),
                _buildImagePicker(context),
                const SizedBox(height: 24),
                _buildButtonRow(),
                const SizedBox(height: 40),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Tên ngày nghỉ',
          labelStyle: TextStyle(
            color: Colors.pink[400],
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(Icons.celebration, color: Colors.pink[400]),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Vui lòng nhập tên ngày nghỉ';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày nghỉ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.pink[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today, color: Colors.pink[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickImageFromGallery,
              child: _imagePath != null
                  ? Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 64,
                            color: Colors.pink[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Thêm hình ảnh',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink[400],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildIconButton(
            Icons.camera_alt,
            'Chụp hình',
            _pickImageFromCamera,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIconButton(
            Icons.photo_library,
            'Thư viện',
            _pickImageFromGallery,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink[400],
        elevation: 4,
        shadowColor: Colors.pink[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final holiday = Holiday(
              name: _nameController.text,
              date: _selectedDate,
              imagePath: _imagePath,
            );
            Navigator.pop(context, holiday);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[500],
          elevation: 4,
          shadowColor: Colors.green[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Lưu ngày nghỉ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
