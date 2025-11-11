import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../splash_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _storageService = StorageService();

  File? _selectedImage;
  bool _isUploading = false;
  String? _newPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final visitor = authProvider.visitorProfile;
    if (visitor != null) {
      _fullNameController.text = visitor.fullName;
      _phoneController.text = visitor.phone;
      _companyController.text = visitor.company;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    File? image;
    if (source == ImageSource.gallery) {
      image = await _storageService.pickImageFromGallery();
    } else {
      image = await _storageService.pickImageFromCamera();
    }

    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppTheme.primaryBlue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null || _getCurrentPhotoUrl() != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.dangerRed),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _newPhotoUrl = '';
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getCurrentPhotoUrl() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.visitorProfile?.photoUrl;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Upload image if selected
      if (_selectedImage != null) {
        _newPhotoUrl = await _storageService.uploadProfilePhoto(
          authProvider.currentUser!.uid,
          _selectedImage!,
        );
      }

      // Update profile
      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        company: _companyController.text.trim(),
        photoUrl: _newPhotoUrl,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _handleSave,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isUploading ? Colors.grey : AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Photo
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryBlue,
                              width: 3,
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : _getCurrentPhotoUrl() != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            _getCurrentPhotoUrl()!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                            gradient: _selectedImage == null &&
                                    _getCurrentPhotoUrl() == null
                                ? AppTheme.primaryGradient
                                : null,
                          ),
                          child: _selectedImage == null &&
                                  _getCurrentPhotoUrl() == null
                              ? Center(
                                  child: Text(
                                    _fullNameController.text.isNotEmpty
                                        ? _fullNameController.text[0]
                                            .toUpperCase()
                                        : 'V',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Company
                  TextFormField(
                    controller: _companyController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Company',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Email (Read Only)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) => TextFormField(
                      initialValue: authProvider.visitorProfile?.email ?? '',
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your email address cannot be changed',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUploading)
            const LoadingOverlay(message: 'Updating profile...'),
        ],
      ),
    );
  }
}

enum ImageSource { gallery, camera }
