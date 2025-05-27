import 'package:project/screens/comments_page.dart';
import 'package:project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:project/services/post_service.dart';

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

  @override
  void initState() {
    super.initState();

    final likes = widget.post['likes'] as List<dynamic>?;

    likesCount = likes?.length ?? 0;
    commentsCount = widget.post['comments']?.length ?? 0;

    _initLikeStatus(); // 👈 Fetch current user and check like status
  }

  void _initLikeStatus() async {
    final currentUserId = await AuthService.getCurrentUserId();

    final likes = widget.post['likes'] as List<dynamic>?;
    final alreadyLiked =
        likes?.any((like) => like['user_id'] == currentUserId) ?? false;

    setState(() {
      isLiked = alreadyLiked;
    });
  }

  void toggleLike() async {
  setState(() {
    isLiked = !isLiked; // Optimistic update
    likesCount += isLiked ? 1 : -1;
  });

  bool success = await PostService.likeOrUnlikePost(widget.post['id'], isLiked);

  if (!success) {
    // Revert if failed
    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update like status')),
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
  final postId = widget.post['id']; // Use 'id' instead of '_id'
  if (postId != null && postId is String) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommentsPage(postId: postId)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid post ID.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.only(top: 5),
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: post['user_profile_pic'] != null &&
                          post['user_profile_pic'].isNotEmpty
                      ? NetworkImage(post['user_profile_pic'])
                      : const NetworkImage(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9tu0c_cjxMIIll3_E23_TRiAGPLXAW5WJFg&s"),
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
          if (post['image_url'] != null)
            Image.network(
              post['image_url'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
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
                    const Icon(Icons.comment_outlined,
                        size: 18, color: Colors.grey),
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
                      onPressed: () {},
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
