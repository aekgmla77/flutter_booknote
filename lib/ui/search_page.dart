import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart' as search;
import '../widgets/book_widget.dart'; // BookWidget 가져오기

class SearchPage extends StatelessWidget {
  final search.SearchController _searchController = Get.put(search.SearchController());
  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        title: const Text('찾으시는 책을 검색하세요'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색어 입력 필드
            TextField(
              // enter 키 누르면 검색
              textInputAction: TextInputAction.done,
              controller: _searchTextController,
              onSubmitted: (query){
                final trimmedQuery = query.trim();
                if(trimmedQuery.isNotEmpty){
                  _searchController.searchBooks(trimmedQuery);
                }else{
                  print("검색어가 비었어요");
                }
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _searchTextController.text.trim();
                    print('TextField 값: $query'); // 입력값 확인
                    // 검색 수행
                    _searchController.searchBooks(query);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 검색 결과 표시
            Expanded(
              child: Obx(() {
                if (_searchController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.books.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }

                // BookWidget을 사용해 검색 결과 표시
                return BookListView(books: _searchController.books);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
