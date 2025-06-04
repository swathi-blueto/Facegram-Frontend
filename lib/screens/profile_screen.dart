import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/user_profile.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/profileform_screen.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/post_service.dart';
import 'package:project/services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends StatefulWidget {
  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  String? userId;

  Future<UserProfile?> fetchUserProfile() async {
    try {
      userId = await AuthService.getCurrentUserId();
      if (userId == null) return null;

      final userService = UserService();
      final response = await userService.fetchUserProfile(userId!);

      if (response == null) return null;

      if (response['user'] != null) {
        return UserProfile.fromJson(response['user']);
      } else if (response['data'] != null) {
        final data = response['data'] is List
            ? response['data'][0]
            : response['data'];
        return UserProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      return null;
    }
  }

  bool _isProfileComplete(UserProfile profile) {
    return profile.firstName.isNotEmpty &&
        profile.lastName.isNotEmpty &&
        profile.profilePic != null &&
        profile.coverPhoto != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const ProfileFormScreen();
        }

        final user = snapshot.data!;

        if (!_isProfileComplete(user)) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pushReplacementNamed(context, "/home"),
              ),
              title: const Text(
                'Complete Profile',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profile Incomplete',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please complete your profile to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileFormScreen(profileData: user),
                          ),
                        );
                      },
                      child: const Text(
                        'Complete Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildProfileScreen(user);
      },
    );
  }

  Widget _buildProfileScreen(UserProfile user) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        user.coverPhoto ??
                            'https://via.placeholder.com/600x200',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(
                          user.profilePic ?? 'https://via.placeholder.com/100',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 60),
              Column(
                children: [
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        user.bio!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileFormScreen(profileData: user),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('2.3M', 'Followers'),
                        _buildStatItem('1.2K', 'Following'),
                        _buildStatItem('456', 'Posts'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      Icons.work,
                      user.work?.isNotEmpty == true
                          ? user.work!
                          : 'Not specified',
                    ),
                    _buildInfoItem(Icons.school, 'University of Example'),
                    _buildInfoItem(
                      Icons.location_on,
                      user.city?.isNotEmpty == true
                          ? '${user.city}, India'
                          : 'Location not specified',
                    ),
                    _buildInfoItem(
                      Icons.calendar_today,
                      'Joined ${DateFormat('MMMM yyyy').format(DateTime.parse(user.createdAt))}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Posts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              if (userId != null) _buildPostsSection(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    return FutureBuilder<List<dynamic>>(
      future: PostService.getPostsById(userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }
        return Column(
          children: snapshot.data!.map((post) => _buildPostCard(post)).toList(),
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postData = post['data'] is List ? post['data'] : [post];
    return Column(
      children: postData.map<Widget>((singlePost) {
        final content = singlePost['content']?.toString() ?? '';
        final imageUrl = singlePost['image_url']?.toString();
        final likes = singlePost['likes'] is List ? singlePost['likes'] : [];
        final likeCount = likes
            .where((like) => like is Map && like['liked'] == true)
            .length;
        final relativeTime = _getRelativeTime(singlePost['created_at']);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text(
                  'User Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(relativeTime),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _handlePostAction(value, singlePost['id']),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Post'),
                    ),
                  ],
                ),
              ),
              if (content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(content),
                ),
              if (imageUrl != null && imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('$likeCount'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  _buildActionButton(Icons.thumb_up_outlined, 'Like'),
                  _buildActionButton(Icons.comment_outlined, 'Comment'),
                  _buildActionButton(Icons.share_outlined, 'Share'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _handlePostAction(String action, String postId) {
    if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                debugPrint('Deleting post with ID: $postId');
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  String _getRelativeTime(String? timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      final createdAt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return 'Just now';
    }
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Expanded(
      child: TextButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        onPressed: () {},
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
        ],
      ),
    );
  }
}
