import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../models/measurement.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});
  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bustCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _shoulderCtrl = TextEditingController();
  String _gender = 'Female';
  File? _profileImage;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _bustCtrl.dispose();
    _waistCtrl.dispose();
    _hipCtrl.dispose();
    _chestCtrl.dispose();
    _shoulderCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardFill,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Select Image',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _imageSourceOption(Icons.camera_alt_rounded, 'Camera',
                  () => Navigator.pop(ctx, ImageSource.camera)),
              _imageSourceOption(Icons.photo_library_rounded, 'Gallery',
                  () => Navigator.pop(ctx, ImageSource.gallery)),
            ]),
          ]),
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  Widget _imageSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, size: 32, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary)),
      ]),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please upload a profile image', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    final uid = context.read<AuthProvider>().userId;
    if (uid == null) return;
    final isFemale = _gender.toLowerCase() == 'female';
    final measurement = Measurement(
      profileId: '',
      gender: _gender,
      bust: isFemale ? double.tryParse(_bustCtrl.text) : null,
      waist: double.tryParse(_waistCtrl.text),
      hip: isFemale ? double.tryParse(_hipCtrl.text) : null,
      chest: !isFemale ? double.tryParse(_chestCtrl.text) : null,
      shoulder: !isFemale ? double.tryParse(_shoulderCtrl.text) : null,
    );
    final result = await context.read<ProfileProvider>().createProfile(
      userId: uid,
      name: _nameCtrl.text.trim(),
      gender: _gender,
      height: double.parse(_heightCtrl.text),
      weight: double.parse(_weightCtrl.text),
      profileImage: _profileImage,
      measurements: measurement,
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile created successfully!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final isFemale = _gender.toLowerCase() == 'female';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Column(children: [
          const AppHeader(showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  const SizedBox(height: 16),
                  Text('Add Person',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  // Profile Image
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                  // Basic Info Card
                  CustomCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      CustomTextField(
                          label: 'Name', hint: 'Enter name', controller: _nameCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 16),
                      CustomDropdown(
                          label: 'Gender', value: _gender,
                          items: AppConstants.genders,
                          onChanged: (v) { if (v != null) setState(() => _gender = v); }),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: CustomTextField(
                                label: 'Height (cm)', hint: 'e.g. 165', controller: _heightCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: CustomTextField(
                                label: 'Weight (kg)', hint: 'e.g. 55', controller: _weightCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Measurements Card
                  CustomCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Measurements (cm)',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        if (isFemale) ...[
                          CustomTextField(
                              label: 'Bust', hint: 'e.g. 86', controller: _bustCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                          const SizedBox(height: 16),
                          CustomTextField(
                              label: 'Waist', hint: 'e.g. 68', controller: _waistCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                          const SizedBox(height: 16),
                          CustomTextField(
                              label: 'Hip', hint: 'e.g. 92', controller: _hipCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                        ] else ...[
                          CustomTextField(
                              label: 'Chest', hint: 'e.g. 96', controller: _chestCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                          const SizedBox(height: 16),
                          CustomTextField(
                              label: 'Waist', hint: 'e.g. 82', controller: _waistCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                          const SizedBox(height: 16),
                          CustomTextField(
                              label: 'Shoulder', hint: 'e.g. 46', controller: _shoulderCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                      text: 'Save Profile', isLoading: pp.isLoading,
                      onPressed: pp.isLoading ? null : _handleSave),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
          image: _profileImage != null
              ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _profileImage == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.camera_alt_rounded, size: 32, color: AppColors.accent),
                const SizedBox(height: 4),
                Text('Upload', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
              ])
            : null,
      ),
    );
  }
}
