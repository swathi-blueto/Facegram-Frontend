import 'package:project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:project/services/post_service.dart';

class CommentsPage extends StatefulWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<dynamic> comments = [];
  final TextEditingController commentController = TextEditingController();
  bool isLoading = true;
  String? currentUserId;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final userId = await AuthService.getCurrentUserId();
    setState(() {
      currentUserId = userId;
    });
    await loadComments();
  }

  Future<void> loadComments() async {
    setState(() => isLoading = true);
    try {
      final fetchedComments = await PostService.getComments(widget.postId);
      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        comments = [];
        isLoading = false;
      });
    }
  }

  // In the postComment method:
  Future<void> postComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => isLoading = true);

    final success = await PostService.addComment(widget.postId, text);
    if (success != null) {
      commentController.clear();
      await loadComments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to post comment")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text("No comments yet"))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final isOwnComment = comment['user_id'] == currentUserId;

                      return Align(
                        alignment: isOwnComment
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isOwnComment ? 320 : 320,
                          ),
                          padding: EdgeInsets.all(isOwnComment ? 10 : 16),
                          decoration: BoxDecoration(
                            color: isOwnComment
                                ? Colors.blue.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOwnComment
                                  ? Colors.blue.shade200
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isOwnComment) ...[
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      comment['user_profile_pic'] != null
                                      ? NetworkImage(
                                          comment['user_profile_pic'],
                                        )
                                      : null,
                                  backgroundColor: Colors.blueGrey.shade100,
                                  child: comment['user_profile_pic'] == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            isOwnComment
                                                ? "${comment['user_first_name'] ?? "You"} (You)"
                                                : comment['user_first_name'] ??
                                                      "Unknown",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: isOwnComment
                                                  ? Colors.blueAccent
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          comment['createdAt'] != null
                                              ? "· ${formatDate(comment['createdAt'])}"
                                              : "",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isOwnComment)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    "Delete Comment",
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to delete this comment?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        "Delete",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                setState(
                                                  () => isLoading = true,
                                                );
                                                await PostService.deleteComment(
                                                  comment['id'],
                                                );
                                                await loadComments();
                                                setState(
                                                  () => isLoading = false,
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      comment['text'] ?? "",
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: postComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String dateString) {
    try {
      final utcDate = DateTime.parse(dateString);
      final localDate = utcDate.toLocal();
      final hour = localDate.hour.toString().padLeft(2, '0');
      final minute = localDate.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return "";
    }
  }
}
