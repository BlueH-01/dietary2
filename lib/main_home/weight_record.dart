import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WeightRecordScreen extends StatefulWidget {
  const WeightRecordScreen({super.key});

  @override
  State<WeightRecordScreen> createState() => _WeightRecordScreenState();
}

class _WeightRecordScreenState extends State<WeightRecordScreen> {
  final Map<String, double> _weightData = {}; // 날짜별 몸무게 저장
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  late String selectedDateStr; // 날짜 문자열 변수

  @override
  void initState() {
    super.initState();
    selectedDateStr = _dateFormat.format(DateTime.now()); // 초기 날짜는 오늘로 설정
  }

  Future<void> _showWeightInputDialog() async {
    final TextEditingController weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    selectedDateStr = _dateFormat.format(selectedDate); // 초기 날짜 설정

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
                      Text('날짜: $selectedDateStr'),
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
                              selectedDateStr = _dateFormat
                                  .format(selectedDate); // 선택한 날짜 업데이트
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
                    color: Color.fromARGB(255, 132, 195, 135)), // 취소 버튼 색상
              ),
            ),
            TextButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                if (weight != null) {
                  setState(() {
                    _weightData[selectedDateStr] = weight;

                    // 7일 이전 데이터 삭제
                    final DateTime now = DateTime.now();
                    _weightData.removeWhere((key, value) {
                      final date = _dateFormat.parse(key);
                      return now.difference(date).inDays > 7;
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                '저장',
                style: TextStyle(
                    color: Color.fromARGB(255, 132, 195, 135)), // 저장 버튼 색상
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 그래프의 데이터 목록을 정렬
    final sortedWeightData = _weightData.entries.toList()
      ..sort((a, b) =>
          _dateFormat.parse(a.key).compareTo(_dateFormat.parse(b.key)));

    // 최소 및 최대 날짜 설정
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
                    const SizedBox(height: 20), // 제목과 그래프 사이 간격 추가
                    const Center(
                      // Center 위젯으로 감싸서 가운데 배치
                      child: Text(
                        '체중 변화 기록',
                        style: TextStyle(
                          fontSize: 24, // 크기 증가
                          fontWeight: FontWeight.bold, // 굵게
                          color: Color.fromARGB(255, 132, 195, 135), // 색상 설정
                        ),
                      ),
                    ),
                    const SizedBox(height: 36), // 제목과 그래프 사이 간격 추가
                    SizedBox(
                      height: 400, // 그래프의 높이를 적절히 조정합니다.
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          // X축을 DateTimeAxis로 설정
                          dateFormat: DateFormat('MM/dd'), // 날짜 형식
                          minimum: minDate, // 최소 날짜 설정
                          maximum: maxDate, // 최대 날짜 설정
                          labelFormat: '{value}', // 날짜 레이블 형식
                        ),
                        primaryYAxis: NumericAxis(
                          // Y축 설정
                          majorGridLines: const MajorGridLines(
                            width: 0, // 격자선의 너비를 0으로 설정하여 숨김
                          ),
                        ),
                        series: <LineSeries<MapEntry<String, double>,
                            DateTime>>[
                          LineSeries<MapEntry<String, double>, DateTime>(
                            dataSource: sortedWeightData,
                            xValueMapper: (entry, _) =>
                                _dateFormat.parse(entry.key), // DateTime으로 변환
                            yValueMapper: (entry, _) => entry.value,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.top,
                              labelIntersectAction: LabelIntersectAction.none,
                            ),
                          ),
                        ],
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePanning: true,
                          enablePinching: true,
                        ),
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
