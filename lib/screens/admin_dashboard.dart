import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/services/admin_service.dart';
import 'package:project/models/user_profile.dart';
import 'package:project/models/post_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentTabIndex = 0;
  List<UserProfile> _users = [];
  List<PostModel> _posts = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // For bottom navigation

  // Bottom navigation items
  static const List<Widget> _bottomNavOptions = <Widget>[
    Icon(Icons.people, size: 30),
    Icon(Icons.post_add, size: 30),
    Icon(Icons.analytics, size: 30),
    Icon(Icons.settings, size: 30),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_currentTabIndex == 0) {
        _users = await AdminService().getAllUsers();
      } else {
        _posts = await AdminService().getAllPosts();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _blockUser(String userId) async {
    try {
      await AdminService().blockUser(userId);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      await AdminService().unblockUser(userId);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await AdminService().deletePost(postId);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0) // Only show tabs on the main dashboard view
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Users'),
                      selected: _currentTabIndex == 0,
                      selectedColor: Colors.blue[800],
                      labelStyle: TextStyle(
                        color: _currentTabIndex == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentTabIndex = 0);
                          _loadData();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Posts'),
                      selected: _currentTabIndex == 1,
                      selectedColor: Colors.blue[800],
                      labelStyle: TextStyle(
                        color: _currentTabIndex == 1
                            ? Colors.white
                            : Colors.black,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentTabIndex = 1);
                          _loadData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _getCurrentView(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 0 && _currentTabIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddUserDialog,
              child: const Icon(Icons.add),
              backgroundColor: Colors.blue[800],
            )
          : null,
    );
  }

  Widget _getCurrentView() {
    switch (_selectedIndex) {
      case 0: // Main dashboard
        return _currentTabIndex == 0 ? _buildUsersList() : _buildPostsList();
      case 1: // Management view
        return _buildManagementView();
      case 2: // Analytics view
        return _buildAnalyticsView();
      case 3: // Settings view
        return _buildSettingsView();
      default:
        return _buildUsersList();
    }
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Enhanced Users List
  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic ?? ''),
              radius: 24,
              child: user.profilePic == null
                  ? Text(user.firstName?.substring(0, 1) ?? 'U')
                  : null,
            ),
            title: Text(
              user.username ?? '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                if (user.isBlocked ?? false)
                  const Text('Blocked', style: TextStyle(color: Colors.red)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info, color: Colors.blue[800]),
                  onPressed: () => _showUserDetails(user),
                ),
                user.isBlocked ?? false
                    ? ElevatedButton(
                        onPressed: () => _unblockUser(user.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Unblock',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => _blockUser(user.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Block',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced Posts List
  Widget _buildPostsList() {
    if (_posts.isEmpty) {
      return const Center(child: Text('No posts found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(post.userProfilePic ?? ''),
                  child: post.userProfilePic == null
                      ? Text(post.username?.substring(0, 1) ?? 'U')
                      : null,
                ),
                title: Text(
                  post.username ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  post.createdAt != null
                      ? '${post.createdAt!.toLocal()}'.split('.')[0]
                      : '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  post.content ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (post.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post.imageUrl!),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.likes?.length ?? 0}'),
                    const SizedBox(width: 16),
                    Icon(Icons.comment, color: Colors.blue, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.comments?.length ?? 0}'),
                  ],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showPostDetails(post),
                    child: const Text('DETAILS'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePost(post.id!),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // New Views for Bottom Navigation
  Widget _buildManagementView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.manage_accounts, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'User & Content Management',
            style: GoogleFonts.poppins(fontSize: 20),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildManagementCard(Icons.people, 'User Roles', () {}),
              _buildManagementCard(Icons.flag, 'Reported Content', () {}),
              _buildManagementCard(Icons.category, 'Categories', () {}),
              _buildManagementCard(Icons.notifications, 'Announcements', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnalyticsCard('Total Users', '1,234', Icons.people, Colors.blue),
        _buildAnalyticsCard('Active Today', '567', Icons.today, Colors.green),
        _buildAnalyticsCard('New Posts', '89', Icons.post_add, Colors.orange),
        _buildAnalyticsCard('Reports', '12', Icons.flag, Colors.red),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildActivityItem('New user registered', '2 mins ago'),
        _buildActivityItem('Post reported', '15 mins ago'),
        _buildActivityItem('User blocked', '1 hour ago'),
      ],
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: false,
          onChanged: (value) {},
        ),
        const ListTile(
          leading: Icon(Icons.security),
          title: Text('Privacy Settings'),
        ),
        const ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notification Settings'),
        ),
        const ListTile(
          leading: Icon(Icons.help),
          title: Text('Help & Support'),
        ),
        const ListTile(leading: Icon(Icons.info), title: Text('About App')),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.circle, size: 8, color: Colors.green),
        title: Text(title),
        subtitle: Text(time),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  // Dialog Methods
  void _showUserDetails(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic ?? ''),
                  radius: 40,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', '${user.firstName} ${user.lastName}'),
              _buildDetailRow('Username', user.username ?? 'N/A'),
              _buildDetailRow('Email', user.email),
              _buildDetailRow(
                'Status',
                (user.isBlocked ?? false) ? 'Blocked' : 'Active',
              ),
              // ignore: unnecessary_null_comparison
              // In _showUser Details method
              _buildDetailRow(
                'Joined',
                user.createdAt != null
                    ? DateTime.parse(
                        user.createdAt!,
                      ).toLocal().toString().split('.')[0]
                    : 'N/A',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showPostDetails(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(post.userProfilePic ?? ''),
                ),
                title: Text(post.username ?? 'Unknown'),
                subtitle: Text(
                  post.createdAt != null
                      ? post.createdAt!.toLocal().toString().split('.')[0]
                      : '',
                ),
              ),
              const SizedBox(height: 8),
              Text(post.content ?? ''),
              if (post.imageUrl != null) ...[
                const SizedBox(height: 16),
                Image.network(post.imageUrl!),
              ],
              const SizedBox(height: 16),
              _buildDetailRow('Likes', '${post.likes?.length ?? 0}'),
              _buildDetailRow('Comments', '${post.comments?.length ?? 0}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    
  }
}
