import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class LocationReminderService {
  LocationReminderService._();

  static final LocationReminderService instance = LocationReminderService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // iOS setup
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await init();

    // iOS notificações
    await _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Localização
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> checkNearbyTasks(BuildContext context) async {
    try {
      await _requestPermissions();

      // Posição atual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final List<Task> tasks = taskProvider.tasks;

      // Filtra tasks com localização + lembrete ativo + não concluídas
      final candidates = tasks.where((t) =>
      t.location != null &&
          t.locationReminderEnabled &&
          !t.isDone);

      const radiusMeters = 200.0; // 200 metros

      for (final task in candidates) {
        final loc = task.location!;
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          loc.latitude,
          loc.longitude,
        );

        if (distance <= radiusMeters) {
          await _showLocationNotification(task, distance.round());
        }
      }
    } catch (e) {
      debugPrint('Erro no checkNearbyTasks: $e');
    }
  }

  Future<void> _showLocationNotification(Task task, int distanceMeters) async {
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(iOS: iosDetails);

    await _notifications.show(
      task.hashCode, // ID único por task
      '📍 ${task.title}',
      'Estás a ${distanceMeters}m de "${task.locationName ?? 'esta localização'}"',
      details,
    );
  }
}
