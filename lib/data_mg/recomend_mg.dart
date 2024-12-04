// recommend.dart
import 'package:flutter/material.dart';

List<Map<String, dynamic>> getRecommendations(String nutrient) {
  List<Map<String, dynamic>> suggestions = [];
  switch (nutrient) {
    case "칼로리":
      suggestions = [
        {
          'type': '운동',
          'suggestion': "빠르게 걷기 30분 (약 200kcal 소모)",
          'icon': Icons.directions_walk,
        },
        {
          'type': '운동',
          'suggestion': "집에서 할 수 있는 홈트레이닝: 스쿼트, 푸시업, 플랭크 10분",
          'icon': Icons.fitness_center,
        },
        {
          'type': '운동',
          'suggestion': "자전거 타기 30분 (약 300kcal 소모)",
          'icon': Icons.directions_bike,
        },
        {
          'type': '운동',
          'suggestion': "HIIT(고강도 인터벌 트레이닝) 20분",
          'icon': Icons.accessibility,
        },
        {
          'type': '식단',
          'suggestion': "가벼운 야채 샐러드와 올리브유 드레싱으로 식사량 줄이기",
          'icon': Icons.restaurant,
        },
        {
          'type': '식단',
          'suggestion': "닭가슴살, 고등어 등 기름진 음식 대신 담백한 단백질 섭취",
          'icon': Icons.fastfood,
        },
        {
          'type': '식단',
          'suggestion': "간식으로 과일 대신 채소 스틱 섭취",
          'icon': Icons.local_grocery_store,
        },
        {
          'type': '식단',
          'suggestion': "물을 충분히 마셔 포만감 느끼기",
          'icon': Icons.local_drink,
        },
      ];
      break;
    case "탄수화물":
      suggestions = [
        {
          'type': '운동',
          'suggestion': "유산소 운동: 조깅 또는 자전거 타기 30분",
          'icon': Icons.directions_run,
        },
        {
          'type': '운동',
          'suggestion': "줄넘기 15분",
          'icon': Icons.sports_handball,
        },
        {
          'type': '운동',
          'suggestion': "복근 운동: 크런치, 레그레이즈 10분",
          'icon': Icons.fitness_center,
        },
        {
          'type': '운동',
          'suggestion': "스텝업 운동 20분",
          'icon': Icons.directions_walk,
        },
        {
          'type': '식단',
          'suggestion': "밥 대신 현미밥 또는 찹쌀밥으로 대체",
          'icon': Icons.rice_bowl,
        },
        {
          'type': '식단',
          'suggestion': "정제된 탄수화물 대신 귀리, 고구마 등의 통곡물 섭취",
          'icon': Icons.local_dining,
        },
        {
          'type': '식단',
          'suggestion': "가공된 빵 대신 통밀빵이나 쌀국수 등 자연식으로 대체",
          'icon': Icons.food_bank,
        },
        {
          'type': '식단',
          'suggestion': "배고픔을 느낄 때 과일 대신 채소를 섭취하여 탄수화물 감소",
          'icon': Icons.agriculture,
        },
      ];
      break;
    case "단백질":
      suggestions = [
        {
          'type': '운동',
          'suggestion': "근력 운동: 덤벨을 이용한 상체 운동 20분",
          'icon': Icons.fitness_center,
        },
        {
          'type': '운동',
          'suggestion': "요가나 필라테스 30분",
          'icon': Icons.self_improvement,
        },
        {
          'type': '운동',
          'suggestion': "서킷 트레이닝: 전신 운동 30분",
          'icon': Icons.loop,
        },
        {
          'type': '운동',
          'suggestion': "스트레칭으로 근육 이완",
          'icon': Icons.spa,
        },
        {
          'type': '식단',
          'suggestion': "식물성 단백질 대체: 두부, 콩 등 섭취",
          'icon': Icons.fastfood,
        },
        {
          'type': '식단',
          'suggestion': "지방이 적은 고기 선택: 닭가슴살, 고등어, 연어 등",
          'icon': Icons.local_dining,
        },
        {
          'type': '식단',
          'suggestion': "식사 시 단백질 비율을 높이고 탄수화물은 줄여 균형 잡힌 식사",
          'icon': Icons.restaurant,
        },
        {
          'type': '식단',
          'suggestion': "운동 후 단백질 쉐이크나 계란 흰자 섭취",
          'icon': Icons.local_drink,
        },
      ];
      break;
    case "지방":
      suggestions = [
        {
          'type': '운동',
          'suggestion': "고강도 유산소 운동 (달리기, 자전거 타기, 수영 등)으로 지방 연소 촉진",
          'icon': Icons.run_circle,
        },
        {
          'type': '운동',
          'suggestion': "전신 근력 운동: 스쿼트, 데드리프트 30분",
          'icon': Icons.fitness_center,
        },
        {
          'type': '운동',
          'suggestion': "복합 운동: 푸시업과 스쿼트를 번갈아 가며 15분",
          'icon': Icons.fitness_center,
        },
        {
          'type': '운동',
          'suggestion': "HIIT 운동 20분",
          'icon': Icons.accessibility,
        },
        {
          'type': '식단',
          'suggestion': "포화지방을 줄이기 위해 기름진 음식 대신 올리브유, 아보카도 사용",
          'icon': Icons.restaurant,
        },
        {
          'type': '식단',
          'suggestion': "튀긴 음식 대신 찜, 구이 요리로 조리 방법 변경",
          'icon': Icons.kitchen,
        },
        {
          'type': '식단',
          'suggestion': "간식으로 견과류(아몬드, 호두)와 아보카도를 섭취",
          'icon': Icons.nature_people,
        },
        {
          'type': '식단',
          'suggestion': "저지방 요거트나 스무디로 간식 대체",
          'icon': Icons.local_cafe,
        },
      ];
      break;
  }
  return suggestions;
}
