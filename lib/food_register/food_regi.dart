import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietaryScreen extends StatefulWidget {
  const DietaryScreen({super.key});

  @override
  _DietaryScreenState createState() => _DietaryScreenState();
}

class _DietaryScreenState extends State<DietaryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchText = ""; // 검색어 상태 변수

  void _addFood(Map<String, dynamic> food) async {
    try {
      await _firestore.collection('foods').add(food);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음식이 성공적으로 등록되었습니다!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $e')),
      );
    }
  }

  void _toggleFavorite(DocumentSnapshot doc) async {
    try {
      final currentFavorite = doc['favorite'] as bool;
      await _firestore
          .collection('foods')
          .doc(doc.id)
          .update({'favorite': !currentFavorite});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('즐겨찾기 토글 실패: $e')),
      );
    }
  }

  void _showAddFoodDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController carbsController = TextEditingController();
    final TextEditingController proteinController = TextEditingController();
    final TextEditingController fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '음식 등록',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField('음식 이름', nameController),
                _buildInputField('칼로리(kcal)', caloriesController,
                    isNumeric: true),
                _buildInputField('탄수화물 (g)', carbsController, isNumeric: true),
                _buildInputField('단백질 (g)', proteinController, isNumeric: true),
                _buildInputField('지방 (g)', fatController, isNumeric: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            caloriesController.text.isEmpty ||
                            carbsController.text.isEmpty ||
                            proteinController.text.isEmpty ||
                            fatController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('모든 필드를 입력하세요')),
                          );
                          return;
                        }

                        try {
                          final newFood = {
                            'name': nameController.text,
                            'calories': int.parse(caloriesController.text),
                            'carbs': double.parse(carbsController.text),
                            'protein': double.parse(proteinController.text),
                            'fat': double.parse(fatController.text),
                            'favorite': false,
                          };
                          _addFood(newFood);
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('숫자를 입력하세요')),
                          );
                        }
                      },
                      child: const Text('등록'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '음식 등록',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '음식을 검색하세요...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('foods').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('등록된 음식이 없습니다.'));
          }

          final foodList = snapshot.data!.docs;

          // 검색 결과 필터링
          final filteredList = foodList
              .where((doc) => (doc.data() as Map<String, dynamic>)['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchText))
              .toList();

          // 즐겨찾기 항목과 비즐겨찾기 항목 분리
          final favoriteList = filteredList
              .where((doc) =>
                  (doc.data() as Map<String, dynamic>)['favorite'] == true)
              .toList();

          final nonFavoriteList = filteredList
              .where((doc) =>
                  (doc.data() as Map<String, dynamic>)['favorite'] == false)
              .toList();

          // 즐겨찾기 항목 먼저 표시
          final sortedList = [...favoriteList, ...nonFavoriteList];

          return ListView.builder(
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final food = sortedList[index].data() as Map<String, dynamic>;
              final doc = sortedList[index];

              return ListTile(
                title: Text(food['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '칼로리: ${food['calories']}kcal, 탄수화물: ${food['carbs']}g',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '단백질: ${food['protein']}g, 지방: ${food['fat']}g',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        food['favorite'] ? Icons.star : Icons.star_border,
                        color: food['favorite'] ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Color.fromARGB(255, 213, 232, 210)),
                      onPressed: () async {
                        try {
                          await _firestore
                              .collection('foods')
                              .doc(doc.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('음식이 삭제되었습니다.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context, {
                    'name': food['name'],
                    'calories': food['calories'],
                    'carbs': food['carbs'],
                    'protein': food['protein'],
                    'fat': food['fat'],
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
