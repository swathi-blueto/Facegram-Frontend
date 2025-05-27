import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/notification_service.dart';

class NotificationHandler extends StatefulWidget {
  final Widget child;
  
  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  late StreamSubscription _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  void _setupRealtimeListener() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return;

    final notificationService = NotificationService();
    _notificationSubscription = notificationService
      .setupGlobalRealtimeListener(userId)
      .listen((notifications) {
       
      });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

