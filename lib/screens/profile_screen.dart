import 'package:project/models/user_profile.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/profileform_screen.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/post_service.dart';
import 'package:project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  
  String? userId;

  Future<UserProfile?> fetchUserProfile() async {
    try {
      userId = await AuthService.getCurrentUserId();
      if (userId == null) return null;

      final userService = UserService();
      return await userService.fetchUserProfile(userId!);
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      return null;
    }
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
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading profile')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const ProfileFormScreen();
        } else {
          final user = snapshot.data!;
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
                      final top = constraints.biggest.height;
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
                            bottom: -50,
                            left: MediaQuery.of(context).size.width / 2 - 50,
                            child: Material(
                              elevation: 4,
                              shape: const CircleBorder(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: NetworkImage(
                                    user.profilePic ??
                                        'https://via.placeholder.com/100',
                                  ),
                                ),
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
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                        if (user.bio != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              user.bio!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
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
                                builder: (_) => ProfileFormScreen(profileData: user),
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
                          side: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
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
                          _buildInfoItem(Icons.work, user.work ?? 'Not specified'),
                          _buildInfoItem(Icons.school, 'University of Example'),
                          _buildInfoItem(Icons.location_on, 'Chennai, India'),
                          _buildInfoItem(Icons.calendar_today, 'Joined June 2023'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                 
                    if (userId != null) _buildPostsSection(userId!),
                  ]),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildPostsSection(String userId) {
    return FutureBuilder<List<dynamic>>(
      future: PostService.getPostsById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts yet'));
        } else {
          return Column(
            children: snapshot.data!.map((post) => _buildPostCard(post)).toList(),
          );
        }
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
      final likeCount = likes.where((like) => like is Map && like['liked'] == true).length;
      
     
      String relativeTime = 'Just now';
      try {
        if (singlePost['created_at'] != null) {
          final createdAt = DateTime.parse(singlePost['created_at']);
          final now = DateTime.now();
          final difference = now.difference(createdAt);
          
          if (difference.inDays > 0) {
            relativeTime = '${difference.inDays}d ago';
          } else if (difference.inHours > 0) {
            relativeTime = '${difference.inHours}h ago';
          } else if (difference.inMinutes > 0) {
            relativeTime = '${difference.inMinutes}m ago';
          }
        }
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            ListTile(
              // leading: const CircleAvatar(
              //   backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              // ),
              title: const Text(
                'User Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(relativeTime),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete') {
                    
                    _deletePost(singlePost['id']);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Post'),
                    ),
                  ];
                },
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                 

  // ... rest of your existing profile screen methods ...


  
void _deletePost(String postId) {
  
  debugPrint('Deleting post with ID: $postId');
 
}


   Widget _buildActionButton(IconData icon, String label) {
  return Expanded(
    child: TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {},
    ),
  );
}

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
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
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}