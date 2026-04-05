import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  late TextEditingController _skillsController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _websiteController = TextEditingController(text: user?.website ?? '');
    _skillsController =
        TextEditingController(text: user?.skills.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // TODO: Implement full profile update with bio, website, skills
    // For now, just update display name
    await authService.updateUserProfile(
      displayName: _nameController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.surface,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? const Icon(Icons.person,
                              size: 40, color: AppTheme.primary)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Display Name',
                icon: Icons.person,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Bio
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.info,
                maxLines: 3,
                hint: 'Tell us about yourself...',
              ),
              const SizedBox(height: 16),

              // Website
              _buildTextField(
                controller: _websiteController,
                label: 'Website',
                icon: Icons.link,
                hint: 'https://yourwebsite.com',
              ),
              const SizedBox(height: 16),

              // Skills
              _buildTextField(
                controller: _skillsController,
                label: 'Skills',
                icon: Icons.star,
                hint: 'Art, Music, Photography (comma separated)',
              ),
              const SizedBox(height: 16),

              // Social Links
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.share, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Social Links',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSocialLink('Twitter', Icons.alternate_email),
                      _buildSocialLink('Instagram', Icons.camera_alt),
                      _buildSocialLink('YouTube', Icons.play_circle),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              GradientButton(
                text: 'Save Changes',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withAlpha(51)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
            prefixIcon: Icon(icon, color: AppTheme.primary),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLink(String platform, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add $platform link',
                hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
