import 'package:cloud_firestore/cloud_firestore.dart';

class BookMemos {
  String? memoId;
  String? userId;
  String? bookId;
  String? memo;
  DateTime? createDate;

  BookMemos({this.memoId, this.userId, this.bookId, this.memo, this.createDate});

  BookMemos.fromJson(Map<String, dynamic> json){
    memoId = json['memo_id'];
    userId = json['user_id'];
    bookId = json['book_id'];
    memo = json['memo'];
    createDate = (json['create_date'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = {};
    data['memo_id'] = memoId;
    data['user_id'] = userId;
    data['book_id'] = bookId;
    data['memo'] = memo;
    data['create_date'] = createDate;
    return data;
  }
}
