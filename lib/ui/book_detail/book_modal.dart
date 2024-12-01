import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class BookModal extends StatefulWidget {
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? goalDate;
  final double starRating;

  const BookModal({
    Key? key,
    this.selectedStatus,
    this.startDate,
    this.endDate,
    this.goalDate,
    this.starRating = 0,
  }) : super(key: key);

  @override
  State<BookModal> createState() => _BookModalState();
}

class _BookModalState extends State<BookModal> {
  // 독서 상태 옵션
  String? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? goalDate;
  double starRating = 0;

  @override
  void initState() {
    super.initState();
    //초기 상태 설정(처음 저장 / 수정)
    selectedStatus = widget.selectedStatus;
    startDate = widget.startDate;
    endDate = widget.endDate;
    goalDate = widget.goalDate;
    starRating = widget.starRating;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFCFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 독서 상태 선택
            const Text(
              '독서 상태',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
                child: _buildStatusButtons()
            ),
            const SizedBox(height: 16),

            // 독서 상태에 따라 날짜 선택 표시
            buildDatePickerByBookStatus(),
            const SizedBox(height: 16),

            // 별점
            const Text(
              '별점',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRatingBar(),

            const SizedBox(height: 16),

            // 저장 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 읽은 책이 아니면 별점은 null로 처리
                  if (selectedStatus != "읽은 책" && (starRating != null && starRating > 0)) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("지금은 등록할 수 없습니다"),
                        content: const Text("읽은 책이 아닌 경우 별점은 등록되지 않습니다."),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("확인"),
                          ),
                        ],
                      ),
                    );

                    // 별점을 null로 처리
                    setState(() {
                      starRating = 0;
                    });

                    return; // 저장하지 않고 리턴
                  }

                  Get.back(result: {
                    'status': selectedStatus ?? widget.selectedStatus,
                    'startDate': startDate ?? widget.startDate,
                    'endDate': endDate ?? widget.endDate,
                    'goalDate': goalDate ?? widget.goalDate,
                    'rating': starRating,
                  });
                },
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 독서 상태 버튼 생성
  Widget _buildStatusButtons() {
    List<Map<String, String>> statuses = [
      {"status": "읽은 책", "icon": "assets/image/flag.png"},
      {"status": "읽고 있는 책", "icon": "assets/image/book.png"},
    ];

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: statuses.map((status) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedStatus = status["status"];
            });
          },
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: selectedStatus == status["status"]
                  ? Colors.blue[50]
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedStatus == status["status"]
                    ? Colors.black38
                    : Colors.black12,
                width: 2.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  status["icon"]!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  status["status"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 날짜 선택 위젯 생성
  Widget buildDatePickerByBookStatus() {
    if (selectedStatus == '읽은 책') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '독서 기간',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          _buildDatePicker(
            label: '시작일',
            initialDate: startDate,
            maximumDate: DateTime.now(),
            minimumDate: DateTime(2000),
            onDateChanged: (date) {
              setState(() {
                startDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: '종료일',
            initialDate: endDate,
            maximumDate: DateTime.now(),
            minimumDate: DateTime(2000),
            onDateChanged: (date) {
              setState(() {
                endDate = date;
              });
            },
          ),
        ],
      );
    } else if (selectedStatus == '읽고 있는 책') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '목표 날짜',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          _buildDatePicker(
            label: '목표일',
            initialDate: goalDate,
            maximumDate: DateTime(2100),
            minimumDate: DateTime.now(),
            onDateChanged: (date) {
              setState(() {
                goalDate = date;
              });
            },
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // 날짜 선택 공통 위젯
  Widget _buildDatePicker({
    required String label,
    required DateTime? initialDate,
    required DateTime? maximumDate,
    required DateTime? minimumDate,
    required Function(DateTime) onDateChanged,
  }) {
    DateTime adjustedInitialDate = initialDate ?? DateTime.now();
    if (maximumDate != null && adjustedInitialDate.isAfter(maximumDate)) {
      adjustedInitialDate = maximumDate;
    }
    if (minimumDate != null && adjustedInitialDate.isBefore(minimumDate)) {
      adjustedInitialDate = minimumDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 70,
          child: CupertinoDatePicker(
            dateOrder: DatePickerDateOrder.ymd,
            mode: CupertinoDatePickerMode.date,
            initialDateTime: adjustedInitialDate,
            maximumDate: maximumDate,
            minimumDate: minimumDate,
            onDateTimeChanged: onDateChanged,
          ),
        ),
      ],
    );
  }

  // 별점 위젯 생성
  Widget _buildRatingBar() {
    return Center(
      child: RatingBar(
        initialRating: starRating,
        minRating: 0,
        maxRating: 5,
        allowHalfRating: true,
        itemSize: 40.0,
        ratingWidget: RatingWidget(
          full: const Icon(Icons.star, color: Colors.amberAccent),
          half: const Icon(Icons.star_half, color: Colors.amberAccent),
          empty: const Icon(Icons.star_border, color: Colors.black38),
        ),
        onRatingUpdate: (rating) {
          setState(() {
            starRating = rating;
          });
        },
      ),
    );
  }
}
