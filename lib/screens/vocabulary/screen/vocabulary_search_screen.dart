import 'package:flutter/material.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';
import 'package:thuchi/screens/vocabulary/utils/data_loader.dart' as loader;
import 'package:thuchi/screens/vocabulary/screen/edit_vocabulary_screen.dart';

class VocabularySearchScreen extends StatefulWidget {
  const VocabularySearchScreen({Key? key}) : super(key: key);

  @override
  State<VocabularySearchScreen> createState() => _VocabularySearchScreenState();
}

class _VocabularySearchScreenState extends State<VocabularySearchScreen> {
  List<Vocabulary> _allVocabulary = [];
  List<Vocabulary> _filteredVocabulary = [];
  TextEditingController _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    final list = await loader.loadVocabularyFromLocal();
    setState(() {
      _allVocabulary = list;
      _filteredVocabulary = list;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredVocabulary =
          _allVocabulary.where((v) {
            return v.kanji.toLowerCase().contains(q) ||
                v.hiragana.toLowerCase().contains(q) ||
                v.mean.toLowerCase().contains(q);
          }).toList();
    });
  }

  void _showDetailDialog(Vocabulary vocab) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              vocab.kanji == vocab.hiragana
                  ? vocab.kanji
                  : vocab.kanji + '\n' + vocab.hiragana,
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocab.mean,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    vocab.example.replaceAll('。', '。\n'),
                    style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Đóng', style: TextStyle(color: Colors.teal)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _openEditScreen(Vocabulary vocab) async {
    final index = _allVocabulary.indexWhere(
      (v) =>
          v.kanji == vocab.kanji &&
          v.hiragana == vocab.hiragana &&
          v.mean == vocab.mean &&
          v.example == vocab.example,
    );
    if (index == -1) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => EditVocabularyScreen(
              vocabulary: vocab.toJson(),
              index: index,
              onUpdated: _loadVocabulary,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Tìm kiếm từ vựng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Nhập Kanji, Hiragana hoặc nghĩa...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredVocabulary.isEmpty
                            ? const Center(
                              child: Text('Không tìm thấy từ vựng nào.'),
                            )
                            : ListView.builder(
                              itemCount: _filteredVocabulary.length,
                              itemBuilder: (context, index) {
                                final vocab = _filteredVocabulary[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      vocab.kanji,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.teal[700],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vocab.hiragana,
                                          style: TextStyle(
                                            color: Colors.teal[400],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          vocab.mean,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showDetailDialog(vocab),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () => _openEditScreen(vocab),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
