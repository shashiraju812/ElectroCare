// lib/features/profile/presentation/widgets/edit_profile_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/auth_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

class EditProfileDialog extends StatefulWidget {
  final AuthService auth;
  final ProfileEntity user;
  final WidgetRef ref;

  const EditProfileDialog({
    super.key,
    required this.auth,
    required this.user,
    required this.ref,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _addressCtrl = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await widget.ref.read(profileNotifierProvider.notifier).updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
        
        // Also update legacy AuthService for compatibility with other parts of the app
        widget.auth.updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
        
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: _isLoading 
        ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
        : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Name cannot be empty';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Phone cannot be empty';
                  if (value.trim().length != 10) return 'Phone must be 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Address cannot be empty';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

void showEditProfileDialog(BuildContext context, AuthService auth, dynamic user, WidgetRef ref) {
  if (user == null) return;
  showDialog(
    context: context,
    builder: (ctx) => EditProfileDialog(auth: auth, user: user as ProfileEntity, ref: ref),
  );
}
