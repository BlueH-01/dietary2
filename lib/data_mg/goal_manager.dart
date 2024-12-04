import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class GoalManager {
  final FirebaseFirestore firestore;
  final String userId;

  double dailyCalories = 3000;
  double dailyCarbs = 200;
  double dailyProteins = 200;
  double dailyFats = 200;

  GoalManager({
    required this.firestore,
    required this.userId,
  });

  // Firebase에서 currentWeight와 targetWeight를 사용해 목표 영양소 계산
  Future<void> fetchDailyGoal({
    required Function({
      required double dailyCalories,
      required double dailyCarbs,
      required double dailyProteins,
      required double dailyFats,
    }) onUpdate,
    required VoidCallback onError,
  }) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        double currentWeight = userData['currentWeight'];
        double targetWeight = userData['targetWeight'];
        double weightDiff = targetWeight - currentWeight;

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

        onUpdate(
          dailyCalories: dailyCalories,
          dailyCarbs: dailyCarbs,
          dailyProteins: dailyProteins,
          dailyFats: dailyFats,
        );
      } else {
        print("User data not found");
        onError();
      }
    } catch (e) {
      print("Error fetching daily goal: $e");
      onError();
    }
  }
}
