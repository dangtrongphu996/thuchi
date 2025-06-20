import 'package:flutter/material.dart';
import 'package:thuchi/screens/docsach/entity/book.dart';
import 'package:thuchi/screens/docsach/entity/screen/chapter_list.dart';

class ListBookListViewScreen extends StatelessWidget {
  final List<Book> books;

  const ListBookListViewScreen({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Books',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap:
                  true, // Điều này giúp ListView tự động co dãn theo chiều cao của nó
              physics:
                  const NeverScrollableScrollPhysics(), // Vô hiệu hoá cuộn bên trong ListView
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          book.coverImage,
                          width: 60,
                          height: 120,
                          fit: BoxFit.fill,
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: TextStyle(
                          fontSize: book.title.length > 18 ? 14 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChapterListPage(book: book),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
