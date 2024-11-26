import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_register/food_regi.dart';
import '../settings/notify.dart';
//import 'package:dietary2/foodlist/food_list.dart'; // DietaryScreen 파일 import

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _calories = 0;
  double _carbs = 0;
  double _proteins = 0;
  double _fats = 0;

  Map<String, Map<String, dynamic>> _mealData = {
    "아침": {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0
    },
    "점심": {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0
    },
    "저녁": {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0
    },
    "간식": {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0
    },
  };

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> _loadDataForDate() async {
    final formattedDate = "${_selectedDate.toLocal()}".split(' ')[0];
    try {
      final doc =
          await _firestore.collection('daily_data').doc(formattedDate).get();
      if (doc.exists) {
        setState(() {
          _calories = (doc['calories'] ?? 0).toDouble();
          _carbs = (doc['carbs'] ?? 0).toDouble();
          _proteins = (doc['proteins'] ?? 0).toDouble();
          _fats = (doc['fats'] ?? 0).toDouble();
          _mealData =
              Map<String, Map<String, dynamic>>.from(doc['meals'] ?? _mealData);
        });
      } else {
        _resetData();
      }
    } catch (e) {
      print("Error loading data: $e");
      _resetData();
    }
  }

  // Firestore에 데이터 저장
  Future<void> _saveDataForDate() async {
    final formattedDate = "${_selectedDate.toLocal()}".split(' ')[0];
    try {
      await _firestore.collection('daily_data').doc(formattedDate).set({
        'calories': _calories,
        'carbs': _carbs,
        'proteins': _proteins,
        'fats': _fats,
        'meals': _mealData,
      });
      print("Data saved successfully!");
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  // 데이터 초기화
  void _resetData() {
    setState(() {
      _calories = 0;
      _carbs = 0;
      _proteins = 0;
      _fats = 0;
      _mealData = {
        "아침": {
          "name": "없음",
          "calories": 0.0,
          "carbs": 0.0,
          "proteins": 0.0,
          "fats": 0.0
        },
        "점심": {
          "name": "없음",
          "calories": 0.0,
          "carbs": 0.0,
          "proteins": 0.0,
          "fats": 0.0
        },
        "저녁": {
          "name": "없음",
          "calories": 0.0,
          "carbs": 0.0,
          "proteins": 0.0,
          "fats": 0.0
        },
        "간식": {
          "name": "없음",
          "calories": 0.0,
          "carbs": 0.0,
          "proteins": 0.0,
          "fats": 0.0
        },
      };
    });
  }

  // 날짜 변경 함수
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadDataForDate();
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDataForDate();
    }
  }

  // 식사 데이터를 표시하는 UI
  Widget _buildMealRow(String mealTime) {
    final meal = _mealData[mealTime]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                "$mealTime: ${meal['name']} (${meal['calories']} kcal)",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _openFoodSelectionScreen(mealTime);
            },
            icon: const Icon(Icons.edit, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  //음식 선택 화면으로 이동
  Future<void> _openFoodSelectionScreen(String mealTime) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DietaryScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _mealData[mealTime] = {
          "name": result['name'],
          "calories": result['calories'],
          "carbs": result['carbs'],
          "proteins": result['protein'],
          "fats": result['fat'],
        };
        _updateTotalData();
        _saveDataForDate(); // 저장
      });
    }
  }

  // 전체 합산 데이터 업데이트
  void _updateTotalData() {
    setState(() {
      _calories = 0;
      _carbs = 0;
      _proteins = 0;
      _fats = 0;

      _mealData.forEach((key, value) {
        _calories += value['calories'];
        _carbs += value['carbs'];
        _proteins += value['proteins'];
        _fats += value['fats'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataForDate(); // 초기 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
        actions: [
          IconButton(
            onPressed: () {
              // 알림 버튼 클릭 시 동작
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationService(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.arrow_left),
                ),
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.arrow_right),
                ),
                IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("칼로리"),
            LinearProgressIndicator(value: _calories / 3000),
            Text("${_calories.toInt()} / 3000 kcal"),
            const Text("탄수화물"),
            LinearProgressIndicator(value: _carbs / 500),
            Text("${_carbs.toInt()} / 500 g"),
            const Text("단백질"),
            LinearProgressIndicator(value: _proteins / 200),
            Text("${_proteins.toInt()} / 200 g"),
            const Text("지방"),
            LinearProgressIndicator(value: _fats / 100),
            Text("${_fats.toInt()} / 100 g"),
            const SizedBox(height: 20),
            _buildMealRow("아침"),
            _buildMealRow("점심"),
            _buildMealRow("저녁"),
            _buildMealRow("간식"),
          ],
        ),
      ),
    );
  }
}
