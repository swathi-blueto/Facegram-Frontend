class PostModel {
  final String? id;
  final String? userId;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? visibility;
  final List<Comment>? comments;
  final List<Like>? likes;
  final String? username; 
  final String? userProfilePic; 

  PostModel({
    this.id,
    this.userId,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.createdAt,
    this.updatedAt,
    this.visibility,
    this.comments,
    this.likes,
    this.username,
    this.userProfilePic,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      visibility: json['visibility'],
      comments: json['comments'] != null 
          ? (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList()
          : null,
      likes: json['likes'] != null
          ? (json['likes'] as List).map((like) => Like.fromJson(like)).toList()
          : null,
      
      username: json['username'] ?? json['user']?['username'],
      userProfilePic: json['userProfilePic'] ?? json['user']?['profile_pic'],
    );
  }
}

class Comment {
  final String? id;
  final String? text;
  final String? userId;
  final DateTime? createdAt;

  Comment({
    this.id,
    this.text,
    this.userId,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'],
      userId: json['user_id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class Like {
  final bool? liked;
  final String? userId;

  Like({
    this.liked,
    this.userId,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      liked: json['liked'],
      userId: json['user_id'],
    );
  }
}