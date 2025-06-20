import 'package:flutter/material.dart';
import 'package:thuchi/screens/docsach/entity/book.dart';
import 'package:thuchi/screens/docsach/entity/screen/chapter_list.dart';

class ListBookScreen extends StatelessWidget {
  final List<Book> books;

  const ListBookScreen({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Books',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 'Books'.length > 20 ? 16 : 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color:
              Colors
                  .white, // Màu cho icon trở lại hoặc các icon khác trên AppBar
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Số cột trong grid
            crossAxisSpacing: 2.0, // Khoảng cách ngang giữa các phần tử
            mainAxisSpacing: 2.0, // Khoảng cách dọc giữa các phần tử
            childAspectRatio:
                0.65, // Điều chỉnh tỉ lệ giữa chiều rộng và chiều cao
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterListPage(book: book),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        book.coverImage,
                        width: double.infinity * 0.5,
                        height: 130, // Giảm chiều cao của hình ảnh
                        fit: BoxFit.fill,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ), // Giảm khoảng cách giữa hình và chữ
                      child: Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
