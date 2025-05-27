import 'package:flutter/material.dart';
import 'package:project/services/post_service.dart';
import 'package:intl/intl.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() => isLoading = true);

      final fetchedPosts = await PostService.getPostsById('current-user-id');
      setState(() {
        posts = fetchedPosts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load posts: $e')));
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
              child: ListView.builder(
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
    final createdAt = DateTime.parse(post['created_at']);
    final comments = post['comments'] ?? [];
    final likes = post['likes'] ?? [];
    final likeCount = likes.where((like) => like['liked'] == true).length;

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
              backgroundImage: NetworkImage(
                post['user']['profile_pic'] ??
                    'https://via.placeholder.com/150',
              ),
            ),
            title: Text(
              post['user']['name'] ?? 'Unknown User',
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
              fit: BoxFit.cover,
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
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
