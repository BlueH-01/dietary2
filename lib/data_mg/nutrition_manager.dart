
class NutritionManager {
  // 영양소 데이터
  double calories = 0;
  double carbs = 0;
  double proteins = 0;
  double fats = 0;

  late Map<String, Map<String, dynamic>> mealData;

  NutritionManager() {
    mealData = _initializeMealData();
  }

  // 초기 식사 데이터 생성
  Map<String, Map<String, dynamic>> _initializeMealData() {
    return {
      "아침": _emptyMeal(),
      "점심": _emptyMeal(),
      "저녁": _emptyMeal(),
      "간식": _emptyMeal(),
    };
  }

  // 빈 식사 데이터
  Map<String, dynamic> _emptyMeal() {
    return {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0,
    };
  }

  void updateFromData(Map<String, dynamic> data) {
    calories = (data['calories'] ?? 0).toDouble();
    carbs = (data['carbs'] ?? 0).toDouble();
    proteins = (data['proteins'] ?? 0).toDouble();
    fats = (data['fats'] ?? 0).toDouble();
    mealData = Map<String, Map<String, dynamic>>.from(
      data['meals'] ?? _initializeMealData(),
    );
  }

  // 데이터 초기화
  void resetData() {
    calories = 0;
    carbs = 0;
    proteins = 0;
    fats = 0;
    mealData = _initializeMealData();
  }

  // 전체 합산 데이터 업데이트
  void updateTotalData() {
    calories = 0;
    carbs = 0;
    proteins = 0;
    fats = 0;

    mealData.forEach((key, value) {
      calories += value['calories'];
      carbs += value['carbs'];
      proteins += value['proteins'];
      fats += value['fats'];
    });
  }
}
