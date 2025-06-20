import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _avatarPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('profile_name') ?? '';
      _avatarPath = prefs.getString('profile_avatar');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text.trim());
    if (_avatarPath != null) {
      await prefs.setString('profile_avatar', _avatarPath!);
    }
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ cá nhân!')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ cá nhân', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 54,
                backgroundColor: Colors.orange.shade100,
                backgroundImage:
                    _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                child:
                    _avatarPath == null
                        ? Icon(
                          Icons.account_circle,
                          size: 90,
                          color: Colors.deepOrange,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.edit, color: Colors.deepOrange),
              label: Text(
                'Đổi ảnh đại diện',
                style: GoogleFonts.montserrat(color: Colors.deepOrange),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên của bạn',
                labelStyle: GoogleFonts.montserrat(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              style: GoogleFonts.montserrat(fontSize: 18),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _saveProfile,
                icon:
                    _loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  'Lưu',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
