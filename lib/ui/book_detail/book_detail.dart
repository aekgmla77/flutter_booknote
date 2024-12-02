import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../models/books.dart';
import 'book_modal.dart';

// StatefulWidget(less - 정적 / ful - 상태가 변하는 클래스)
class BookDetail extends StatefulWidget {
  final Item book; // book 객체를 받을 필드 추가

  const BookDetail({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetail> createState() => _BookDetailState();

}

class _BookDetailState extends State<BookDetail> {

  void _openModal() async {
    final result = await Get.dialog<Map<String, dynamic>>(
      BookModal(
        selectedStatus: null,
        startDate: null,
        endDate: null,
        goalDate: null,
        starRating: 0,
      ),
    );

    if (result != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown user';
      final Item book = widget.book;

      // Firebase에 저장
      await saveBook(
        userId: userId,
        isbn: book.isbn,
        title: book.title,
        author: book.author,
        image: book.image,
        publisher: book.publisher,
        pubdate: book.pubdate,
        description: book.description,
        bookStatus: result['status'] ?? 'unknown',
        startDate: result['startDate'],
        endDate: result['endDate'],
        goalDate: result['goalDate'],
        star: result['rating'],
      );
    }
  }

  // firebase 데이터 저장 함수
  Future<void> saveBook({
    required String userId,
    required String isbn,
    required String title,
    required String author,
    required String image,
    required String publisher,
    required String pubdate,
    required String description,
    required String bookStatus,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? goalDate,
    required double star
  }) async {
    final Map<String, dynamic> bookData = {
      "user_id": userId,
      "isbn": isbn,
      "title": title,
      "author": author,
      "image": image,
      "publisher": publisher,
      "pubdate": pubdate,
      "description": description,
      "book_status": bookStatus,
      "create_date": FieldValue.serverTimestamp(),
    };

    if (bookStatus == "읽은 책") {
      bookData["start_date"] = startDate;
      bookData["end_date"] = endDate;
      bookData["star"] = star;
    } else if (bookStatus == "읽고 있는 책") {
      bookData["goal_date"] = goalDate;
    }

    // 데이터 저장 로직 실행
    try {
      // Firebase Firestore에 데이터 저장
      await FirebaseFirestore.instance.collection("books").add(bookData);

      // 로딩 스피너 닫기 (GetX 사용)
      Get.back();

      // 저장 성공 알림창
      Get.dialog(
        AlertDialog(
          title: const Text("저장 완료"),
          content: const Text("책 정보를 성공적으로 저장했습니다!"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // 알림창 닫기
              },
              child: const Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      // 로딩 스피너 닫기 (GetX 사용)
      Get.back();

      // 저장 실패 알림창
      Get.dialog(
        AlertDialog(
          title: const Text("저장 실패"),
          content: Text("책 정보를 저장하지 못했습니다. 오류: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // 알림창 닫기
              },
              child: const Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // BookDetail의 book에 접근
    final Item book = widget.book;
    return Scaffold(
        backgroundColor: const Color(0xFFFCFCFC),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 저장 버튼
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        onPressed: _openModal,
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(40, 30),
                            textStyle: const TextStyle(fontSize: 12),
                            side: BorderSide(
                                color: Colors.black38
                            )
                        ),
                        child: Text("책 등록하기", style: const TextStyle(color: Colors.indigo),)),
                  ],
                ),
                // 책 제목
                Center(
                    child: Text(
                      '${book.title}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    )),
                const SizedBox(height: 20),
                // 책 이미지
                Center(
                  child: book.image.isNotEmpty ?
                  Image.network(book.image, height: 300, fit: BoxFit.cover)
                      : const Icon(Icons.book, size: 100)
                  ,
                ),
                const SizedBox(height: 16),
                // 작가
                Center(child: Text('${book.author}', style: const TextStyle(fontSize: 15))),
                const SizedBox(height: 10),

                // 출판사
                Text('출판사', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Text('${book.publisher}'),
                const SizedBox(height: 16),

                Text('출판일', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Text('${book.pubdate.substring(0, 4)}년 ${book.pubdate.substring(4, 6)}월'),
                const SizedBox(height: 16),
                // 책 설명
                Text(
                  '책 소개',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(book.description),
              ],
            ),
          ),
        )

    );
  }
}

