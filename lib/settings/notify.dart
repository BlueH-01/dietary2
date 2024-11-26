import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  bool OnNotificationB = true;
  bool OnNotificationL = true;
  bool OnNotificationD = true;

  @override
  void initState() {
    super.initState();
    FlutterLocalNotification.init();
    tz.initializeTimeZones();
    FlutterLocalNotification.requestNotificationPermission();
  }

  Future<void> _selectTime(BuildContext context, String t) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && t == "breakfast") {
      setState(() {
        _selectedTimeBreakfast = picked;
        _isNotificationEnabledBreakfast = true;
      });
      FlutterLocalNotification.scheduleNotification(picked, 0);
    } else if (picked != null && t == "lunch") {
      setState(() {
        _selectedTimeLunch = picked;
        _isNotificationEnabledLunch = true;
      });
      FlutterLocalNotification.scheduleNotification(picked, 1);
    } else if (picked != null && t == "dinner") {
      setState(() {
        _selectedTimeDinner = picked;
        _isNotificationEnabledDinner = true;
      });
      FlutterLocalNotification.scheduleNotification(picked, 3);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("식사 알림 설정"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 125.0,
                    height: 60.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 25.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "아침 식사",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _selectTime(context, "breakfast");
                    },
                    icon: const Icon(Icons.edit, color: Colors.grey),
                  ),
                  SizedBox(
                    child: _selectedTimeBreakfast != null && OnNotificationB
                        ? Text(
                            '${_selectedTimeBreakfast!.format(context)}',
                            style: const TextStyle(fontSize: 18),
                          )
                        : Container(
                            child: Text(
                              "알림 없음",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isNotificationEnabledBreakfast =
                            !_isNotificationEnabledBreakfast;

                        if (_selectedTimeBreakfast != null) {
                          TimeOfDay time = _selectedTimeBreakfast as TimeOfDay;

                          if (_isNotificationEnabledBreakfast) {
                            FlutterLocalNotification.scheduleNotification(
                                time, 0);
                            OnNotificationB = true;
                          } else {
                            FlutterLocalNotification
                                .flutterLocalNotificationsPlugin
                                .cancel(0);
                            OnNotificationB = false;
                          }
                        }
                      });
                    },
                    icon: Icon(
                      _isNotificationEnabledBreakfast
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 125.0,
                    height: 60.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 25.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "점심 식사",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _selectTime(context, "lunch");
                    },
                    icon: const Icon(Icons.edit, color: Colors.grey),
                  ),
                  SizedBox(
                    child: _selectedTimeLunch != null && OnNotificationL
                        ? Text(
                            '${_selectedTimeLunch!.format(context)}',
                            style: const TextStyle(fontSize: 18),
                          )
                        : Container(
                            child: Text(
                              "알림 없음",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isNotificationEnabledLunch =
                            !_isNotificationEnabledLunch;

                        if (_selectedTimeLunch != null) {
                          TimeOfDay time = _selectedTimeLunch as TimeOfDay;

                          if (_isNotificationEnabledLunch) {
                            FlutterLocalNotification.scheduleNotification(
                                time, 1);
                            OnNotificationL = true;
                          } else {
                            FlutterLocalNotification
                                .flutterLocalNotificationsPlugin
                                .cancel(1);
                            OnNotificationL = false;
                          }
                        }
                      });
                    },
                    icon: Icon(
                      _isNotificationEnabledLunch
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 125.0,
                    height: 60.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 25.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "저녁 식사",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _selectTime(context, "dinner");
                    },
                    icon: const Icon(Icons.edit, color: Colors.grey),
                  ),
                  SizedBox(
                    child: _selectedTimeDinner != null && OnNotificationD
                        ? Text(
                            '${_selectedTimeDinner!.format(context)}',
                            style: const TextStyle(fontSize: 18),
                          )
                        : Container(
                            child: Text(
                              "알림 없음",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isNotificationEnabledDinner =
                            !_isNotificationEnabledDinner;

                        if (_selectedTimeDinner != null) {
                          TimeOfDay time = _selectedTimeDinner as TimeOfDay;

                          if (_isNotificationEnabledDinner) {
                            FlutterLocalNotification.scheduleNotification(
                                time, 2);
                            OnNotificationD = true;
                          } else {
                            FlutterLocalNotification
                                .flutterLocalNotificationsPlugin
                                .cancel(2);
                            OnNotificationD = false;
                          }
                        }
                      });
                    },
                    icon: Icon(
                      _isNotificationEnabledDinner
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

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

  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
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
      scheduledDate = scheduledDate.add(Duration(days: 1));
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
