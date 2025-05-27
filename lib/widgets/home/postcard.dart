// import 'package:project/screens/comments_page.dart';
// import 'package:project/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:project/services/post_service.dart';

// class PostCard extends StatefulWidget {
//   final Map<String, dynamic> post;

//   const PostCard({super.key, required this.post});

//   @override
//   State<PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
//   late int likesCount;
//   late int commentsCount;
//   bool isLiked = false;

//   @override
//   void initState() {
//     super.initState();

//     final likes = widget.post['likes'] as List<dynamic>?;

//     likesCount = likes?.length ?? 0;
//     commentsCount = widget.post['comments']?.length ?? 0;

//     _initLikeStatus();
//   }

//   void _initLikeStatus() async {
//     final currentUserId = await AuthService.getCurrentUserId();

//     final likes = widget.post['likes'] as List<dynamic>?;
//     final alreadyLiked =
//         likes?.any((like) => like['user_id'] == currentUserId) ?? false;

//     setState(() {
//       isLiked = alreadyLiked;
//     });
//   }

//   void toggleLike() async {
//   setState(() {
//     isLiked = !isLiked;
//     likesCount += isLiked ? 1 : -1;
//   });

//   bool success = await PostService.likeOrUnlikePost(widget.post['id'], isLiked);

//   if (!success) {

//     setState(() {
//       isLiked = !isLiked;
//       likesCount += isLiked ? 1 : -1;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to update like status')),
//     );
//   }
// }

//   void addComment(String comment) {
//     setState(() {
//       commentsCount += 1;
//     });
//     Navigator.of(context).pop();
//   }

//  void navigateToComments() {
//   final postId = widget.post['id'];
//   if (postId != null && postId is String) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => CommentsPage(postId: postId)),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Invalid post ID.')),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final post = widget.post;

//     return Card(
//       margin: const EdgeInsets.only(top: 5),
//       elevation: 5,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.zero,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: post['user_profile_pic'] != null &&
//                           post['user_profile_pic'].isNotEmpty
//                       ? NetworkImage(post['user_profile_pic'])
//                       : const NetworkImage(
//                           "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9tu0c_cjxMIIll3_E23_TRiAGPLXAW5WJFg&s"),
//                   radius: 20,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     post['users']?['first_name'] ?? "User Name",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               post['content'] ?? '',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//           if (post['image_url'] != null)
//             Image.network(
//               post['image_url'],
//               height: 250,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           Container(
//             decoration: BoxDecoration(
//               border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.thumb_up, size: 18, color: Colors.blue),
//                     const SizedBox(width: 4),
//                     Text(
//                       "$likesCount",
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Icon(Icons.comment_outlined,
//                         size: 18, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(
//                       "$commentsCount",
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         isLiked
//                             ? Icons.thumb_up_alt
//                             : Icons.thumb_up_alt_outlined,
//                       ),
//                       onPressed: toggleLike,
//                       color: Colors.blue,
//                     ),
//                     const Text("Like"),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.comment_outlined),
//                       onPressed: navigateToComments,
//                       color: Colors.grey,
//                     ),
//                     const Text("Comment"),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.share),
//                       onPressed: () {},
//                       color: Colors.grey,
//                     ),
//                     const Text("Share"),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }

import 'package:project/screens/comments_page.dart';
import 'package:project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:project/services/post_service.dart';
import 'package:project/services/friend_service.dart';
import 'package:project/services/chat_service.dart';
import 'package:project/models/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int likesCount;
  late int commentsCount;
  bool isLiked = false;
  List<PotentialFriend> friends = [];
  bool isSharing = false;
  Map<String, bool> selectedFriends = {};

  @override
  void initState() {
    super.initState();

    final likes = widget.post['likes'] as List<dynamic>?;
    likesCount = likes?.length ?? 0;
    commentsCount = widget.post['comments']?.length ?? 0;

    _initLikeStatus();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) return;

      final fetchedFriends = await FriendService.getFriends(currentUserId);
      setState(() {
        friends = fetchedFriends;
        selectedFriends = {for (var friend in fetchedFriends) friend.id: false};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load friends: ${e.toString()}')),
        );
      }
    }
  }

  void _initLikeStatus() async {
    final currentUserId = await AuthService.getCurrentUserId();
    if (currentUserId == null) return;

    final likes = widget.post['likes'] as List<dynamic>?;
    final alreadyLiked =
        likes?.any((like) => like['user_id'] == currentUserId) ?? false;

    setState(() {
      isLiked = alreadyLiked;
    });
  }

  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });

    bool success = await PostService.likeOrUnlikePost(
      widget.post['id'],
      isLiked,
    );

    if (!success) {
      setState(() {
        isLiked = !isLiked;
        likesCount += isLiked ? 1 : -1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like status')),
      );
    }
  }

  void addComment(String comment) {
    setState(() {
      commentsCount += 1;
    });
    Navigator.of(context).pop();
  }

  void navigateToComments() {
    final postId = widget.post['id'];
    if (postId != null && postId is String) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CommentsPage(postId: postId)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid post ID.')));
    }
  }

  void _showShareBottomSheet() {
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                    friend.profilePic ??
                                        'https://via.placeholder.com/150',
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
                            await _sharePost();
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

  Future<void> _sharePost() async {
    try {
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      final selectedFriendIds = selectedFriends.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedFriendIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one friend')),
        );
        return;
      }

      final postContent = widget.post['content'] ?? '';
      final imageUrl = widget.post['image_url'] as String?;
      print(imageUrl);

      for (final friendId in selectedFriendIds) {
        try {
          final chatId = await ChatService.createChatIfNotExists(
            currentUserId,
            friendId,
          );

          if (postContent.isNotEmpty) {
            await ChatService.sendMessage(chatId, currentUserId, postContent);
          }

          if (imageUrl != null) {
            _buildNetworkImage(imageUrl);
            await ChatService.sendMessage(
              chatId,
              currentUserId,
              '[IMAGE] $imageUrl',
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to share with ${friends.firstWhere((f) => f.id == friendId).firstName ?? 'friend'}: ${e.toString()}',
                ),
              ),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shared with ${selectedFriendIds.length} ${selectedFriendIds.length == 1 ? 'friend' : 'friends'}',
            ),
          ),
        );
      }

      setState(() {
        selectedFriends = selectedFriends.map(
          (key, value) => MapEntry(key, false),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share post: ${e.toString()}')),
        );
      }
    }
  }

Widget _buildNetworkImage(String imageUrl) {
  try {
    // Validate the URL first
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      return _buildImageErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      httpHeaders: const {
        'Accept': 'image/*', // Ensure we only accept image responses
      },
      progressIndicatorBuilder: (context, url, progress) => Container(
        height: 250,
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            value: progress.progress,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildImageErrorWidget(),
    );
  } catch (e) {
    return _buildImageErrorWidget();
  }
}

Widget _buildImageErrorWidget() {
  return Container(
    height: 250,
    color: Colors.grey[200],
    child: const Icon(Icons.broken_image, color: Colors.grey),
  );
}

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.only(top: 5),
      elevation: 5,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      post['user_profile_pic'] != null &&
                          post['user_profile_pic'].isNotEmpty
                      ? NetworkImage(post['user_profile_pic'])
                      : const NetworkImage(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9tu0c_cjxMIIll3_E23_TRiAGPLXAW5WJFg&s",
                        ),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post['users']?['first_name'] ?? "User Name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (post['image_url'] != null && post['image_url'].isNotEmpty)
            Image.network(
              post['image_url'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 18, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      "$likesCount",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$commentsCount",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                      ),
                      onPressed: toggleLike,
                      color: Colors.blue,
                    ),
                    const Text("Like"),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: navigateToComments,
                      color: Colors.grey,
                    ),
                    const Text("Comment"),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _showShareBottomSheet,
                      color: Colors.grey,
                    ),
                    const Text("Share"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
