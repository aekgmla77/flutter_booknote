import 'dart:convert';

import 'package:http/http.dart' as http;

class BookApiService{
  final String URL = "https://openapi.naver.com/v1/search/book.json";
  final String clienttId = "v14xZMH6gIoSy2pQjok3";
  final String clientKey = "hfW9Jgk5QF";

  Future<List<Map<String, dynamic>>> searchBooks(String query) async{
    try{
      final response = await http.get(
        Uri.parse('$URL?query=$query&display=100'),
        headers: {
          'X-Naver-Client-Id' : clienttId,
          'X-Naver-Client-Secret' : clientKey,
        },
      );

      if(response.statusCode == 200){
        // JSON 데이터 파싱
        final data = json.decode(response.body);
        print('API 호출 성공: ${response.body}');

        if(data['items'] == null){
          print('items null');
          return [];
        }
        return List<Map<String, dynamic>>.from(data['items']);
      }else{
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    }catch(e){
      print('API 호출 에러: $e');
      throw Exception('API 호출 실패');
    }
  }
}