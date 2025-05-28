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
  
  @override
  Widget build(BuildContext context) {
    return NotificationHandler( // Only one at root level
      child: MaterialApp(
        title: "Facegram",
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        initialRoute: "/login",
        routes: {
          "/login": (_) => LoginScreen(),
          "/signup": (_) => SignupScreen(),
          "/home": (_) => HomeScreen(),
          '/profile': (_) => ProfileScreen(),
          '/friends': (_) => PotentialFriendsScreen(),
          "/contacts": (_) => ContactsScreen(),
          "/notifications": (_) => NotificationsScreen(),
          "/create-post": (_) => CreatePostScreen(),
          "/admin-dashboard":(_)=> AdminDashboard()
        },
      ),
    );
  }
}