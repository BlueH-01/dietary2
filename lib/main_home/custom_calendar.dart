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

  @override
  void initState() {
    super.initState();
    _highlightGoalDates();
  }

  Future<void> _highlightGoalDates() async {
    final userId = widget.dateManager.userId;
    final firestore = widget.dateManager.firestore;

    final collection = firestore
        .collection('users')
        .doc(userId)
        .collection('daily_data');

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
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    });
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final days = List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );

    // 앞뒤로 빈 날짜 채우기 (달력 정렬을 위해)
    final leadingEmptyDays = firstDay.weekday - 1;
    final trailingEmptyDays = 7 - lastDay.weekday;

    return [
      ...List.generate(leadingEmptyDays, (_) => DateTime(0)),
      ...days,
      ...List.generate(trailingEmptyDays, (_) => DateTime(0)),
    ];
  }

  String _getMonthTitle(DateTime date) {
    return '${date.year}년 ${date.month}월'; // 2023 - 12 형식 표시
  }

  @override
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
            onPressed: _goToPreviousMonth,
            icon: const Icon(Icons.arrow_left),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: const Icon(Icons.arrow_right),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: daysInMonth.length,
        itemBuilder: (context, index) {
          final date = daysInMonth[index];

          if (date.year == 0) {
            // 빈 칸 (빈 날짜)
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
              Navigator.pop(context); // 날짜 선택 후 화면 닫기
            },
            child: Container(
              decoration: BoxDecoration(
                color
                  :isHighlighted
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
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
