import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';
import 'dart:math';
import 'package:thuchi/screens/vocabulary/screen/quiz_screen.dart';
import 'package:thuchi/screens/vocabulary/screen/vocabulary_search_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VocabularyListScreen extends StatefulWidget {
  final int characterId;
  final int sectionId;
  final String sectionName;
  final Color themeColor;

  const VocabularyListScreen({
    super.key,
    required this.characterId,
    required this.sectionId,
    required this.sectionName,
    this.themeColor = Colors.teal,
  });

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  late Future<List<Vocabulary>> _vocabularyFuture;
  final List<Color> _itemColors = [
    Colors.blue[600]!,
    Colors.green[600]!,
    Colors.red[500]!,
    Colors.orange[600]!,
    Colors.purple[400]!,
    Colors.teal[500]!,
    Colors.pink[400]!,
    Colors.amber[700]!,
  ];

  @override
  void initState() {
    super.initState();
    _vocabularyFuture = _loadAndFilterVocabulary();
  }

  Future<List<Vocabulary>> _loadAndFilterVocabulary() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/vocabulary_temp.json');
    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/data/vocabulary.json');
      await file.writeAsString(data);
    }
    final jsonString = await file.readAsString();
    final allVocabulary = vocabularyFromJson(jsonString);
    return allVocabulary
        .where(
          (v) =>
              v.character == widget.characterId &&
              v.section == widget.sectionId,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sectionName,
          style: TextStyle(
            color: Colors.white,
            fontSize:
                widget.sectionName.length > 30
                    ? 10
                    : widget.sectionName.length > 25
                    ? 13
                    : widget.sectionName.length > 15
                    ? 15
                    : 18,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: widget.themeColor,
        actions: [
          IconButton(
            icon: Icon(Icons.quiz, color: Colors.white),
            tooltip: 'Test trắc nghiệm',
            onPressed: () async {
              final mode = await showDialog<String>(
                context: context,
                builder:
                    (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz,
                                  color: Colors.indigo,
                                  size: 32,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Chọn chế độ trắc nghiệm',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            _buildQuizModeButton(
                              context,
                              mode: 'kanji',
                              title: 'Kanji → Hiragana',
                              icon: Icons.translate,
                              color: Colors.teal,
                              description: 'Chọn Hiragana đúng cho từ Kanji',
                            ),
                            SizedBox(height: 12),
                            _buildQuizModeButton(
                              context,
                              mode: 'hiragana',
                              title: 'Hiragana → Kanji',
                              icon: Icons.spellcheck,
                              color: Colors.orange,
                              description: 'Chọn Kanji đúng cho Hiragana',
                            ),
                            SizedBox(height: 12),
                            _buildQuizModeButton(
                              context,
                              mode: 'kanji_meaning',
                              title: 'Kanji → Từ vựng',
                              icon: Icons.menu_book,
                              color: Colors.purple,
                              description:
                                  'Chọn nghĩa tiếng Việt đúng cho Kanji',
                            ),
                          ],
                        ),
                      ),
                    ),
              );
              if (mode != null) {
                // Lấy toàn bộ từ vựng đang hiển thị
                final vocabList = await _vocabularyFuture;
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QuizScreen(
                          mode: mode,
                          questionCount: vocabList.length,
                          character: widget.characterId,
                          section: widget.sectionId,
                        ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            tooltip: 'Tìm kiếm từ vựng',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VocabularySearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Vocabulary>>(
        future: _vocabularyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có từ vựng nào trong mục này.'),
            );
          }

          final vocabularyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: vocabularyList.length,
            itemBuilder: (context, index) {
              final vocab = vocabularyList[index];
              final itemColor = _itemColors[index % _itemColors.length];
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    vocab.kanji,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: itemColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vocab.hiragana,
                        style: TextStyle(
                          color:
                              _itemColors[Random(
                                vocab.kanji.hashCode,
                              ).nextInt(_itemColors.length)],
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        vocab.mean,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showExampleDialog(context, vocab, itemColor);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showExampleDialog(
    BuildContext context,
    Vocabulary vocab,
    Color itemColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            vocab.kanji == vocab.hiragana
                ? vocab.kanji
                : vocab.kanji + '\n' + vocab.hiragana,
            style: TextStyle(
              color: itemColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              vocab.example.replaceAll('。', '。\n'),
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Đóng', style: TextStyle(color: itemColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizModeButton(
    BuildContext context, {
    required String mode,
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => Navigator.pop(context, mode),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
