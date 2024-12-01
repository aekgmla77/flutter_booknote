import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

Books welcomeFromJson(String str) => Books.fromJson(json.decode(str));

String welcomeToJson(Books data) => json.encode(data.toJson());

class Books {
  String lastBuildDate;
  int total;
  int start;
  int display;
  List<Item> items;

  Books({
    required this.lastBuildDate,
    required this.total,
    required this.start,
    required this.display,
    required this.items,
  });

  factory Books.fromJson(Map<String, dynamic> json) => Books(
    lastBuildDate: json["lastBuildDate"] ?? "",
    total: json["total"] ?? 0,
    start: json["start"] ?? 0,
    display: json["display"] ?? 0,
    items: json["items"] != null
        ? List<Item>.from(json["items"].map((x) => Item.fromJson(x)))
        : [], // items가 null이면 빈 리스트로 초기화
  );

  Map<String, dynamic> toJson() => {
    "lastBuildDate": lastBuildDate,
    "total": total,
    "start": start,
    "display": display,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };

  // toString 메서드
  @override
  String toString() {
    return 'Books(lastBuildDate: $lastBuildDate, total: $total, start: $start, display: $display, items: ${items.length})';
  }
}

class Item {
  String bookId;
  String title;
  String link;
  String image;
  String author;
  String discount;
  String publisher;
  String pubdate;
  String isbn;
  String description;
  String bookStatus;
  Timestamp startDate;
  Timestamp createDate;
  Timestamp endDate;
  Timestamp goalDate;
  double star;


  Item({
    required this.bookId,
    required this.title,
    required this.link,
    required this.image,
    required this.author,
    required this.discount,
    required this.publisher,
    required this.pubdate,
    required this.isbn,
    required this.description,
    required this.bookStatus,
    required this.startDate,
    required this.createDate,
    required this.endDate,
    required this.goalDate,
    required this.star,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    bookId: json['book_id'] ?? '',
    title: json["title"] ?? '',
    link: json["link"] ?? '',
    image: json["image"] ?? '',
    author: json["author"] ?? '',
    discount: json["discount"] ?? '',
    publisher: json["publisher"] ?? '',
    pubdate: json["pubdate"] ?? '',
    isbn: json["isbn"] ?? "정보 없음",
    description: json["description"] ?? '',
    bookStatus: json['book_status'] ?? '',
    startDate: json['start_date'] ?? Timestamp.now(),
    createDate: json['create_date'] ?? Timestamp.now(),
    endDate: json['end_date'] ?? Timestamp.now(),
    goalDate: json['goal_date'] ?? Timestamp.now(),
    star: json['star'] ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "book_id": bookId,
    "title": title,
    "link": link,
    "image": image,
    "author": author,
    "discount": discount,
    "publisher": publisher,
    "pubdate": pubdate,
    "isbn": isbn,
    "description": description,
    "book_status": bookStatus,
    "start_date" : startDate,
    "create_date": createDate,
    "end_date": endDate,
    "goal_date": goalDate,
    "star": star
  };
}
