import 'package:flutter/material.dart';
import 'package:thuchi/screens/vocabulary/screen/add_vocabulary_screen.dart';
import 'package:thuchi/screens/vocabulary/screen/vocabulary_search_screen.dart';
import 'package:thuchi/screens/vocabulary/screen/mode_selection_screen.dart';
import 'package:thuchi/screens/vocabulary/screen/character_section_screen.dart';
// TODO: import màn hình thêm từ vựng nếu có

class VocabularyMenuScreen extends StatelessWidget {
  const VocabularyMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chức năng từ vựng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.search,
            title: 'Tìm kiếm từ vựng',
            description: 'Tra cứu nhanh Kanji, Hiragana hoặc nghĩa tiếng Việt.',
            color: Colors.blue,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VocabularySearchScreen()),
                ),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.quiz,
            title: 'Trắc nghiệm từ vựng',
            description:
                'Luyện tập ghi nhớ từ vựng với nhiều chế độ trắc nghiệm.',
            color: Colors.orange,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ModeSelectionScreen()),
                ),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.list_alt,
            title: 'Danh mục từ vựng',
            description: 'Xem các nhóm từ vựng theo chủ đề, bài học.',
            color: Colors.teal,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CharacterSectionScreen()),
                ),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.add_circle_outline,
            title: 'Thêm từ vựng',
            description: 'Bổ sung từ vựng mới vào kho từ điển cá nhân.',
            color: Colors.green,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddVocabularyScreen()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: 28),
                radius: 28,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
