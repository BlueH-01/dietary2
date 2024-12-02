import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService extends StatefulWidget {
  const NotificationService({super.key});

  @override
  State<NotificationService> createState() => _NotificationServiceState();
}

class _NotificationServiceState extends State<NotificationService> {
  TimeOfDay? _selectedTimeBreakfast;
  TimeOfDay? _selectedTimeLunch;
  TimeOfDay? _selectedTimeDinner;

  bool _isNotificationEnabledBreakfast = false;
  bool _isNotificationEnabledLunch = false;
  bool _isNotificationEnabledDinner = false;

  @override
  void initState() {
    super.initState();
    FlutterLocalNotification.init();
    tz.initializeTimeZones();
    FlutterLocalNotification.requestNotificationPermission();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _selectedTimeBreakfast =
          _getTimeOfDayFromString(prefs.getString('breakfastTime'));
      _selectedTimeLunch =
          _getTimeOfDayFromString(prefs.getString('lunchTime'));
      _selectedTimeDinner =
          _getTimeOfDayFromString(prefs.getString('dinnerTime'));

      _isNotificationEnabledBreakfast =
          prefs.getBool('isNotificationEnabledBreakfast') ?? false;
      _isNotificationEnabledLunch =
          prefs.getBool('isNotificationEnabledLunch') ?? false;
      _isNotificationEnabledDinner =
          prefs.getBool('isNotificationEnabledDinner') ?? false;
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        'breakfastTime', _selectedTimeBreakfast?.format(context) ?? '');
    await prefs.setString(
        'lunchTime', _selectedTimeLunch?.format(context) ?? '');
    await prefs.setString(
        'dinnerTime', _selectedTimeDinner?.format(context) ?? '');

    await prefs.setBool(
        'isNotificationEnabledBreakfast', _isNotificationEnabledBreakfast);
    await prefs.setBool(
        'isNotificationEnabledLunch', _isNotificationEnabledLunch);
    await prefs.setBool(
        'isNotificationEnabledDinner', _isNotificationEnabledDinner);
  }

  TimeOfDay? _getTimeOfDayFromString(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }
    final format = DateFormat.jm(); //"6:00 AM"
    final time = format.parse(timeString);
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Future<void> _selectTime(BuildContext context, String t) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (t == "breakfast") {
          _selectedTimeBreakfast = picked;
          _isNotificationEnabledBreakfast = true;
        } else if (t == "lunch") {
          _selectedTimeLunch = picked;
          _isNotificationEnabledLunch = true;
        } else if (t == "dinner") {
          _selectedTimeDinner = picked;
          _isNotificationEnabledDinner = true;
        }
        _saveNotificationSettings();
      });
      FlutterLocalNotification.scheduleNotification(
          picked, t == "breakfast" ? 0 : (t == "lunch" ? 1 : 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("식사 알림 설정",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNotificationRow("아침 식사", "breakfast",
                  _selectedTimeBreakfast, _isNotificationEnabledBreakfast, 0),
              const SizedBox(height: 40),
              _buildNotificationRow("점심 식사", "lunch", _selectedTimeLunch,
                  _isNotificationEnabledLunch, 1),
              const SizedBox(height: 40),
              _buildNotificationRow("저녁 식사", "dinner", _selectedTimeDinner,
                  _isNotificationEnabledDinner, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationRow(String title, String type,
      TimeOfDay? selectedTime, bool isEnabled, int id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 125.0,
          height: 60.0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 132, 195, 135),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _selectTime(context, type);
          },
          icon: const Icon(Icons.edit, color: Colors.grey),
        ),
        SizedBox(
          child: selectedTime != null && isEnabled
              ? Text(
                  selectedTime.format(context),
                  style: const TextStyle(fontSize: 18),
                )
              : const Text(
                  "알림 없음",
                  style: TextStyle(fontSize: 18),
                ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () {
            setState(() {
              if (type == "breakfast") {
                _isNotificationEnabledBreakfast =
                    !_isNotificationEnabledBreakfast;
              } else if (type == "lunch") {
                _isNotificationEnabledLunch = !_isNotificationEnabledLunch;
              } else if (type == "dinner") {
                _isNotificationEnabledDinner = !_isNotificationEnabledDinner;
              }
              if (selectedTime != null) {
                if (type == "breakfast") {
                  if (_isNotificationEnabledBreakfast) {
                    FlutterLocalNotification.scheduleNotification(
                        selectedTime, 0);
                  } else {
                    FlutterLocalNotification.flutterLocalNotificationsPlugin
                        .cancel(0);
                  }
                } else if (type == "lunch") {
                  if (_isNotificationEnabledLunch) {
                    FlutterLocalNotification.scheduleNotification(
                        selectedTime, 1);
                  } else {
                    FlutterLocalNotification.flutterLocalNotificationsPlugin
                        .cancel(1);
                  }
                } else if (type == "dinner") {
                  if (_isNotificationEnabledDinner) {
                    FlutterLocalNotification.scheduleNotification(
                        selectedTime, 2);
                  } else {
                    FlutterLocalNotification.flutterLocalNotificationsPlugin
                        .cancel(2);
                  }
                }
                _saveNotificationSettings();
              }
            });
          },
          icon: Icon(
            isEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: Colors.black,
            size: 40,
          ),
        ),
      ],
    );
  }
}

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> scheduleNotification(TimeOfDay time, int id) async {
    final now = DateTime.now();

    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '예약된 알림',
      '식사 시간입니다!',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
