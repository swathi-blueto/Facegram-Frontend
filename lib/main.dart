import "package:project/handlers/notificaton_handler.dart";
import "package:project/screens/admin_dashboard.dart";
import "package:project/screens/contact_screen.dart";
import "package:project/screens/createpost_screen.dart";
import "package:project/screens/home_screen.dart";
import "package:project/screens/login_screen.dart";
import "package:project/screens/notification_screen.dart";
import "package:project/screens/potential_friends_screen.dart";
import "package:project/screens/profile_screen.dart";
import "package:project/screens/signup_screen.dart";
import "package:flutter/material.dart";
import "package:project/services/notification_service.dart";
import "package:project/services/auth_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://oegotgnjkfhxgsuhwpss.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9lZ290Z25qa2ZoeGdzdWh3cHNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5OTEyNzQsImV4cCI6MjA2MTU2NzI3NH0.hr8ohcQzjNxoEBye4iJppXbC7KrRQxxcOhvIf78x-vo',
  );

  await NotificationService().initLocalNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final Set<String> _authenticatedRoutes = const {
    '/home',
    '/profile',
    '/friends',
    '/contacts',
    '/notifications',
    '/create-post',
    '/admin-dashboard',
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Facegram",
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      onGenerateRoute: (settings) {
        Widget screen;
        switch (settings.name) {
          case "/login":
            screen = LoginScreen();
            break;
          case "/signup":
            screen = SignupScreen();
            break;
          case "/home":
            screen = HomeScreen();
            break;
          case '/profile':
            screen = ProfileScreen();
            break;
          case '/friends':
            screen = PotentialFriendsScreen();
            break;
          case "/contacts":
            screen = ContactsScreen();
            break;
          case "/notifications":
            screen = NotificationsScreen();
            break;
          case "/create-post":
            screen = CreatePostScreen();
            break;
          case "/admin-dashboard":
            screen = AdminDashboard();
            break;
          default:
            screen = LoginScreen();
        }

        if (_authenticatedRoutes.contains(settings.name)) {
          return MaterialPageRoute(
            builder: (_) => FutureBuilder(
              future: AuthService.getCurrentUserId(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return NotificationHandler(child: screen);
                }
                return screen;
              },
            ),
          );
        } else {
          return MaterialPageRoute(builder: (_) => screen);
        }
      },
    );
  }
}
