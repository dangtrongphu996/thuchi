import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class EditVocabularyScreen extends StatefulWidget {
  final Map<String, dynamic> vocabulary;
  final int index;
  final VoidCallback? onUpdated;

  const EditVocabularyScreen({
    Key? key,
    required this.vocabulary,
    required this.index,
    this.onUpdated,
  }) : super(key: key);

  @override
  _EditVocabularyScreenState createState() => _EditVocabularyScreenState();
}

class _EditVocabularyScreenState extends State<EditVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kanjiController;
  late TextEditingController _hiraganaController;
  late TextEditingController _meanController;
  late TextEditingController _exampleController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kanjiController = TextEditingController(
      text: widget.vocabulary['kanji'] ?? '',
    );
    _hiraganaController = TextEditingController(
      text: widget.vocabulary['hiragana'] ?? '',
    );
    _meanController = TextEditingController(
      text: widget.vocabulary['mean'] ?? '',
    );
    _exampleController = TextEditingController(
      text: widget.vocabulary['example'] ?? '',
    );
  }

  Future<String> _getLocalVocabularyPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/vocabulary_temp.json';
  }

  Future<File> _getLocalVocabularyFile() async {
    final path = await _getLocalVocabularyPath();
    final file = File(path);
    if (!await file.exists()) {
      // Copy from assets if not exists
      final data = await rootBundle.loadString('assets/data/vocabulary.json');
      await file.writeAsString(data);
    }
    return file;
  }

  Future<void> _updateVocabulary() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final file = await _getLocalVocabularyFile();
      final String data = await file.readAsString();
      List<dynamic> jsonData = json.decode(data);
      if (widget.index < 0 || widget.index >= jsonData.length) {
        throw Exception('Index không hợp lệ');
      }
      jsonData[widget.index] = {
        ...jsonData[widget.index],
        'kanji': _kanjiController.text,
        'hiragana': _hiraganaController.text,
        'mean': _meanController.text,
        'example': _exampleController.text,
      };
      await file.writeAsString(json.encode(jsonData));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật từ vựng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      if (widget.onUpdated != null) widget.onUpdated!();
      Navigator.of(context).pop();
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
        title: Text('Chỉnh sửa từ vựng', style: TextStyle(color: Colors.white)),
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
                        onPressed: _updateVocabulary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Lưu thay đổi',
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
