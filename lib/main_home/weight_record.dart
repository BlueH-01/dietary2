import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeightRecordScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId; // 현재 사용자 ID

  const WeightRecordScreen({
    super.key,
    required this.firestore,
    required this.userId,
  });

  @override
  State<WeightRecordScreen> createState() => _WeightRecordScreenState();
}

class _WeightRecordScreenState extends State<WeightRecordScreen> {
  final Map<String, double> _weightData = {}; // 날짜별 몸무게 저장
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  late String _selectedDateStr;

  @override
  void initState() {
    super.initState();
    _selectedDateStr = _dateFormat.format(DateTime.now());
    _loadWeightData(); // Firestore에서 데이터 로드
  }

  Future<void> _loadWeightData() async {
    try {
      final snapshot = await widget.firestore
          .collection('users')
          .doc(widget.userId)
          .collection('daily_weight')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _weightData.clear();
          for (var doc in snapshot.docs) {
            final date = doc.id; // 문서 ID를 날짜로 사용
            final weight = doc['weight'] as double; // weight 필드
            _weightData[date] = weight;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading weight data: $e');
    }
  }

  Future<void> _saveWeightData(String date, double weight) async {
    try {
      await widget.firestore
          .collection('users')
          .doc(widget.userId)
          .collection('daily_weight')
          .doc(date)
          .set({'weight': weight});

      debugPrint('Weight data saved for $date: $weight');
    } catch (e) {
      debugPrint('Error saving weight data: $e');
    }
  }

  Future<void> _showWeightInputDialog() async {
    final TextEditingController weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    _selectedDateStr = _dateFormat.format(selectedDate);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('몸무게 입력'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('날짜: $_selectedDateStr'),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              _selectedDateStr =
                                  _dateFormat.format(selectedDate);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '몸무게 (kg)'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color.fromARGB(255, 132, 195, 135),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                if (weight != null) {
                  setState(() {
                    _weightData[_selectedDateStr] = weight;
                  });
                  _saveWeightData(_selectedDateStr, weight); // Firestore에 저장
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                '저장',
                style: TextStyle(
                  color: Color.fromARGB(255, 132, 195, 135),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedWeightData = _weightData.entries.toList()
      ..sort((a, b) =>
          _dateFormat.parse(a.key).compareTo(_dateFormat.parse(b.key)));

    DateTime minDate = sortedWeightData.isNotEmpty
        ? _dateFormat.parse(sortedWeightData.first.key)
        : DateTime.now();
    DateTime maxDate = sortedWeightData.isNotEmpty
        ? _dateFormat.parse(sortedWeightData.last.key)
        : DateTime.now();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _weightData.isEmpty
              ? const Center(
                  child: Text(
                    '몸무게를 입력해 변화를 한눈에 확인하세요!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        '체중 변화 기록',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 132, 195, 135),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      height: 400,
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          dateFormat: DateFormat('MM/dd'),
                          minimum: minDate,
                          maximum: maxDate,
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        series: <LineSeries<MapEntry<String, double>, DateTime>>[
                          LineSeries<MapEntry<String, double>, DateTime>(
                            dataSource: sortedWeightData,
                            xValueMapper: (entry, _) =>
                                _dateFormat.parse(entry.key),
                            yValueMapper: (entry, _) => entry.value,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.top,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showWeightInputDialog,
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        child: const Icon(Icons.add),
      ),
    );
  }
}
