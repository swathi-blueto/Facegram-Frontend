import 'package:project/widgets/home/postcard.dart';
import 'package:flutter/material.dart';
import 'package:project/constants/api_constants.dart';
import "package:project/services/post_service.dart";
import 'dart:convert';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  late Future<List<dynamic>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = PostService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posts available."));
        } else {
          final posts = snapshot.data!;
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(), 
            shrinkWrap: true, 
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        }
      },
    );
  }
}