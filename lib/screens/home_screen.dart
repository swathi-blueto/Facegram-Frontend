import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/models/user_profile.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/notification_service.dart';
import 'package:project/services/user_service.dart';
import 'package:project/widgets/home/badgedicon.dart';
import 'package:project/widgets/home/bottombar.dart';
import 'package:project/widgets/home/posts.dart';
import 'package:project/widgets/home/scrolling_icons.dart';
import 'package:project/widgets/home/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _notificationService = NotificationService();

  int _selectedIndex = 0;
  int _unreadMessageCount = 0;
  Future<UserProfile?>? _userProfileFuture;
  RealtimeChannel? _messageChannel;

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageChannel?.unsubscribe();
    super.dispose();
  }

  void _initializeUserProfile() {
    _userProfileFuture = _fetchUserProfile();
  }

 Future<UserProfile?> _fetchUserProfile() async {
  try {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return null;
    
    final response = await UserService().fetchUserProfile(userId);
    if (response == null) return null;


    if (response['user'] != null) {
      return UserProfile.fromJson(response['user']);
    } else if (response['data'] != null) {
      final data = response['data'] is List ? response['data'][0] : response['data'];
      return UserProfile.fromJson(data);
    }
    
    return null;
  } catch (e) {
    debugPrint("Error fetching profile: $e");
    return null;
  }
}

  void _setupMessageListener() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return;

    _updateUnreadCount(userId);

    _messageChannel = _notificationService.subscribeToUnreadMessages(
      userId,
      (_) => _updateUnreadCount(userId),
    );
  }

  Future<void> _updateUnreadCount(String userId) async {
    final count = await _notificationService.getUnreadCount(userId);
    if (mounted) setState(() => _unreadMessageCount = count);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 4) {
      _scaffoldKey.currentState?.openDrawer();
      return;
    }

    final routes = ['/home', '/friends', '/create-post', '/notifications'];
    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MySidebar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "facegram",
          style: GoogleFonts.poppins(
            fontSize: 29,
            color: const Color.fromARGB(255, 16, 144, 250),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 228, 225, 225),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 30, color: Colors.black87),
            ),
            onPressed: () => debugPrint("Search tapped"),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 228, 225, 225),
                shape: BoxShape.circle,
              ),
              child: BadgedIcon(
                icon: Image.asset(
                  'assets/images/message.png',
                  height: 30,
                  color: Colors.black87,
                ),
                count: _unreadMessageCount > 0 ? _unreadMessageCount : null,
              ),
            ),
            onPressed: () {
              setState(() => _unreadMessageCount = 0);
              Navigator.pushNamed(context, "/contacts");
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async => setState(() => _initializeUserProfile()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildUserHeader(),
                    const ScrollingIcons(),
                    const Posts(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          FutureBuilder<UserProfile?>(
            future: _userProfileFuture,
            builder: (context, snapshot) {
              final profilePic =
                  snapshot.data?.profilePic ??
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9tu0c_cjxMIIll3_E23_TRiAGPLXAW5WJFg&s";

              return snapshot.connectionState == ConnectionState.waiting
                  ? const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(profilePic),
                    );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 242, 240, 240),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              readOnly: true,
              onTap: () => Navigator.pushNamed(context, '/create-post'),
            ),
          ),
        ],
      ),
    );
  }
}