import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Singleton pattern sesuai dengan instruksi modul
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Inisialisasi zona waktu agar tidak ada error konversi waktu
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // 2. Konfigurasi Android
    // (Perbaikan: Menggunakan 'ic_launcher' tanpa '@mipmap/' agar tidak NullPointerException)
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);
    await notificationPlugin.initialize(settings:  initSettings);

    // 3. Meminta izin dan membuat Notification Channel[cite: 1]
    final androidPlatform = notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminder Notifications',
      description: 'Channel for notification reminders',
      importance: Importance.high,
    );
    await androidPlatform?.createNotificationChannel(channel);
  }

  // Fungsi untuk Immediate Notification: muncul secara langsung saat dipanggil[cite: 1]
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    print('Menampilkan notifikasi instan: $title - $body');
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notifDetails = NotificationDetails(android: androidDetails);

    await notificationPlugin.show(
        id: 0, title:  title, body:  body, notificationDetails:  notifDetails);
  }

  // Fungsi untuk Scheduled Notification: muncul pada waktu yang telah ditentukan[cite: 1]
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notifDetails = NotificationDetails(android: androidDetails);

    await notificationPlugin.zonedSchedule(
      id: id,
      title:  title,
      body:  body,
      // Membuat TZDateTime langsung dari komponen waktu[cite: 1]
      scheduledDate: tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ),
      notificationDetails:  notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> requestPermission() async {
    final androidPlatform = notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.requestNotificationsPermission();
  }

}