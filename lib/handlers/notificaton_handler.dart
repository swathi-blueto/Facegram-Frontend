import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/notification_service.dart';

class NotificationHandler extends StatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> with WidgetsBindingObserver {
  StreamSubscription? _notificationSubscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _initializeNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel(); 
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeNotificationListener(); 
    }
  }

  Future<void> _initializeNotificationListener() async {
    final userId = await AuthService.getCurrentUserId();


    if (userId == _currentUserId) {
      return;
    }

    
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;

    if (userId == null) {
     
      _currentUserId = null;
      return;
    }

   
    _currentUserId = userId;

    final notificationService = NotificationService();
    _notificationSubscription = notificationService
        .setupGlobalRealtimeListener(userId)
        .listen((notifications) {
    
    }, onError: (error) {
      debugPrint("Error in global realtime listener: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}