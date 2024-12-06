import 'package:flutter/material.dart';
import '../data_mg/date_manager.dart';
import '../data_mg/goal_manager.dart';

class CustomCalendar extends StatefulWidget {
  final DateManager dateManager;
  final GoalManager goalManager;

  const CustomCalendar({
    Key? key,
    required this.dateManager,
    required this.goalManager,
  }) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  final Set<DateTime> _highlightedDates = {};
  List<Map<String, String>> _recommendedFoods = [];

  @override
  void initState() {
    super.initState();
    _highlightGoalDates();
    _fetchRecommendedFoods();
    _focusedDate = widget.dateManager.selectedDate; // 초기 포커스 설정
    _selectedDate = widget.dateManager.selectedDate;
  }

  Future<void> _highlightGoalDates() async {
    final userId = widget.dateManager.userId;
    final firestore = widget.dateManager.firestore;

    final collection =
        firestore.collection('users').doc(userId).collection('daily_data');

    final snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(doc.id);

      if (_meetsGoals(data)) {
        setState(() {
          _highlightedDates.add(date);
        });
      }
    }
  }

  Future<void> _fetchRecommendedFoods() async {
    final firestore = widget.dateManager.firestore;

    final currentMonth = _focusedDate.month;
    final collection = firestore.collection('recommend_food');

    final snapshot = await collection
        .where('month', isEqualTo: currentMonth)
        .get();

    final foods = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'food_name': data['food_name'] as String,
        'image_url': data['image_url'] as String,
        'comment': data['comment'] as String,
      };
    }).toList();

    setState(() {
      _recommendedFoods = foods;
    });
  }

  bool _meetsGoals(Map<String, dynamic> data) {
    final calories = data['calories'] ?? 0.0;
    final carbs = data['carbs'] ?? 0.0;
    final proteins = data['proteins'] ?? 0.0;
    final fats = data['fats'] ?? 0.0;

    return calories <= widget.goalManager.dailyCalories &&
        carbs <= widget.goalManager.dailyCarbs &&
        proteins <= widget.goalManager.dailyProteins &&
        fats <= widget.goalManager.dailyFats;
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
    });
    _fetchRecommendedFoods();
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    });
    _fetchRecommendedFoods();
  }

  void _selectMonth() async {
    final selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Month"),
          children: List.generate(12, (index) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, index + 1);
              },
              child: Text("${index + 1}월"),
            );
          }),
        );
      },
    );

    if (selectedMonth != null) {
      setState(() {
        _focusedDate = DateTime(_focusedDate.year, selectedMonth, 1);
      });
      _fetchRecommendedFoods();
    }
  }

  String _getMonthTitle(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final days = List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );

    final leadingEmptyDays = firstDay.weekday - 1;
    final trailingEmptyDays = 7 - lastDay.weekday;

    return [
      ...List.generate(leadingEmptyDays, (_) => DateTime(0)),
      ...days,
      ...List.generate(trailingEmptyDays, (_) => DateTime(0)),
    ];
  }


  Widget build(BuildContext context) {
    final daysInMonth = _generateDaysInMonth(_focusedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getMonthTitle(_focusedDate),
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        actions: [
          IconButton(
            onPressed: _selectMonth,
            icon: const Icon(Icons.calendar_view_month),
          ),
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: const Icon(Icons.arrow_left),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: const Icon(Icons.arrow_right),
          ),
        ],
      ),
      body: Column(
        children: [
          // 달력 공간 줄이기
          Expanded(
            flex: 1, // 이전 flex: 2에서 1로 변경
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                final date = daysInMonth[index];

                if (date.year == 0) {
                  return const SizedBox.shrink();
                }

                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                final isSelected = _selectedDate != null &&
                    date.day == _selectedDate!.day &&
                    date.month == _selectedDate!.month &&
                    date.year == _selectedDate!.year;

                final isHighlighted = _highlightedDates.contains(date);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                        _selectedDate = date;
                        widget.dateManager.selectedDate = date;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Colors.green
                          : isSelected
                              ? Colors.orange
                              : isToday
                                  ? Colors.blue
                                  : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: date.month == _focusedDate.month
                            ? Colors.black
                            : Colors.grey,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 추천 음식 리스트 공간은 그대로 유지
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendedFoods.length,
              itemBuilder: (context, index) {
                final food = _recommendedFoods[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        food['image_url']!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        food['food_name']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150, // 이미지의 너비와 동일한 너비를 지정하거나 적당한 크기 설정
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          food['comment']!,
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                          softWrap: true, // 텍스트 줄바꿈 허용
                          overflow: TextOverflow.fade, // 텍스트가 너무 길면 페이드 처리
                          maxLines: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
