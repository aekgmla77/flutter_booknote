import 'package:get/get.dart';

import '../models/books.dart';
import '../service/service_api.dart';

class SearchController extends GetxController{
  final BookApiService  bookApiService = BookApiService();
  var books = <Item>[].obs; // 검색 결과 리스트
  var isLoading = false.obs;

  // 검색 함수
  Future<void> searchBooks(String query) async{
    isLoading.value = true;
    try{
      final results = await bookApiService.searchBooks(query);
      books.value = results.map((data) => Item.fromJson(data)).toList();
      print('검색 결과 데이터: ${books.value}');
    }catch(e){
      print('검색 중 에러 발생: $e');
    }finally{
      isLoading.value = false;
    }
  }
  //
  // // 모든 items를 추출하여 하나의 리스트로 반환
  // List<Item> get allItems {
  //   return books.expand((book) => book.items).toList();
  // }
}