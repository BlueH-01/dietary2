import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateManager {
  final FirebaseFirestore firestore; // Firestore 인스턴스
  final String userId; // 현재 사용자 ID

  DateTime selectedDate; // 현재 선택 날짜

  DateManager({
    required this.firestore,
    required this.userId, // Id - 현재 사용자
    DateTime? initialDate, // 초기 날짜 - 오늘 날짜로 설정
  }) : selectedDate = initialDate ?? DateTime.now();

  // 현재 선택된 날짜의 포맷
  String formattedDate() {
    return "${selectedDate.toLocal()}".split(' ')[0];
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<Map<String, dynamic>> loadDataForDate(
      {required void Function(Map<String, dynamic>) onDataLoaded,
      required VoidCallback onNoData}) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(formattedDate())
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        onDataLoaded(data);
        return data;
      } else {
        onNoData();
        return {};
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      onNoData();
      return {};
    }
  }

  // Firestore에 데이터 저장
  Future<void> saveDataForDate(Map<String, dynamic> data) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(formattedDate())
          .set(data);
      debugPrint("Data saved successfully!");
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }

  // 날짜 변경
  void changeDate(int days, Function(DateTime) onDateChanged) {
    selectedDate = selectedDate.add(Duration(days: days));
    onDateChanged(selectedDate);
  }

  // 날짜 선택
  Future<void> selectDate(
    BuildContext context, {
    required Function(DateTime) onDateSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      onDateSelected(selectedDate);
    }
  }
}
