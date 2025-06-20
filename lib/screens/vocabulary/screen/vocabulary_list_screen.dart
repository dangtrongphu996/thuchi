import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';
import 'dart:math';

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
    final jsonString = await rootBundle.loadString(
      'assets/data/vocabulary.json',
    );
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
                widget.sectionName.length > 25
                    ? 13
                    : widget.sectionName.length > 15
                    ? 15
                    : 18,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: widget.themeColor,
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
}
