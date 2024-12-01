import 'package:boonote/ui/save_memo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../models/books.dart';
import 'book_detail/book_modal.dart';

class SavedBook extends StatefulWidget {
  final Item book;
  final String bookId;

  const SavedBook({Key? key, required this.book, required this.bookId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SavedBook();
}

class _SavedBook extends State<SavedBook> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser?.uid ?? '없다';
    Stream<QuerySnapshot> fetchMemos(String bookId) {
      return FirebaseFirestore.instance
          .collection('books_memo')
          .where('user_id', isEqualTo: currentUser)
          .where('book_id', isEqualTo: bookId)
          .orderBy('create_date', descending: true)
          .snapshots();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: const Color(0xFFFCFCFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCFCFC),
            title: Text(widget.book.title),
            actions: [
              // 수정
              IconButton(
                onPressed: () async {
                  _openEditModal(widget.bookId);
                },
                icon: Icon(Icons.edit),
              ),
              // 삭제
              IconButton(
                onPressed: () => _openDelete(widget.bookId),
                icon: Icon(Icons.delete),
              )
            ],
            bottom: const TabBar(
              indicatorColor: Colors.red,
              tabs: [
                Tab(
                  text: '정보',
                ),
                Tab(
                  text: '메모',
                )
              ],
            ),
          ),
          body: TabBarView(children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 책 제목
                    Center(
                        child: Text(
                      '${widget.book.title}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Chosun'),
                    )),
                    const SizedBox(height: 20),
                    // 책 이미지
                    Center(
                      child: widget.book.image.isNotEmpty
                          ? Image.network(widget.book.image,
                              height: 300, fit: BoxFit.cover)
                          : const Icon(Icons.book, size: 100),
                    ),
                    const SizedBox(height: 16),
                    // 작가
                    Center(
                        child: Text('${widget.book.author}',
                            style: const TextStyle(fontSize: 15))),
                    const SizedBox(height: 10),

                    // 시작 / 종료 or 목표 달성 여부
                    Text(
                      widget.book.bookStatus == '읽은 책' ? '독서 기간' : '목표 달성 기간',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(getBookDateInfo(widget.book)),
                    const SizedBox(height: 16),

                    // 출판사
                    Text(
                      '출판사',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text('${widget.book.publisher}'),
                    const SizedBox(height: 16),

                    Text(
                      '출판일',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.book.pubdate != null &&
                              widget.book.pubdate.length >= 6
                          ? '${widget.book.pubdate.substring(0, 4)}년 ${widget.book.pubdate.substring(4, 6)}월'
                          : '출판일 없어요',
                    ),
                    const SizedBox(height: 16),

                    // isbn
                    Text(
                      'ISBN',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text('${widget.book.isbn}'),
                    const SizedBox(height: 16),

                    // 책 설명
                    Text(
                      '책 소개',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.book.description),
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: fetchMemos(widget.bookId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0, top: 10),
                      // 버튼과 메모 리스트 간격
                      child: Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                                fontSize: 13, fontFamily: 'Chosun'), // 텍스트 스타일
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 네모난 버튼
                            ),
                          ),
                          onPressed: () {
                            _openMemo(widget.bookId); // 메모 등록 버튼
                          },
                          child: const Text('메모 등록'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                      const Center(
                        child: Text(
                          '메모를 등록해보세요!',
                          style: TextStyle(fontSize: 14, fontFamily: 'Chosun'),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final memoId = snapshot.data!.docs[index];
                              final memo = snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                              return TextButton(
                                  onPressed: (){
                                    _openEditMemo(memoId.id, memo['memo']);
                                  },
                                  child: ListTile(
                                    title: Text(
                                      memo['memo'] ?? '메모 없음',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      '${memo['create_date'].toDate().year}년 ${memo['create_date'].toDate().month}월 ${memo['create_date'].toDate().day}일'
                                          ' ${memo['create_date'].toDate().hour}시 ${memo['create_date'].toDate().minute}분',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                              );
                            }),
                      )
                  ],
                );
              },
            )
          ])),
    );
  }

  // 만들어둔 book_modal에 값 전달 -> 수정
  Future<void> _openEditModal(String bookId) async {
    final bookSnapshot =
        await FirebaseFirestore.instance.collection('books').doc(bookId).get();

    if (bookSnapshot.exists) {
      final bookData = bookSnapshot.data();

      final result = await Get.dialog<Map<String, dynamic>>(
        BookModal(
          selectedStatus: bookData?['book_status'],
          startDate: (bookData?['start_date'] as Timestamp?)?.toDate(),
          endDate: (bookData?['end_date'] as Timestamp?)?.toDate(),
          goalDate: (bookData?['goal_date'] as Timestamp?)?.toDate(),
          starRating: bookData?['star']?.toDouble() ?? 0,
        ),
      );

      // FieldValue.delete() 값 삭제
      if (result != null) {
        final updatedData = {
          'book_status': result['status'] ?? bookData?['book_status'],
          'start_date': result['status'] == '읽고 있는 책'
              ? FieldValue.delete()
              : result['startDate'] ?? bookData?['start_date'],
          'end_date': result['status'] == '읽고 있는 책'
              ? FieldValue.delete()
              : result['endDate'] ?? bookData?['end_date'],
          'goal_date': result['goalDate'] ?? bookData?['goal_date'],
          'star': result['rating'] ?? bookData?['star']
        };
        print('결과: $result');
        print('업데이트: $updatedData');

        // 수정된 데이터 저장
        await FirebaseFirestore.instance
            .collection('books')
            .doc(bookId)
            .update(updatedData);
        Get.snackbar('수정 완료', '책 정보를 수정했습니다.');
      }
    } else {
      Get.snackbar('오류', '수정 안됨.');
    }
  }

  // 메모 수정
  void _openEditMemo(String memoId, String existingMemo) async{
    // 기존 데이터 전달
    final updateMemo = await Get.to(() => SaveMemo(memoId: memoId, memo: existingMemo, bookId: widget.bookId,));

    if(updateMemo != null){
      // 업데이트
      try{
        await FirebaseFirestore
            .instance
            .collection('books_memo')
            .doc(memoId)
            .update({'memo':updateMemo});

        Get.snackbar('수정 완료', '메모가 수정 됐습니다.');
      }catch(e){
        Get.snackbar('수정 실패', '메모를 수정하지 못했습니다.');
      }
    }
  }

  // 독서 기간 / 목표일 계산
  String getBookDateInfo(Item book) {
    if (book.bookStatus == '읽은 책') {
      if (book.startDate != null && book.endDate != null) {
        // 독서 기간 표시
        return '${book.startDate.toDate().year}년 ${book.startDate.toDate().month}월 ${book.startDate.toDate().day}일 ~ '
            '${book.endDate.toDate().year}년 ${book.endDate.toDate().month}월 ${book.endDate.toDate().day}일';
      } else {
        return '등록일 없음';
      }
    } else if (book.bookStatus == '읽고 있는 책') {
      if (book.goalDate != null) {
        // 목표 달성 기간 계산
        return calculateDDay(book.goalDate.toDate());
      } else {
        return '목표 완료를 위해 노력 중';
      }
    }
    return '정보 없음';
  }

  // 목표일 D-day 표시
  String calculateDDay(DateTime goalDate) {
    final now = DateTime.now();
    final difference = goalDate.difference(now).inDays;

    if (difference > 0) {
      return 'D-${difference}'; // 목표 날짜까지 남은 일 수
    } else if (difference == 0) {
      return 'D-Day'; // 오늘이 목표 날짜인 경우
    } else {
      return 'D+${difference.abs()}'; // 목표 날짜를 지난 경우
    }
  }

  // 책 삭제
  void _openDelete(String bookId) async{
    await FirebaseFirestore.instance
        .collection('books')
        .doc(bookId)
        .delete();
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.snackbar('삭제 완료', '삭제되었습니다.');
    });
    Get.back();
  }


  void _openMemo(String bookId, {String? memoId, String? memo}) async {
    Get.to(() => SaveMemo(
      bookId: bookId,
      memoId: memoId, // 새 메모는 null
      memo: memo,    // 새 메모는 null
    ));
  }
}
