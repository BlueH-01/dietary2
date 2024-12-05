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
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
                minHeight: 8.0,
              ),
              LinearProgressIndicator(
                value: normalProgress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 118, 193, 120),
                ),
                minHeight: 8.0,
              ),
              if (currentValue > goal)
                ClipRect(
                  clipper: _ExcessClipper(normalProgress, progress),
                  child: const LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
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
        elevation: 4.0,
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

  static void showRecommendationDialog({
    required BuildContext context,
    required String nutrient,
    required List<Map<String, dynamic>> suggestions,
  }) {
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
                children: suggestions.map(
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
                ).toList(),
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
}

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
