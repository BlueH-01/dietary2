import 'package:dietary2/settings/myPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_register/food_regi.dart';
import 'package:dietary2/firebase_init.dart';
import 'package:dietary2/data_mg/date_manager.dart';
import 'package:dietary2/data_mg/goal_manager.dart';

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
  final FirebaseInit _firebaseInit = FirebaseInit.instance;
  late FirebaseFirestore _firestore;
  late String userId;
  late DateManager _dateManager;
  late GoalManager _goalManager;

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

  @override
  void initState() {
    super.initState();
    _firestore = _firebaseInit.firestore; // FirebaseFirestore 가져오기
    userId = _firebaseInit.auth.currentUser?.uid ?? ''; //ID 가져오기
    _dateManager = DateManager(
      firestore: _firestore, // Firestore 인스턴스 전달
      userId: userId); // 현재 로그인한 ID를 Date Manager에게 전달
    _goalManager = GoalManager(
      firestore: _firestore,
      userId: userId);
    _mealData = _initializeMealData();
    _loadDataForDate(); // 초기 데이터 로드
    _fetchDailyGoal(); // 초기화시 목표 영양값 가져오기
  }

  // Firebase에서 currentWeight 가져와서 목표값 계산
  Future<void> _fetchDailyGoal() async {
    _goalManager.fetchDailyGoal(
      onUpdate: ({
        required double dailyCalories,
        required double dailyCarbs,
        required double dailyProteins,
        required double dailyFats,
      }){
        setState(() {
          this.dailyCalories = dailyCalories;
          this.dailyCarbs = dailyCarbs;
          this.dailyProteins = dailyProteins;
          this.dailyFats = dailyFats;
        });
      }, 
      onError:(){});
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
    return _dateManager.formattedDate();
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> _loadDataForDate() async {
    _dateManager.loadDataForDate(onDataLoaded: (data){
          setState(() {
          _calories = (data['calories'] ?? 0).toDouble();
          _carbs = (data['carbs'] ?? 0).toDouble();
          _proteins = (data['proteins'] ?? 0).toDouble();
          _fats = (data['fats'] ?? 0).toDouble();
          _mealData = Map<String, Map<String, dynamic>>.from(
              data['meals'] ?? _initializeMealData());
        });
      },
      onNoData: _resetData,
    );
  }

  // Firestore에 데이터 저장
  void _saveDataForDate() {
  final data = {
    'calories': _calories,
    'carbs': _carbs,
    'proteins': _proteins,
    'fats': _fats,
    'meals': _mealData,
  };

  _dateManager.saveDataForDate(data); // DateManager 사용
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
    List<Map<String, dynamic>> suggestions = [];

    // 추천 내용을 초과된 영양소에 따라 다르게 제공
    switch (nutrient) {
      case "칼로리":
        suggestions = [
          {
            'type': '운동',
            'suggestion': "빠르게 걷기 30분 (약 200kcal 소모)",
            'icon': Icons.directions_walk
          },
          {
            'type': '운동',
            'suggestion': "집에서 할 수 있는 홈트레이닝: 스쿼트, 푸시업, 플랭크 10분",
            'icon': Icons.fitness_center
          },
          {
            'type': '운동',
            'suggestion': "자전거 타기 30분 (약 300kcal 소모)",
            'icon': Icons.directions_bike
          },
          {
            'type': '운동',
            'suggestion': "HIIT(고강도 인터벌 트레이닝) 20분",
            'icon': Icons.accessibility
          },
          {
            'type': '식단',
            'suggestion': "가벼운 야채 샐러드와 올리브유 드레싱으로 식사량 줄이기",
            'icon': Icons.restaurant
          },
          {
            'type': '식단',
            'suggestion': "닭가슴살, 고등어 등 기름진 음식 대신 담백한 단백질 섭취",
            'icon': Icons.fastfood
          },
          {
            'type': '식단',
            'suggestion': "간식으로 과일 대신 채소 스틱 섭취",
            'icon': Icons.local_grocery_store
          },
          {
            'type': '식단',
            'suggestion': "물을 충분히 마셔 포만감 느끼기",
            'icon': Icons.local_drink
          },
        ];
        break;
      case "탄수화물":
        suggestions = [
          {
            'type': '운동',
            'suggestion': "유산소 운동: 조깅 또는 자전거 타기 30분",
            'icon': Icons.directions_run
          },
          {
            'type': '운동',
            'suggestion': "줄넘기 15분",
            'icon': Icons.sports_handball
          },
          {
            'type': '운동',
            'suggestion': "복근 운동: 크런치, 레그레이즈 10분",
            'icon': Icons.fitness_center
          },
          {
            'type': '운동',
            'suggestion': "스텝업 운동 20분",
            'icon': Icons.directions_walk
          },
          {
            'type': '식단',
            'suggestion': "밥 대신 현미밥 또는 찹쌀밥으로 대체",
            'icon': Icons.rice_bowl
          },
          {
            'type': '식단',
            'suggestion': "정제된 탄수화물 대신 귀리, 고구마 등의 통곡물 섭취",
            'icon': Icons.local_dining
          },
          {
            'type': '식단',
            'suggestion': "가공된 빵 대신 통밀빵이나 쌀국수 등 자연식으로 대체",
            'icon': Icons.food_bank
          },
          {
            'type': '식단',
            'suggestion': "배고픔을 느낄 때 과일 대신 채소를 섭취하여 탄수화물 감소",
            'icon': Icons.agriculture
          },
        ];
        break;
      case "단백질":
        suggestions = [
          {
            'type': '운동',
            'suggestion': "근력 운동: 덤벨을 이용한 상체 운동 20분",
            'icon': Icons.fitness_center
          },
          {
            'type': '운동',
            'suggestion': "요가나 필라테스 30분",
            'icon': Icons.self_improvement
          },
          {
            'type': '운동',
            'suggestion': "서킷 트레이닝: 전신 운동 30분",
            'icon': Icons.loop
          },
          {'type': '운동', 'suggestion': "스트레칭으로 근육 이완", 'icon': Icons.spa},
          {
            'type': '식단',
            'suggestion': "식물성 단백질 대체: 두부, 콩 등 섭취",
            'icon': Icons.fastfood
          },
          {
            'type': '식단',
            'suggestion': "지방이 적은 고기 선택: 닭가슴살, 고등어, 연어 등",
            'icon': Icons.local_dining
          },
          {
            'type': '식단',
            'suggestion': "식사 시 단백질 비율을 높이고 탄수화물은 줄여 균형 잡힌 식사",
            'icon': Icons.restaurant
          },
          {
            'type': '식단',
            'suggestion': "운동 후 단백질 쉐이크나 계란 흰자 섭취",
            'icon': Icons.local_drink
          },
        ];
        break;
      case "지방":
        suggestions = [
          {
            'type': '운동',
            'suggestion': "고강도 유산소 운동 (달리기, 자전거 타기, 수영 등)으로 지방 연소 촉진",
            'icon': Icons.run_circle
          },
          {
            'type': '운동',
            'suggestion': "전신 근력 운동: 스쿼트, 데드리프트 30분",
            'icon': Icons.fitness_center
          },
          {
            'type': '운동',
            'suggestion': "복합 운동: 푸시업과 스쿼트를 번갈아 가며 15분",
            'icon': Icons.fitness_center
          },
          {
            'type': '운동',
            'suggestion': "HIIT 운동 20분",
            'icon': Icons.accessibility
          },
          {
            'type': '식단',
            'suggestion': "포화지방을 줄이기 위해 기름진 음식 대신 올리브유, 아보카도 사용",
            'icon': Icons.restaurant
          },
          {
            'type': '식단',
            'suggestion': "튀긴 음식 대신 찜, 구이 요리로 조리 방법 변경",
            'icon': Icons.kitchen
          },
          {
            'type': '식단',
            'suggestion': "간식으로 견과류(아몬드, 호두)와 아보카도를 섭취",
            'icon': Icons.nature_people
          },
          {
            'type': '식단',
            'suggestion': "저지방 요거트나 스무디로 간식 대체",
            'icon': Icons.local_cafe
          },
        ];
        break;
    }

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
            textAlign: TextAlign.center, // 가운데 정렬
          ),
          content: SizedBox(
            width: 400, // 원하는 너비
            height: 370, // 원하는 높이
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20), // 제목과 설명 사이에 간격 추가
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
                        style: const TextStyle(fontSize: 14), // 텍스트 크기 조정
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
            onPressed: () => openFoodSelectionScreen(mealTime),
            icon: const Icon(Icons.edit,
                color: Color.fromARGB(255, 132, 195, 135)),
          ),
        ),
      ),
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
        _mealData[mealTime] = {
          "name": result['name'],
          "calories": result['calories'],
          "carbs": result['carbs'],
          "proteins": result['protein'],
          "fats": result['fat'],
        };
        updateTotalData();
        _saveDataForDate(); // 저장
      });
    }
  }

  // 전체 합산 데이터 업데이트
  void updateTotalData() {
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
            ...["아침","점심","저녁"].map(buildMealRow),
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
