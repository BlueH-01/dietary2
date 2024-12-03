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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '음식 등록',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField('음식 이름', nameController,
                    icon: Icons.restaurant),
                _buildInputField('칼로리(kcal)', caloriesController,
                    isNumeric: true, icon: Icons.fitness_center),
                _buildInputField('탄수화물 (g)', carbsController,
                    isNumeric: true, icon: Icons.rice_bowl),
                _buildInputField('단백질 (g)', proteinController,
                    isNumeric: true, icon: Icons.accessibility),
                _buildInputField('지방 (g)', fatController,
                    isNumeric: true, icon: Icons.local_pizza),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('취소 확인'),
                              content: const Text(
                                  '정말로 취소하시겠습니까? 입력한 정보는 저장되지 않습니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('아니요',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // 팝업 닫기
                                    Navigator.pop(context); // 다이얼로그 닫기
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 118, 193, 120),
                                  ),
                                  child: const Text('예',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color.fromARGB(255, 118, 193, 120),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
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
                      child: const Text(
                        '등록',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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

  Widget _buildInputField(String labelText, TextEditingController controller,
      {bool isNumeric = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: '입력하세요',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.green)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '음식 등록',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 118, 193, 120),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '음식을 검색하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('foods').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('등록된 음식이 없습니다.'));
                }

                final foodList = snapshot.data!.docs;

                final filteredList = foodList
                    .where((doc) =>
                    (doc.data() as Map<String, dynamic>)['name']
                        .toString()
                        .toLowerCase()
                        .contains(_searchText))
                    .toList();

                final favoriteList = filteredList
                    .where((doc) =>
                (doc.data() as Map<String, dynamic>)['favorite'] ==
                    true)
                    .toList();

                final nonFavoriteList = filteredList
                    .where((doc) =>
                (doc.data() as Map<String, dynamic>)['favorite'] ==
                    false)
                    .toList();

                final sortedList = [...favoriteList, ...nonFavoriteList];

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    final food =
                    sortedList[index].data() as Map<String, dynamic>;
                    final doc = sortedList[index];

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, {
                            'name': food['name'],
                            'calories': food['calories'],
                            'carbs': food['carbs'],
                            'protein': food['protein'],
                            'fat': food['fat'],
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              food['name'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '칼로리: ${food['calories']}kcal',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 0.5),
                            Text(
                              '탄수화물: ${food['carbs']}g',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 0.5),
                            Text(
                              '단백질: ${food['protein']}g',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 0.5),
                            Text(
                              '지방: ${food['fat']}g',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    food['favorite']
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: food['favorite']
                                        ? Colors.yellow
                                        : Colors.grey,
                                  ),
                                  onPressed: () => _toggleFavorite(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color:
                                      Color.fromARGB(255, 201, 201, 201)),
                                  onPressed: () async {
                                    try {
                                      await _firestore
                                          .collection('foods')
                                          .doc(doc.id)
                                          .delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('음식이 삭제되었습니다.')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('삭제 실패: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: const Color.fromARGB(255, 118, 193, 120),
        child: const Icon(Icons.add),
      ),
    );
  }
}
