import 'dart:io';
import 'package:project/services/auth_service.dart';
import 'package:project/services/user_service.dart';
import 'package:project/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileFormScreen extends StatefulWidget {
  final UserProfile? profileData;
  const ProfileFormScreen({super.key, this.profileData});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();

  final TextEditingController _zipCtrl = TextEditingController();
  final TextEditingController _occupationCtrl = TextEditingController();

  String? _selectedGender;
  File? _coverImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.profileData != null) {
      _populateForm(widget.profileData!);
    }
  }

  void _populateForm(UserProfile profile) {
    _nameCtrl.text = "${profile.firstName} ${profile.lastName}";
    _emailCtrl.text = profile.email ?? '';
    _dobCtrl.text = profile.dateOfBirth ?? '';
    _bioCtrl.text = profile.bio ?? '';
    _phoneCtrl.text = profile.phone ?? '';
    _cityCtrl.text = profile.city ?? '';
   
    _addressCtrl.text = profile.hometown ?? '';
    _occupationCtrl.text = profile.work ?? '';
    _selectedGender = profile.gender;
  }

  Future<void> _pickDOB() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickImage(bool isCover) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (isCover) {
            _coverImage = File(pickedFile.path);
          } else {
            _profileImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: ${e.toString()}")),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final userId = await AuthService.getCurrentUserId();
        if (userId == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
          return;
        }

        // Split full name into first and last names
        final nameParts = _nameCtrl.text.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final profileData = {
          'first_name': firstName,
          'last_name': lastName,
          'email': _emailCtrl.text,
          'phone': _phoneCtrl.text,
          'gender': _selectedGender ?? '',
          'date_of_birth': _dobCtrl.text,
          'city': _cityCtrl.text,
         
          'hometown': _addressCtrl.text,
          'bio': _bioCtrl.text,
          'work': _occupationCtrl.text,
          'education': '',
          'relationship_status': '',
         
          'zip_code': _zipCtrl.text,
        };

        final userService = UserService();
        final result = await userService.createUserProfile(
          userId,
          profileData,
          _profileImage,
          _coverImage,
        );

        Navigator.pop(context);

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          Navigator.pop(context); // Close the form after successful save
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profile. Check the data and try again.')),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : widget.profileData?.coverPhoto != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.profileData!.coverPhoto!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: _coverImage == null && widget.profileData?.coverPhoto == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, 
                                    size: 40, 
                                    color: Colors.white.withOpacity(0.7)),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to add cover photo",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : widget.profileData?.profilePic != null
                                      ? NetworkImage(widget.profileData!.profilePic!)
                                      : null,
                              child: _profileImage == null && widget.profileData?.profilePic == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionHeader("Personal Info", Icons.person_outline),
                      _buildTextField("Full Name", _nameCtrl),
                      _buildTextField("Email Address", _emailCtrl),
                      _buildTextField("Phone Number", _phoneCtrl),
                      _buildTextField("Date of Birth", _dobCtrl,
                          readOnly: true, onTap: _pickDOB),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          hintText: "Gender",
                          filled: true,
                          fillColor: const Color(0xFFF0F0F0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        value: _selectedGender,
                        items: ['male', 'female', 'other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedGender = value),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionHeader("Address Info", Icons.location_on_outlined),
                      _buildTextField("Address", _addressCtrl),
                      _buildTextField("City", _cityCtrl),
                     
                      _buildTextField("Zip Code", _zipCtrl),
                      const SizedBox(height: 20),
                      _buildSectionHeader("Other Info", Icons.info_outline),
                      _buildTextField("Occupation", _occupationCtrl),
                      _buildTextField("Short Bio", _bioCtrl),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text("Save Profile",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}