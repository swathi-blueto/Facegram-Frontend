import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/models/user_profile.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/friend_service.dart';

class PotentialFriendsScreen extends StatefulWidget {
  const PotentialFriendsScreen({Key? key}) : super(key: key);

  @override
  State<PotentialFriendsScreen> createState() => _PotentialFriendsScreenState();
}

class _PotentialFriendsScreenState extends State<PotentialFriendsScreen> {
  final List<PotentialFriend> _potentialFriends = [];
  final List<PotentialFriend> _sentRequests = [];
  final List<PotentialFriend> _receivedRequests = [];
  bool _isLoading = true;
  bool _isAccepting = false;
  bool _isRejecting = false;
  bool _isSending = false;
  bool _isCanceling = false;
  String? _errorMessage;
  String? _currentUser;
  final FToast _fToast = FToast();

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _initializeData();
  }

  void _showToast(String message, {bool isError = false}) {
    _fToast.removeQueuedCustomToasts();
    _fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: isError ? Colors.red : Colors.blue,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, 
                color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> _initializeData() async {
    try {
      _currentUser = await AuthService.getCurrentUserId();
      await _loadData();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _loadData() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        FriendService.getPotentialFriends(_currentUser!),
        FriendService.getPendingFriendRequests(_currentUser!),
        FriendService.getReceivedFriendRequests(_currentUser!),
      ]);

      setState(() {
        _potentialFriends.clear();
        _potentialFriends.addAll(results[0]);
        _sentRequests.clear();
        _sentRequests.addAll(results[1]);
        _receivedRequests.clear();
        _receivedRequests.addAll(results[2]);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    if (mounted) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('People You May Know'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_add), text: 'Add Friends'),
              Tab(icon: Icon(Icons.send), text: 'Sent Requests'),
              Tab(icon: Icon(Icons.mail), text: 'Incoming Requests'),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1),
              ],
            ),
          ),
          child: TabBarView(
            children: [
              _buildPotentialFriendsTab(),
              _buildSentRequestsTab(),
              _buildIncomingRequestsTab(),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildPotentialFriendsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_potentialFriends.isEmpty) {
      return _buildEmptyWidget('No suggestions available');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _potentialFriends.length,
        itemBuilder: (context, index) {
          final friend = _potentialFriends[index];
          return _FriendCard(
            friend: friend,
            actionButton: _isSending
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _sendFriendRequest(friend.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Add Friend'),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_sentRequests.isEmpty) {
      return _buildEmptyWidget('No pending requests');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final friend = _sentRequests[index];
          return _FriendCard(
            friend: friend,
            actionButton: _isCanceling
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: () => _cancelFriendRequest(friend.id),
                    child: const Text('Cancel Request'),
                  ),
          );
        },
      ),
    );
  }


Widget _buildIncomingRequestsTab() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_errorMessage != null) {
    return _buildErrorWidget();
  }

  if (_receivedRequests.isEmpty) {
    return _buildEmptyWidget('No incoming requests');
  }

  return RefreshIndicator(
    onRefresh: _loadData,
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        final friend = _receivedRequests[index];
        return _FriendCard(
          friend: friend,
          actionButton: SizedBox(
            width: 160, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: _isAccepting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _acceptFriendRequest(friend.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced padding
                          ),
                          child: const FittedBox(
                            child: Text('Accept'),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _isRejecting
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: () => _rejectFriendRequest(friend.id),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced padding
                          ),
                          child: const FittedBox(
                            child: Text('Reject'),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}



  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Unknown error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  // ... [Keep all your existing _buildPotentialFriendsTab, _buildSentRequestsTab, 
  // _buildIncomingRequestsTab, _buildErrorWidget, _buildEmptyWidget methods exactly the same]

  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      setState(() => _isSending = true);
      final success = await FriendService.sendFriendRequest(receiverId);

      if (success && mounted) {
        await _loadData();
        _showToast('Friend request sent!');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to send request: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _cancelFriendRequest(String receiverId) async {
    try {
      setState(() => _isCanceling = true);
      final success = await FriendService.cancelFriendRequest(receiverId);

      if (success && mounted) {
        await _loadData();
        _showToast('Request cancelled!');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to cancel request: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  Future<void> _acceptFriendRequest(String senderId) async {
    try {
      setState(() => _isAccepting = true);
      final success = await FriendService.acceptFriendRequest(senderId);

      if (success && mounted) {
        await _loadData();
        _showToast('Friend request accepted!');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to accept request: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _rejectFriendRequest(String senderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text('Are you sure you want to reject this friend request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isRejecting = true);
      final success = await FriendService.cancelFriendRequest(senderId);

      if (success && mounted) {
        await _loadData();
        _showToast('Friend request rejected');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to reject request: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isRejecting = false);
    }
  }
}

class _FriendCard extends StatelessWidget {
  final PotentialFriend friend;
  final Widget actionButton;

  const _FriendCard({
    required this.friend,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: friend.profilePic.isNotEmpty
                  ? NetworkImage(friend.profilePic)
                  : null,
              child: friend.profilePic.isEmpty
                  ? const Icon(Icons.person, size: 28)
                  : null,
            ),
            const SizedBox(width: 12), // Reduced spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.firstName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            actionButton,
          ],
        ),
      ),
    );
  }
}
