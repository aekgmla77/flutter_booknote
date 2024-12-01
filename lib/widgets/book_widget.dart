import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/books.dart';
import '../ui/book_detail/book_detail.dart';

class BookListView extends StatelessWidget {

  final List<Item> books;

  const BookListView({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // recycle view처럼 사용하는
    return
      ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          color: const Color(0xFFFCFCFC),
          margin: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 2.0),
          child: ListTile(
            title: Text(
              book.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            leading: book.image.isNotEmpty
                ? Image.network(book.image, width: 50, fit: BoxFit.cover)
                : const Icon(Icons.book),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('저자: ${book.author}'),
                Text('출판사: ${book.publisher}'),
                Text('출판일: ${book.pubdate.substring(0, 4)}년 ${book.pubdate.substring(4, 6)}월'),
              ],
            ),
            onTap: () {
              Get.to(() => BookDetail(book: book)); // book 객체 전달
              print('Selected Book: ${book.title}');
            },
          ),
        );
      },
    );
  }
}
