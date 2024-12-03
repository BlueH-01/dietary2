import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietaryScreen extends StatefulWidget {
  const DietaryScreen({super.key});

  @override
  State<DietaryScreen> createState() => _DietaryScreenState();
}

class _DietaryScreenState extends State<DietaryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _searchText = ""; // 검색어 상태 변수

  // 공통적으로 사용되는 컬렉션 이름 정의
  final String collectionName = 'foods';
  // 개인 User가 사용하는 FavoriteFoods 컬렉션
  final String userFavoritesCollectionName = 'favorites';

  // 새로운 음식 추가
  Future<void> _addFood(Map<String, dynamic> food) async {
    try {
      await _firestore.collection(collectionName).add(food);
      _showSnackbar('음식이 성공적으로 등록되었습니다!');
    } catch (e) {
      _showSnackbar('등록 실패: $e');
    }
  }

  // 음식 등록 다이얼로그 표시
  void _showAddFoodDialog() {
    final fields = [
      {'label': '음식 이름', 'icon': Icons.restaurant, 'isNumeric': false},
      {'label': '칼로리(kcal)', 'icon': Icons.fitness_center, 'isNumeric': true},
      {'label': '탄수화물 (g)', 'icon': Icons.rice_bowl, 'isNumeric': true},
      {'label': '단백질 (g)', 'icon': Icons.accessibility, 'isNumeric': true},
      {'label': '지방 (g)', 'icon': Icons.local_pizza, 'isNumeric': true},
    ];

    final controllers = fields.map((field) => TextEditingController()).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                ...fields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;
                  return _buildInputField(
                    field['label'] as String,
                    controllers[index],
                    isNumeric: field['isNumeric'] as bool,
                    icon: field['icon'] as IconData?,
                  );
                }),
                const SizedBox(height: 20),
                _buildDialogActions(controllers),
              ],
            ),
          ),
        );
      },
    );
  }

  // 입력 필드 생성
  Widget _buildInputField(String labelText, TextEditingController controller,
      {bool isNumeric = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: '입력하세요',
          prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // 다이얼로그 버튼 생성
  Widget _buildDialogActions(List<TextEditingController> controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          child: const Text('취소', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (controllers.any((controller) => controller.text.isEmpty)) {
              _showSnackbar('모든 필드를 입력하세요');
              return;
            }
            try {
              final newFood = {
                'name': controllers[0].text,
                'calories': int.parse(controllers[1].text),
                'carbs': double.parse(controllers[2].text),
                'protein': double.parse(controllers[3].text),
                'fat': double.parse(controllers[4].text),
                'favorite': false,
              };
              _addFood(newFood);
              Navigator.pop(context);
            } catch (e) {
              _showSnackbar('숫자를 입력하세요');
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.green,
          ),
          child: const Text('등록', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Snackbar 표시
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // 검색어를 소문자로 저장
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // food 컬렉션에서 데이터 가져오기
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

                // 즐겨찾기를 먼저 정렬하기 위해 FutureBuilder 사용
                return FutureBuilder<List<DocumentSnapshot>>(
                  future: _sortFavoritesFirst(filteredList), // 즐겨찾기 우선 정렬
                  builder: (context, sortedSnapshot) {
                    if (sortedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 즐겨찾기 항목 먼저 표시
                    final sortedList = sortedSnapshot.data ?? [];

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // FutureBuilder 추가
                                    FutureBuilder<bool>(
                                      future: _isFavorite(
                                          food['name']), // 즐겨찾기 여부 확인
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Icon(
                                            Icons.star_border,
                                            color: Colors.grey, // 로딩 중 기본 색상
                                          );
                                        }

                                        if (snapshot.hasError) {
                                          return const Icon(
                                            Icons.error,
                                            color: Colors.red, // 오류 발생 시
                                          );
                                        }

                                        final isFavorite =
                                            snapshot.data ?? false;

                                        return IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: isFavorite
                                                ? Colors.yellow
                                                : Colors.grey,
                                          ),
                                          onPressed: () =>
                                              _toggleFavorite(food['name']),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color:
                                            Color.fromARGB(255, 201, 201, 201),
                                      ),
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
                                            SnackBar(
                                                content: Text('삭제 실패: $e')),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<DocumentSnapshot>> _sortFavoritesFirst(
      List<DocumentSnapshot> foodList) async {
    final favorites = <DocumentSnapshot>[]; // 즐겨찾기 목록
    final nonFavorites = <DocumentSnapshot>[]; // 비즐겨찾기 목록

    for (final foodDoc in foodList) {
      final isFavorite = await _isFavorite((foodDoc.data()
          as Map<String, dynamic>)['name']); // 음식 이름으로 즐겨찾기 여부 확인
      if (isFavorite) {
        favorites.add(foodDoc);
      } else {
        nonFavorites.add(foodDoc);
      }
    }

    // 즐겨찾기 항목을 먼저 배치한 리스트 반환
    return [...favorites, ...nonFavorites];
  }

// 특정 음식이 즐겨찾기인지 확인
  Future<bool> _isFavorite(String foodName) async {
    final favoriteDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(foodName)
        .get();
    return favoriteDoc.exists; // 문서가 존재하면 즐겨찾기 상태
  }

// 즐겨찾기 토글 함수
  Future<void> _toggleFavorite(String foodName) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(foodName); // 음식 이름을 문서 ID로 사용

    final doc = await docRef.get();
    if (doc.exists) {
      // 문서가 존재하면 삭제 (즐겨찾기 해제)
      await docRef.delete();
    } else {
      // 문서가 없으면 추가 (즐겨찾기 추가)
      await docRef.set({});
    }
    setState(() {}); // UI 업데이트
  }
}
