import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:thuchi/screens/vocabulary/models/character_structure.dart';
import 'package:thuchi/screens/vocabulary/screen/vocabulary_list_screen.dart';

class CharacterSectionScreen extends StatefulWidget {
  const CharacterSectionScreen({super.key});

  @override
  State<CharacterSectionScreen> createState() => _CharacterSectionScreenState();
}

class _CharacterSectionScreenState extends State<CharacterSectionScreen> {
  late Future<List<CharacterStructure>> _characterStructureFuture;
  final List<Color> _characterColors = [
    Colors.blue[400]!,
    Colors.green[400]!,
    Colors.orange[400]!,
    Colors.purple[400]!,
    Colors.red[400]!,
    Colors.teal[400]!,
  ];

  @override
  void initState() {
    super.initState();
    _characterStructureFuture = _loadStructure();
  }

  Future<List<CharacterStructure>> _loadStructure() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/structure.json',
    );
    return characterStructureFromJson(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh mục từ vựng',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<CharacterStructure>>(
        future: _characterStructureFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không tìm thấy dữ liệu.'));
          }

          final characters = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  characters.asMap().entries.map((entry) {
                    int idx = entry.key;
                    CharacterStructure character = entry.value;
                    final color =
                        _characterColors[idx % _characterColors.length];

                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.only(bottom: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: color, width: 8.0),
                            ),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: Text(
                              'Character ${character.character}',
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: _buildSections(
                                  character.sections,
                                  color,
                                  character.character,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSections(
    List<Section> sections,
    Color characterColor,
    int characterId,
  ) {
    return Column(
      children:
          sections.map((section) {
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: characterColor.withOpacity(0.1),
                  child: Text(
                    section.section.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: characterColor,
                    ),
                  ),
                ),
                title: Text(
                  section.name,
                  style: const TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VocabularyListScreen(
                            characterId: characterId,
                            sectionId: section.section,
                            sectionName: section.name,
                            themeColor: characterColor,
                          ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
    );
  }
}
