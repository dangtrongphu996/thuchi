import 'package:flutter/material.dart';
import 'package:thuchi/screens/vocabulary/screen/quiz_screen.dart';
import 'package:thuchi/screens/vocabulary/screen/add_vocabulary_screen.dart';
import 'package:thuchi/screens/vocabulary/screen/character_section_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int selectedQuestionCount = 10;
  final List<int> questionCounts = [10, 20, 50, 100];

  int? selectedCharacter;
  final List<int?> characters = [null, 1, 2];

  int? selectedSection;
  final Map<int, List<int?>> sectionsByCharacter = {
    1: [null, 1, 2, 3, 4, 5],
    2: [null, 1, 2],
  };
  List<int?> availableSections = [null];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Chọn chế độ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Danh mục',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CharacterSectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFF6F7FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddVocabularyScreen()),
            ),
        backgroundColor: Colors.indigo,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Thêm từ vựng', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDropdownRow<int>(
                    label: 'Số câu hỏi:',
                    value: selectedQuestionCount,
                    items: questionCounts,
                    onChanged: (val) {
                      setState(() => selectedQuestionCount = val!);
                    },
                    itemTextBuilder: (val) => '$val câu',
                  ),
                  Divider(height: 1),
                  _buildDropdownRow<int?>(
                    label: 'Bài:',
                    value: selectedCharacter,
                    items: characters,
                    onChanged: (val) {
                      setState(() {
                        selectedCharacter = val;
                        selectedSection = null;
                        availableSections =
                            val == null ? [null] : sectionsByCharacter[val]!;
                      });
                    },
                    itemTextBuilder:
                        (val) => val == null ? 'Tất cả' : 'Bài $val',
                  ),
                  Divider(height: 1),
                  _buildDropdownRow<int?>(
                    label: 'Section:',
                    value: selectedSection,
                    items: availableSections,
                    onChanged:
                        selectedCharacter == null
                            ? null // Disable if no character is selected
                            : (val) {
                              setState(() => selectedSection = val);
                            },
                    itemTextBuilder:
                        (val) => val == null ? 'Tất cả' : 'Section $val',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kanji → Hiragana',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => QuizScreen(
                            mode: 'kanji',
                            questionCount: selectedQuestionCount,
                            character: selectedCharacter,
                            section: selectedSection,
                          ),
                    ),
                  ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hiragana → Kanji',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => QuizScreen(
                            mode: 'hiragana',
                            questionCount: selectedQuestionCount,
                            character: selectedCharacter,
                            section: selectedSection,
                          ),
                    ),
                  ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kanji → Nghĩa',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => QuizScreen(
                            mode: 'kanji_meaning',
                            questionCount: selectedQuestionCount,
                            character: selectedCharacter,
                            section: selectedSection,
                          ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?)? onChanged,
    required String Function(T) itemTextBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          DropdownButton<T>(
            value: value,
            items:
                items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemTextBuilder(item)),
                  );
                }).toList(),
            onChanged: onChanged,
            underline: Container(),
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
