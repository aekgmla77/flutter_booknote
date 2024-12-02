import 'package:boonote/ui/login.dart';
import 'package:boonote/ui/saved_book.dart';
import 'package:boonote/ui/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../models/books.dart';

class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 개수
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFCFC),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.to(SearchPage()),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        '책 검색하기',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

            ],
          ),

          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            tabs: [
              Tab(text: '읽은 책'),
              Tab(text: '읽고 있는 책'),
            ],
          ),
        ),
        body:
        const TabBarView(
          children: [
            BookGridView(bookStatus: '읽은 책'),
            BookGridView(bookStatus: '읽고 있는 책'),
        ],
        ),
      ),
    );
  }
}

class BookGridView extends StatelessWidget{
  final String bookStatus;

  const BookGridView({Key? key, required this.bookStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser == null){
      print("로그인 없다");
      Get.to(LoginPage());
    }else{
      print('현재 로그인한 사용자 UID: ${currentUser.uid}');
    }

    return FutureBuilder<QuerySnapshot>(
      // firebase에서 불러오기
      future: FirebaseFirestore.instance
          .collection('books')
          .where('user_id', isEqualTo: currentUser?.uid)
          .where('book_status', isEqualTo: bookStatus)
          .orderBy('create_date', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: EmptyStatePage(
              title: "텅텅 빈 서재예요 😢",
              description: "책을 검색 -> 추가해 주세요!📚📖",
            ),
          );
        }

        final books = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 한 줄에 3개
              crossAxisSpacing: 4.0, // 가로 간격
              mainAxisSpacing: 4.0, // 세로 간격
              childAspectRatio: 0.5, // 아이템 비율 (가로 대비 세로)
            ),
            itemCount: books.length > 13 ? 13 : books.length, // 최대 15개
            itemBuilder: (context, index) {
              final book = books[index].data() as Map<String, dynamic>;

              final bookSave = Item.fromJson(book);

              return GestureDetector(
                onTap: (){
                  Get.to(() => SavedBook(book: bookSave, bookId: books[index].id));
                },
              child: Column(
                children: [
                  // 책 이미지
                  book['image'] != null && book['image'] is String && book['image'].isNotEmpty
                      ? Image.network(
                    book['image'],
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                      : const Icon(
                    Icons.book,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  // 책 제목
                  Text(
                    book['title'] ?? '제목 없음',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // 작가
                  Text(
                    book['author'] ?? '작가 미상',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  // 별점
                  book['book_status'] == '읽은 책' ?
                  RatingBarIndicator(
                      rating: book['star'],
                      itemCount: 5,
                      itemSize: 10,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amberAccent,
                      )
                  ) : const Text('책을 읽고 별점을 등록하세요!', style: const TextStyle(fontSize: 10),),
                  // 생성일
                  Text(
                    '${book['create_date'].toDate().year}년 ${book['create_date'].toDate().month}월 ${book['create_date'].toDate().day}일 ' ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
                )
              );
            },
          ),
        );
      },
    );
  }
}

// 연도별 데이터 불러오기(드롭다운 기능)
// Map<int, List<DocumentSnapshot>> groupBooks(List<DocumentSnapshot> books) {
//   final Map<int, List<DocumentSnapshot>> groupedBooks = {};
//
//   for (var book in books) {
//     final createDate = (book['create_date'] as Timestamp?)?.toDate();
//     if (createDate != null) {
//       final year = createDate.year;
//
//       if (!groupedBooks.containsKey(year)) {
//         groupedBooks[year] = [];
//       }
//       groupedBooks[year]!.add(book);
//     }
//   }
//
//   return groupedBooks;
// }

// 책이 없을때
class EmptyStatePage extends StatelessWidget {
  final String title;
  final String description;

  const EmptyStatePage({
    required this.title,
    required this.description,
  });


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb, size: 80, color: Colors.yellow),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
