import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/post_service.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart'; // Added for toast

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  File? _imageFile;
  String _visibility = 'public';
  bool _isLoading = false;
  final FToast _toast = FToast(); 

  @override
  void initState() {
    super.initState();
    _toast.init(context); 
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _showToast(String message, {bool isError = false}) {
    _toast.removeQueuedCustomToasts();
    _toast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: isError ? Colors.red : Colors.green,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
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

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      await PostService.createPost(
        userId: userId,
        content: _contentController.text,
        visibility: _visibility,
        imageFile: _imageFile,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
        _showToast('Post created successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pushReplacementNamed(context, "/home"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton(
              onPressed: _isLoading ? null : _submitPost,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Row(
                    children: [
                      const CircleAvatar(radius: 22, child: Icon(Icons.person)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You', style: theme.textTheme.titleMedium),
                          DropdownButton<String>(
                            value: _visibility,
                            icon: const Icon(Icons.arrow_drop_down),
                            underline: const SizedBox(),
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.primary),
                            items: const [
                              DropdownMenuItem(value: 'public', child: Text("🌍 Public")),
                              DropdownMenuItem(value: 'friends', child: Text("👥 Friends")),
                              DropdownMenuItem(value: 'private', child: Text("🔒 Only me")),
                            ],
                            onChanged: (value) => setState(() => _visibility = value!),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please write something.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                 
                  if (_imageFile != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _imageFile = null),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

              
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Add Photo"),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: theme.colorScheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_camera_back_rounded),
              onPressed: _pickImage,
              tooltip: 'Photo',
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.emoji_emotions),
              onPressed: () {}, 
              tooltip: 'Emoji',
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.location_on_outlined),
              onPressed: () {}, 
              tooltip: 'Location',
            ),
          ],
        ),
      ),
    );
  }
}
