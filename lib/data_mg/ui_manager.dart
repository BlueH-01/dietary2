import 'package:flutter/material.dart';

class UIManager {
  static Widget buildProgressBar({
    required String label,
    required double currentValue,
    required double goal,
    required VoidCallback onExcessTap,
  }) {
    double maxValue = goal * 1.3; // 최대치: goal의 130%
    double progress = currentValue / maxValue; // 전체 막대의 진행률
    double normalProgress =
        (currentValue > goal ? goal : currentValue) / maxValue; // 정상 범위 진행률
    // double excessProgress =
    //     (currentValue > goal ? currentValue - goal : 0) / maxValue; // 초과 범위 진행률

    return GestureDetector(
      onTap: () {
        if (currentValue > goal) {
          onExcessTap();
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

  static Widget buildMealRow({
    required Map<String, dynamic> meal,
    required String mealTime,
    required VoidCallback onEdit,
  }) {
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
            onPressed: onEdit,
            icon: const Icon(Icons.edit,
                color: Color.fromARGB(255, 132, 195, 135)),
          ),
        ),
      ),
    );
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
