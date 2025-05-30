class ApiConstants {
  static const String baseUrl = 'http://192.168.1.4:4000/api';

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String createPost = '$baseUrl/posts';
  static const String getPosts = '$baseUrl/posts';
  static const String getPostsById = '$baseUrl/posts/:id';
  static const String likePost = '$baseUrl/posts/:id/like';
  static const String commentPost = '$baseUrl/posts/:postId/comment';
  static const String getComments = '$baseUrl/posts/:postId/comment';
  static const String deleteCommentById = '$baseUrl/posts/comments/:commentId';
  static const String fetchUserDetails = '$baseUrl/users/:userId';
  static const String editUserProfile = '$baseUrl/users/:userId';
  static const String updateProfile = '$baseUrl/users/:id';
  static const String sendFriendRequest = '$baseUrl/friends/requests/:userId';
  static const String acceptFriendRequest =
      '$baseUrl/friends/requests/:userId/accept';
  static const String cancelFriendRequest =
      '$baseUrl/friends/requests/:userId/cancel';
  static const String removeFriend = '$baseUrl/friends/:userId';
  static const String getPotentialFriends = '$baseUrl/friends/potential';
  static const String getPendingFriendRequests =
      '$baseUrl/friends/pending-requests';
  static const String getReceivedFriendRequests =
      '$baseUrl/friends/income-requests';
  static const String getFriends = '$baseUrl/friends/accepted';
  static const String createChat = '$baseUrl/chats';
  static const String getMessages = '$baseUrl/chats/:chatId';
  static const String sendMessage = '$baseUrl/chats/:chatId/messages';
  static const String deleteMessage = '$baseUrl/messages/:messageId';
}
