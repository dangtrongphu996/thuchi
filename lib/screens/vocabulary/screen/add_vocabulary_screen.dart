import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';
import 'package:flutter/services.dart';

class AddVocabularyScreen extends StatefulWidget {
  @override
  _AddVocabularyScreenState createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kanjiController = TextEditingController();
  final _hiraganaController = TextEditingController();
  final _meanController = TextEditingController();
  final _exampleController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveVocabulary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Đọc dữ liệu hiện tại
      final String data = await rootBundle.loadString(
        'assets/data/vocabulary.json',
      );
      List<dynamic> jsonData = json.decode(data);

      // Thêm từ mới
      jsonData.add({
        'kanji': _kanjiController.text,
        'hiragana': _hiraganaController.text,
        'mean': _meanController.text,
        'example': _exampleController.text,
      });

      // Lưu lại file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/vocabulary.json');
      await file.writeAsString(json.encode(jsonData));

      // Hiện thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm từ mới thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _kanjiController.clear();
      _hiraganaController.clear();
      _meanController.clear();
      _exampleController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm từ vựng', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _kanjiController,
                        label: 'Kanji',
                        validator:
                            (v) =>
                                v?.isEmpty == true
                                    ? 'Vui lòng nhập Kanji'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _hiraganaController,
                        label: 'Hiragana',
                        validator:
                            (v) =>
                                v?.isEmpty == true
                                    ? 'Vui lòng nhập Hiragana'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _meanController,
                        label: 'Nghĩa (tiếng Việt)',
                        validator:
                            (v) =>
                                v?.isEmpty == true
                                    ? 'Vui lòng nhập nghĩa'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _exampleController,
                        label: 'Ví dụ',
                        validator: null,
                        maxLines: 3,
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveVocabulary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Lưu từ vựng',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  @override
  void dispose() {
    _kanjiController.dispose();
    _hiraganaController.dispose();
    _meanController.dispose();
    _exampleController.dispose();
    super.dispose();
  }
}
