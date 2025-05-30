// import 'package:flutter/material.dart';
// import 'package:project/services/post_service.dart';
// import 'package:intl/intl.dart';

// class PostsScreen extends StatefulWidget {
//   const PostsScreen({super.key});

//   @override
//   State<PostsScreen> createState() => _PostsScreenState();
// }

// class _PostsScreenState extends State<PostsScreen> {
//   List<dynamic> posts = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPosts();
//   }

//   Future<void> _fetchPosts() async {
//     try {
//       setState(() => isLoading = true);

//       final fetchedPosts = await PostService.getPostsById('current-user-id');
//       setState(() {
//         posts = fetchedPosts;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load posts: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Posts'), centerTitle: true),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _fetchPosts,
//               child: ListView.builder(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 itemCount: posts.length,
//                 itemBuilder: (context, index) {
//                   final post = posts[index];
//                   return _buildPostCard(post);
//                 },
//               ),
//             ),
//     );
//   }

//   Widget _buildPostCard(Map<String, dynamic> post) {
//     final dateFormat = DateFormat('MMM d, yyyy · hh:mm a');
//     final createdAt = DateTime.parse(post['created_at']);
//     final comments = post['comments'] ?? [];
//     final likes = post['likes'] ?? [];
//     final likeCount = likes.where((like) => like['liked'] == true).length;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(
//                 post['user']['profile_pic'] ??
//                     'https://via.placeholder.com/150',
//               ),
//             ),
//             title: Text(
//               post['user']['name'] ?? 'Unknown User',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text(dateFormat.format(createdAt)),
//             trailing: IconButton(
//               icon: const Icon(Icons.more_vert),
//               onPressed: () {},
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(post['content'] ?? ''),
//           ),

//           if (post['image_url'] != null) ...[
//             const SizedBox(height: 12),
//             Image.network(
//               post['image_url'],
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ],

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 if (likeCount > 0) ...[
//                   const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
//                   const SizedBox(width: 4),
//                   Text('$likeCount'),
//                   const SizedBox(width: 16),
//                 ],
//                 if (comments.isNotEmpty) ...[
//                   Text('${comments.length} comments'),
//                 ],
//               ],
//             ),
//           ),

//           const Divider(height: 1),
//           Row(
//             children: [
//               Expanded(
//                 child: TextButton.icon(
//                   icon: const Icon(Icons.thumb_up_outlined),
//                   label: const Text('Like'),
//                   onPressed: () {},
//                 ),
//               ),
//               Expanded(
//                 child: TextButton.icon(
//                   icon: const Icon(Icons.comment_outlined),
//                   label: const Text('Comment'),
//                   onPressed: () {},
//                 ),
//               ),
//               Expanded(
//                 child: TextButton.icon(
//                   icon: const Icon(Icons.share_outlined),
//                   label: const Text('Share'),
//                   onPressed: () {},
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:project/models/user_profile.dart';
import 'package:project/services/post_service.dart';
import 'package:project/services/friend_service.dart';
import 'package:project/services/chat_service.dart';
import 'package:project/services/auth_service.dart';
import 'package:intl/intl.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  List<PotentialFriend> friends = [];
  bool isSharing = false;
  Map<String, bool> selectedFriends = {};

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchFriends();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() => isLoading = true);
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) throw Exception('User not logged in');
      
      final fetchedPosts = await PostService.getPostsById(currentUserId);
      setState(() {
        posts = fetchedPosts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _fetchFriends() async {
    try {
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) throw Exception('User not logged in');
      
      final fetchedFriends = await FriendService.getFriends(currentUserId);
      setState(() {
        friends = fetchedFriends;
        selectedFriends = {
          for (var friend in fetchedFriends) friend.id: false
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load friends: ${e.toString()}')),
        );
      }
    }
  }

  void _showShareBottomSheet(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  const Text(
                    'Share with friends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: friends.isEmpty
                        ? const Center(child: Text('No friends found'))
                        : ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              final friend = friends[index];
                              return CheckboxListTile(
                                value: selectedFriends[friend.id] ?? false,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedFriends[friend.id] = value!;
                                  });
                                },
                                title: Text(friend.firstName ?? 'Unknown'),
                                secondary: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    friend.profilePic ?? 'https://via.placeholder.com/150',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isSharing
                        ? null
                        : () async {
                            setModalState(() => isSharing = true);
                            await _sharePost(post);
                            setModalState(() => isSharing = false);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: isSharing
                        ? const CircularProgressIndicator()
                        : const Text('Send'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sharePost(Map<String, dynamic> post) async {
    try {
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) throw Exception('User not logged in');
      
      final selectedFriendIds = selectedFriends.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedFriendIds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one friend')),
          );
        }
        return;
      }

      final shareMessage = "Check out this post: ${post['content'] ?? ''}";

      for (final friendId in selectedFriendIds) {
        try {
          final chatId = await ChatService.createChatIfNotExists(
            currentUserId,
            friendId,
          );

          await ChatService.sendMessage(
            chatId,
            currentUserId,
            shareMessage,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to share with ${friends.firstWhere((f) => f.id == friendId).firstName ?? 'friend'}: ${e.toString()}')),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared with ${selectedFriendIds.length} ${selectedFriendIds.length == 1 ? 'friend' : 'friends'}')),
        );
      }

      setState(() {
        selectedFriends = selectedFriends.map((key, value) => MapEntry(key, false));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share post: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: posts.isEmpty
                  ? const Center(child: Text('No posts found'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostCard(post);
                      },
                    ),
            ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final dateFormat = DateFormat('MMM d, yyyy · hh:mm a');
    final createdAt = post['created_at'] != null 
        ? DateTime.parse(post['created_at'])
        : DateTime.now();
    final comments = post['comments'] ?? [];
    final likes = post['likes'] ?? [];
    final likeCount = likes.where((like) => like['liked'] == true).length;
    final user = post['user'] ?? {};
    final userName = user['name'] ?? user['firstName'] ?? 'Unknown User';
    final userProfilePic = user['profile_pic'] ?? user['profilePic'] ?? 'https://via.placeholder.com/150';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userProfilePic),
            ),
            title: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dateFormat.format(createdAt)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post['content'] ?? ''),
          ),

          if (post['image_url'] != null) ...[
            const SizedBox(height: 12),
            Image.network(
              post['image_url'],
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (likeCount > 0) ...[
                  const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('$likeCount'),
                  const SizedBox(width: 16),
                ],
                if (comments.isNotEmpty) ...[
                  Text('${comments.length} comments'),
                ],
              ],
            ),
          ),

          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.thumb_up_outlined),
                  label: const Text('Like'),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comment'),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                  onPressed: () => _showShareBottomSheet(post),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}