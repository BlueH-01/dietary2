import 'package:dietary2/settings/myPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_register/food_regi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../settings/notify.dart';

// 초과된 부분을 자르는 클리퍼
class _ExcessClipper extends CustomClipper<Rect> {
  final double startRatio;
  final double endRatio;

  _ExcessClipper(this.startRatio, this.endRatio);

  @override
  Rect getClip(Size size) {
    double start = size.width * startRatio;
    double end = size.width * endRatio;
    return Rect.fromLTRB(start, 0, end, size.height);
  }

  @override
  bool shouldReclip(_ExcessClipper oldClipper) {
    return startRatio != oldClipper.startRatio ||
        endRatio != oldClipper.endRatio;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // 섭취 영양소
  double _calories = 0;
  double _carbs = 0;
  double _proteins = 0;
  double _fats = 0;

  late Map<String, Map<String, dynamic>> _mealData;

  // 목표 영양소
  double dailyCalories = 3000;
  double dailyCarbs = 200;
  double dailyProteins = 200;
  double dailyFats = 200;

  bool isLoading = true; //data 로딩 상태
  Map<String, dynamic>? userData; // userData

  // Firebase에서 currentWeight 가져와서 목표값 계산
  Future<void> _fetchDailyGoal() async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
        double currentWeight = userData!['currentWeight'];
        double targetWeight = userData!['targetWeight'];
        double weightDiff = targetWeight - currentWeight;
        // 목표 체중과 현재 체중의 차

        setState(() {
          if (weightDiff > 0) {
            // 체중 증가 목표
            dailyCalories = currentWeight * 24 * 1.7;
            dailyProteins = (dailyCalories * 0.35) / 4;
            dailyFats = (dailyCalories * 0.2) / 9;
            dailyCarbs =
                (dailyCalories - (dailyProteins * 4 + dailyFats * 9)) / 4;
          } else if (weightDiff < 0) {
            // 체중 감소 목표
            dailyCalories = currentWeight * 24 * 1.3;
            dailyProteins = (dailyCalories * 0.4) / 4;
            dailyFats = (dailyCalories * 0.2) / 9;
            dailyCarbs =
                (dailyCalories - (dailyProteins * 4 + dailyFats * 9)) / 4;
          } else {
            // 체중 유지 목표
            dailyCalories = currentWeight * 24 * 1.5;
            dailyProteins = (dailyCalories * 0.25) / 4;
            dailyFats = (dailyCalories * 0.3) / 9;
            dailyCarbs =
                (dailyCalories - (dailyProteins * 4 + dailyFats * 9)) / 4;
          }
          isLoading = false; // 로딩 상태 해제
        });
      } else {
        print('사용자 데이터가 없습니다.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, Map<String, dynamic>> _initializeMealData() {
    return {
      "아침": _emptyMeal(),
      "점심": _emptyMeal(),
      "저녁": _emptyMeal(),
      "간식": _emptyMeal(),
    };
  }

  Map<String, dynamic> _emptyMeal() {
    return {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0,
    };
  }

  String _formattedDate() {
    return "${_selectedDate.toLocal()}".split(' ')[0];
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> _loadDataForDate() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(_formattedDate())
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _calories = (data['calories'] ?? 0).toDouble();
          _carbs = (data['carbs'] ?? 0).toDouble();
          _proteins = (data['proteins'] ?? 0).toDouble();
          _fats = (data['fats'] ?? 0).toDouble();
          _mealData = Map<String, Map<String, dynamic>>.from(
              data['meals'] ?? _initializeMealData());
        });
      } else {
        _resetData();
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      _resetData();
    }
  }

  // Firestore에 데이터 저장
  Future<void> _saveDataForDate() async {
    final formattedDate = "${_selectedDate.toLocal()}".split(' ')[0];
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(formattedDate)
          .set({
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
      _mealData = _initializeMealData();
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
  Widget _buildProgressBar(String label, double currentValue, double goal) {
    double maxValue = goal * 1.3; // 최대치: goal의 130%
    double progress = currentValue / maxValue; // 전체 막대의 진행률
    double normalProgress =
        (currentValue > goal ? goal : currentValue) / maxValue; // 정상 범위 진행률
    double excessProgress =
        (currentValue > goal ? currentValue - goal : 0) / maxValue; // 초과 범위 진행률

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Stack(
          children: [
            // 기본 회색 배경 (전체 Progress Bar)
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.grey, // 기본 회색
              ),
              minHeight: 8.0,
            ),
            // 초록색 정상 범위 Progress Bar
            LinearProgressIndicator(
              value: normalProgress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 118, 193, 120), // 초록색
              ),
              minHeight: 8.0,
            ),
            // 빨간색 초과 범위 Progress Bar
            if (currentValue > goal)
              ClipRect(
                clipper: _ExcessClipper(normalProgress, progress),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.red, // 초과된 부분 빨간색
                  ),
                  minHeight: 8.0,
                ),
              ),
          ],
        ),
        Text("${currentValue.toInt()} / ${goal.toInt()}"),
      ],
    );
  }

  // 식사 데이터를 표시하는 UI2
  Widget _buildMealRow(String mealTime) {
    final meal = _mealData[mealTime]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4.0, // 그림자 효과
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            "$mealTime: ${meal['name']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${meal['calories']} kcal",
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            onPressed: () => _openFoodSelectionScreen(mealTime),
            icon: const Icon(Icons.edit,
                color: Color.fromARGB(255, 132, 195, 135)),
          ),
        ),
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
    _mealData = _initializeMealData();
    _loadDataForDate(); // 초기 데이터 로드
    _fetchDailyGoal(); // 초기화시 목표 영양값 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dietary",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        actions: [
          IconButton(
            // 설정 버튼
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings, size: 30, color: Colors.white),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                Text(_formattedDate(), style: const TextStyle(fontSize: 20)),
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
            _buildProgressBar("칼로리", _calories, dailyCalories),
            _buildProgressBar("탄수화물", _carbs, dailyCarbs),
            _buildProgressBar("단백질", _proteins, dailyProteins),
            _buildProgressBar("지방", _fats, dailyFats),
            const SizedBox(height: 20),
            ..._mealData.keys.map(_buildMealRow),
          ],
        ),
      ),
    );
  }
}

class UserDataService {
  final FirebaseFirestore firestore;

  UserDataService(this.firestore);

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      // Firestore에서 사용자 데이터 가져오기
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // 문서가 존재하면 데이터를 반환
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User data not found!');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
