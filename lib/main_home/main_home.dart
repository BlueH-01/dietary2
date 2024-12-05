import 'dart:async';
import 'package:dietary2/data_mg/nutrition_manager.dart';
import 'package:dietary2/settings/myPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_register/food_regi.dart';
import '../data_mg/recomend_mg.dart';
import 'package:dietary2/firebase_init.dart';
import 'package:dietary2/data_mg/date_manager.dart';
import 'package:dietary2/data_mg/goal_manager.dart';
import '../data_mg/user_data_service.dart';
import '../data_mg/ui_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseInit _firebaseInit = FirebaseInit.instance;
  late FirebaseFirestore _firestore = _firebaseInit.firestore;
  late String userId;
  late DateManager _dateManager;
  late NutritionManager _nutritionManager;
  late GoalManager _goalManager;
  late UserDataService _userDataService;
  
  StreamSubscription<Map<String, dynamic>>? _userDataSubcription;

  bool isLoading = true; //data 로딩 상태
  Map<String, dynamic>? userData; // userData

  @override
  void initState() {
    super.initState();
    _firestore = _firebaseInit.firestore; // FirebaseFirestore 가져오기
    userId = _firebaseInit.auth.currentUser?.uid ?? ''; //ID 가져오기
    _dateManager = DateManager(firestore: _firestore,userId: userId);
    _nutritionManager = _dateManager.nutritionManager;
    _goalManager = GoalManager(firestore: _firestore, userId: userId);
    _userDataService = UserDataService(_firestore);
    
    _userDataService.userDataStream(userId).listen((userData){
      _fetchDailyGoal(); // 목표값 업데이트
    });
    _loadDataForDate(); // 초기 데이터 로드
    _fetchDailyGoal(); // 초기 목표 영양값 가져오기
  }

  @override
  void dispose() { // 앱의 불필요한 작업 지속 방지
    _userDataSubcription?.cancel(); // 스트림 구독 취소
    super.dispose();
  }

  String _formattedDate() {
    return _dateManager.formattedDate();
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> _loadDataForDate() async {
    _dateManager.loadDataForDate(
      onDataLoaded: (data) {
        setState(() {
          _nutritionManager.updateTotalData();
        });
      },
      onNoData: () {
        setState(() {
          _nutritionManager.resetData();
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
        _nutritionManager.mealData[mealTime] = {
          "name": result['name'],
          "calories": result['calories'],
          "carbs": result['carbs'],
          "proteins": result['protein'],
          "fats": result['fat'],
        };
        _nutritionManager.updateTotalData();
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
            UIManager.buildProgressBar(
              label: "칼로리",
              currentValue: _dateManager.calories,
              goal: _goalManager.dailyCalories,
              onExcessTap: () {
                _showRecommendationDialog("칼로리", _dateManager.calories - _goalManager.dailyCalories);
              },
            ),
            UIManager.buildProgressBar(
              label: "탄수화물",
              currentValue: _dateManager.carbs,
              goal: _goalManager.dailyCarbs,
              onExcessTap: () {
                _showRecommendationDialog("탄수화물", _dateManager.carbs - _goalManager.dailyCarbs);
              },
            ),
            UIManager.buildProgressBar(
              label: "단백질",
              currentValue: _dateManager.proteins,
              goal: _goalManager.dailyProteins,
              onExcessTap: () {
                _showRecommendationDialog("단백질", _dateManager.proteins - _goalManager.dailyProteins);
              },
            ),
            UIManager.buildProgressBar(
              label: "지방",
              currentValue: _dateManager.fats,
              goal: _goalManager.dailyFats,
              onExcessTap: () {
                _showRecommendationDialog("지방", _dateManager.fats - _goalManager.dailyFats);
              },
            ),
            const SizedBox(height: 20),
            ...["아침", "점심", "저녁", "간식"].map((mealTime) {
              return UIManager.buildMealRow(
                meal: _nutritionManager.mealData[mealTime]!,
                mealTime: mealTime,
                onEdit: () => openFoodSelectionScreen(mealTime),
              );
            }),
          ],
        ),
      ),
    );
  }
}
