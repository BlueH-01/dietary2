import 'package:dietary2/settings/myPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_register/food_regi.dart';
import '../data_mg/recomend_mg.dart';
import 'package:dietary2/firebase_init.dart';
import 'package:dietary2/data_mg/date_manager.dart';
import 'package:dietary2/data_mg/goal_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseInit _firebaseInit = FirebaseInit.instance;
  late FirebaseFirestore _firestore;
  late String userId;
  late DateManager _dateManager;
  late GoalManager _goalManager;

  bool isLoading = true; //data 로딩 상태
  Map<String, dynamic>? userData; // userData

  @override
  void initState() {
    super.initState();
    _firestore = _firebaseInit.firestore; // FirebaseFirestore 가져오기
    userId = _firebaseInit.auth.currentUser?.uid ?? ''; //ID 가져오기
    _dateManager = DateManager(
        firestore: _firestore, // Firestore 인스턴스 전달
        userId: userId); // 현재 로그인한 ID를 Date Manager에게 전달
    _goalManager = GoalManager(firestore: _firestore, userId: userId);
    _loadDataForDate(); // 초기 데이터 로드
    _fetchDailyGoal(); // 초기화시 목표 영양값 가져오기
  }

  String _formattedDate() {
    return _dateManager.formattedDate();
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> _loadDataForDate() async {
    _dateManager.loadDataForDate(
      onDataLoaded: (data) {
        setState(() {
          _dateManager.updateTotalData();
        });
      },
      onNoData: () {
        setState(() {
          _dateManager.resetData();
        });
      }
    );
  }

  // Firestore에 데이터 저장
  void _saveDataForDate() {
    _dateManager.saveDataForDate(); // DateManager 사용
  }

  // 날짜 변경 함수
  void _changeDate(int days) {
    _dateManager.changeDate(
      days,
      (newDate) => setState(() {
        _loadDataForDate();
      }),
    );
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    await _dateManager.selectDate(
      context,
      onDateSelected: (newDate) => setState(() {
        _loadDataForDate();
      }),
    );
  }

    //음식 선택 화면으로 이동
  Future<void> openFoodSelectionScreen(String mealTime) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DietaryScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _dateManager.mealData[mealTime] = {
          "name": result['name'],
          "calories": result['calories'],
          "carbs": result['carbs'],
          "proteins": result['protein'],
          "fats": result['fat'],
        };
        _dateManager.updateTotalData();
        _saveDataForDate(); // 저장
      });
    }
  }

    // Firebase에서 currentWeight 가져와서 목표값 계산
  Future<void> _fetchDailyGoal() async {
    _goalManager.fetchDailyGoal(
        onUpdate: ({
          required double dailyCalories,
          required double dailyCarbs,
          required double dailyProteins,
          required double dailyFats,
        }) {
          setState(() {
            _goalManager.dailyCalories = dailyCalories;
            _goalManager.dailyCarbs = dailyCarbs;
            _goalManager.dailyProteins = dailyProteins;
            _goalManager.dailyFats = dailyFats;
          });
        },
        onError: () {});
  }

  // 식사 데이터를 표시하는 UI
  Widget _buildProgressBar(String label, double currentValue, double goal) {
    double maxValue = goal * 1.3; // 최대치: goal의 130%
    double progress = currentValue / maxValue; // 전체 막대의 진행률
    double normalProgress =
        (currentValue > goal ? goal : currentValue) / maxValue; // 정상 범위 진행률
    double excessProgress =
        (currentValue > goal ? currentValue - goal : 0) / maxValue; // 초과 범위 진행률

    return GestureDetector(
      onTap: () {
        if (currentValue > goal) {
          _showRecommendationDialog(label, currentValue - goal);
        }
      },
      child: Column(
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
                  child: const LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.red, // 초과된 부분 빨간색
                    ),
                    minHeight: 8.0,
                  ),
                ),
            ],
          ),
          Text("${currentValue.toInt()} / ${goal.toInt()}"),
        ],
      ),
    );
  }

  void _showRecommendationDialog(String nutrient, double excessAmount) {
    // recommend.dart에서 데이터 가져오기
    final suggestions = getRecommendations(nutrient);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "$nutrient 초과 해결 방법",
            style: const TextStyle(
              color: Color.fromARGB(255, 132, 195, 135),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 400,
            height: 370,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  ...suggestions.map(
                    (suggestion) => ListTile(
                      leading: Icon(
                        suggestion['icon'],
                        color: suggestion['type'] == '운동'
                            ? Colors.blue
                            : Colors.green,
                      ),
                      title: Text(
                        suggestion['suggestion'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("닫기", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // 식사 데이터를 표시하는 UI2
  Widget buildMealRow(String mealTime) {
    final meal = _dateManager.mealData[mealTime]!;
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
            onPressed: () => openFoodSelectionScreen(mealTime),
            icon: const Icon(Icons.edit,
                color: Color.fromARGB(255, 132, 195, 135)),
          ),
        ),
      ),
    );
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
            _buildProgressBar("칼로리", _dateManager.calories, _goalManager.dailyCalories),
            _buildProgressBar("탄수화물", _dateManager.carbs, _goalManager.dailyCarbs),
            _buildProgressBar("단백질", _dateManager.proteins, _goalManager.dailyProteins),
            _buildProgressBar("지방", _dateManager.fats, _goalManager.dailyFats),
            const SizedBox(height: 20),
            ...["아침", "점심", "저녁", "간식"].map(buildMealRow),
          ],
        ),
      ),
    );
  }
}

class UserDataService {
  final _firestore;

  UserDataService(this._firestore);

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      // Firestore에서 사용자 데이터 가져오기
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

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
