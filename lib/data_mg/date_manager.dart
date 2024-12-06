import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_mg/nutrition_manager.dart';

class DateManager {
  final FirebaseFirestore firestore; // Firestore 인스턴스
  final String userId; // 현재 사용자 ID
  DateTime selectedDate; // 현재 선택 날짜

  final NutritionManager nutritionManager; // NutritionManager 인스턴스

  double get calories => nutritionManager.calories;
  double get carbs => nutritionManager.carbs;
  double get proteins => nutritionManager.proteins;
  double get fats => nutritionManager.fats;

  DateManager({
    required this.firestore,
    required this.userId, // Id - 현재 사용자
    DateTime? initialDate, // 초기 날짜 - 오늘 날짜로 설정
  }) : selectedDate = initialDate ?? DateTime.now(), 
      nutritionManager = NutritionManager();

  // 현재 선택된 날짜의 포맷
  String formattedDate() {
    return "${selectedDate.toLocal()}".split(' ')[0];
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> loadDataForDate({
    required void Function(Map<String, dynamic>) onDataLoaded,
    required VoidCallback onNoData,
  }) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(formattedDate())
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nutritionManager.updateFromData(data);
        onDataLoaded(data);
      } else {
        nutritionManager.resetData();
        onNoData();
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      nutritionManager.resetData();
      onNoData();
    }
  }

  // Firestore에 데이터 저장
  Future<void> saveDataForDate() async {
    final data = {
      'calories': nutritionManager.calories,
      'carbs': nutritionManager.carbs,
      'proteins': nutritionManager.proteins,
      'fats': nutritionManager.fats,
      'meals': nutritionManager.mealData,
    }; try {
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
}
