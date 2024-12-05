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
import './custom_calendar.dart';
import './weight_record.dart';
import '../community/community_screen.dart';

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

  bool isLoading = true; // data 로딩 상태
  Map<String, dynamic>? userData; // userData

  // PageController 추가
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // 초기 페이지를 두 번째로 설정
    _firestore = _firebaseInit.firestore; // FirebaseFirestore 가져오기
    userId = _firebaseInit.auth.currentUser?.uid ?? ''; // ID 가져오기
    _dateManager = DateManager(firestore: _firestore, userId: userId);
    _nutritionManager = _dateManager.nutritionManager;
    _goalManager = GoalManager(firestore: _firestore, userId: userId);
    _userDataService = UserDataService(_firestore);

    _userDataService.userDataStream(userId).listen((userData) {
      _fetchDailyGoal(); // 목표값 업데이트
    });
    _loadDataForDate(); // 초기 데이터 로드
    _fetchDailyGoal(); // 초기 목표 영양값 가져오기
  }

  @override
  void dispose() {
    _userDataSubcription?.cancel(); // 스트림 구독 취소
    _pageController.dispose(); // PageController 해제
    super.dispose();
  }

  void _handleExcessTap(String nutrient) {
    UIManager.showRecommendationDialog(
      context: context,
      nutrient: nutrient,
      suggestions: getRecommendations(nutrient),
    );
  }

  String _formattedDate() {
    return _dateManager.formattedDate();
  }

  // Firestore에서 날짜별 데이터 불러오기
  Future<void> _loadDataForDate() async {
    _dateManager.loadDataForDate(onDataLoaded: (data) {
      setState(() {
        _nutritionManager.updateTotalData();
      });
    }, onNoData: () {
      setState(() {
        _nutritionManager.resetData();
      });
    });
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

    // Custom Calendar 이동
  Future<void> _openCustomCalendar(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCalendar(
          dateManager: _dateManager,
          goalManager: _goalManager,
        ),
      ),
    );
    setState(() {
      _loadDataForDate();
    });
  }

  // 음식 선택 화면으로 이동
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
      onError: () {},
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
      body: PageView(
        controller: _pageController,
        children: [
          const WeightRecordScreen(), // 몸무게 기록 화면 (왼쪽)
          SingleChildScrollView(
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
                    Text(_formattedDate(),
                        style: const TextStyle(fontSize: 20)),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(Icons.arrow_right),
                    ),
                    IconButton(
                      onPressed: () => _openCustomCalendar(context),
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                UIManager.buildProgressBar(
                  label: "칼로리",
                  currentValue: _dateManager.calories,
                  goal: _goalManager.dailyCalories,
                  onExcessTap: () => _handleExcessTap("칼로리"),
                ),
                UIManager.buildProgressBar(
                  label: "탄수화물",
                  currentValue: _dateManager.carbs,
                  goal: _goalManager.dailyCarbs,
                  onExcessTap: () => _handleExcessTap("탄수화물"),
                ),
                UIManager.buildProgressBar(
                  label: "단백질",
                  currentValue: _dateManager.proteins,
                  goal: _goalManager.dailyProteins,
                  onExcessTap: () => _handleExcessTap("단백질"),
                ),
                UIManager.buildProgressBar(
                  label: "지방",
                  currentValue: _dateManager.fats,
                  goal: _goalManager.dailyFats,
                  onExcessTap: () => _handleExcessTap("지방"),
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
          CommunityScreen(), // 커뮤니티 화면 (오른쪽)
        ],
      ),
    );
  }
}
