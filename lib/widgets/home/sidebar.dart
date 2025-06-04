import 'package:project/screens/profile_screen.dart';
import 'package:project/screens/profileform_screen.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/user_service.dart';
import 'package:flutter/material.dart';

class MySidebar extends StatefulWidget {
  const MySidebar({super.key});

  @override
  State<MySidebar> createState() => _MySidebarState();
}

class _MySidebarState extends State<MySidebar> {
  Future<void> handleLogout() async {
    try {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Facegram',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Connect with your world',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildListTile(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  title: 'Home',
                  onTap: () => Navigator.pushReplacementNamed(context, "/home"),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.blue),
                  title: const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.person, color: Colors.blue),
                  onTap: () async {
                    final userId = await AuthService.getCurrentUserId();
                    if (userId != null) {
                      final userService = UserService();
                      final profile =
                          await userService.fetchUserProfile(userId);
                     

                      if (!context.mounted) return;

                      if (profile == null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileFormScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User not logged in.")),
                      );
                    }
                  },
                ),
                const Divider(height: 1, thickness: 1),
                const Divider(height: 1, thickness: 1),
                _buildListTile(
                  context,
                  icon: Icons.logout_outlined,
                  title: 'Logout',
                  onTap: handleLogout,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Facegram v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.blue[800],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: activeIcon != null
          ? Icon(
              activeIcon,
              color: color ?? Colors.blue[800],
            )
          : null,
      onTap: onTap,
    );
  }
}
