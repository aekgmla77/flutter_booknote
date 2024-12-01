import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SaveMemo extends StatefulWidget {
  final String? memo; // 전달받은 메모 값
  final String? memoId;
  final String bookId;

  SaveMemo({Key? key, this.memo, this.memoId, required this.bookId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SaveMemo();
}

class _SaveMemo extends State<SaveMemo> {
  late TextEditingController _memoController;

  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.memo);
  }

  @override
  Widget build(BuildContext context) {
    print('보자 ${widget.memoId}');

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        title: Text(widget.memoId == null ? '메모 등록' : '메모 수정'),
        actions: [
          IconButton(
            onPressed: () => _saveMemo(),
            icon: const Icon(Icons.save),
          ),
          if (widget.memo != null && widget.memo!.isNotEmpty)
            IconButton(
                onPressed: () => _memoDelete(widget.memoId!),
                icon: const Icon(Icons.restore_from_trash_outlined)),
        ],
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _memoController,
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            labelText: '메모를 입력하세요',
            border: OutlineInputBorder(),
            alignLabelWithHint: true, // 힌트를 상단에 맞춤
          ),
        ),
      ),
    );
  }

  // 책 삭제
  void _memoDelete(String memoId) async{
      await FirebaseFirestore.instance
          .collection('books_memo')
          .doc(memoId)
          .delete();
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar('삭제 완료', '삭제되었습니다.');
      });
      Get.back();
  }

  // 메모 저장
  Future<void> _saveMemo() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      Get.snackbar('오류', '로그인 정보가 없습니다.');
      return;
    }

    final memoData = {
      "user_id": userId,
      "book_id": widget.bookId,
      "memo": _memoController.text,
      "create_date": DateTime.now(),
    };

    try {
      if (widget.memoId == null) {
        // 새 메모 저장
        await FirebaseFirestore.instance.collection('books_memo').add(memoData);
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.snackbar('저장 완료', '메모가 등록되었습니다.');
        });
      } else {
        // 기존 메모 수정
        await FirebaseFirestore.instance
            .collection('books_memo')
            .doc(widget.memoId)
            .update(memoData);
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.snackbar('수정 완료', '메모가 수정되었습니다.');
        });
      }
      Get.back(); // 저장 후 페이지 닫기
    } catch (e) {
      Get.snackbar('오류', '저장에 실패했습니다: $e');
    }
  }
}
