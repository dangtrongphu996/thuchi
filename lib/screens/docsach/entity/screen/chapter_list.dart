import 'package:flutter/material.dart';
import 'package:thuchi/screens/docsach/entity/book.dart';
import 'package:thuchi/screens/docsach/entity/chapter.dart';
import 'package:thuchi/screens/docsach/entity/screen/pdf_view.dart';

class ChapterListPage extends StatelessWidget {
  final Book book;

  const ChapterListPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Nhóm các chương theo phần (ví dụ: theo số phần).
    final Map<String, List<Chapter>> groupedChapters = {
      for (var phan in book.phans) phan.title: phan.chapters,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: book.title.length > 20 ? 16 : 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color:
              Colors
                  .white, // Màu cho icon trở lại hoặc các icon khác trên AppBar
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children:
            groupedChapters.entries.map((entry) {
              String sectionTitle = entry.key;
              List<Chapter> chapters = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: ThemeData().copyWith(
                    dividerColor: Colors.transparent, // Ẩn đường gạch ngang
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    backgroundColor: Colors.deepOrange[50],
                    collapsedBackgroundColor: Colors.orange[100],
                    collapsedIconColor: Colors.deepOrange,
                    iconColor: Colors.deepOrange,
                    title: Text(
                      sectionTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange[900],
                      ),
                    ),
                    children:
                        chapters.map((chapter) {
                          return ListTile(
                            tileColor:
                                Colors.green[50], // Nền cho các chương con
                            title: Text(
                              chapter.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'Trang ${chapter.startPage} - ${chapter.endPage}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.green,
                              size: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LimitedPDFViewer(
                                        pdfPath: book.pdfPath,
                                        title: chapter.title,
                                        startPage: chapter.startPage,
                                        endPage: chapter.endPage,
                                      ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
