import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  File? _clothingImage;
  String? _selectedBrand;
  String? _selectedSize;
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
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickClothingImage() async {
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
            Text('Select Clothing Image',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _sourceOption(Icons.camera_alt_rounded, 'Camera',
                  () => Navigator.pop(ctx, ImageSource.camera)),
              _sourceOption(Icons.photo_library_rounded, 'Gallery',
                  () => Navigator.pop(ctx, ImageSource.gallery)),
            ]),
          ]),
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 90);
    if (picked != null) setState(() => _clothingImage = File(picked.path));
  }

  Widget _sourceOption(IconData icon, String label, VoidCallback onTap) {
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
        Text(label, style: GoogleFonts.poppins(fontSize: 13)),
      ]),
    );
  }

  void _handleCheckFit() {
    if (_clothingImage == null) {
      _showError('Please upload a clothing image');
      return;
    }
    if (_selectedBrand == null) {
      _showError('Please select a brand');
      return;
    }
    if (_selectedSize == null) {
      _showError('Please select a size');
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.result, arguments: {
      'clothingImage': _clothingImage,
      'brand': _selectedBrand,
      'size': _selectedSize,
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: AppColors.error,
    ));
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case 1:
        break; // Current
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(children: [
                const SizedBox(height: 16),
                Text('Upload Clothing',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                // Image picker area
                GestureDetector(
                  onTap: _pickClothingImage,
                  child: CustomCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                      child: _clothingImage != null
                          ? Image.file(_clothingImage!, height: 280, width: double.infinity, fit: BoxFit.cover)
                          : Container(
                              height: 280,
                              width: double.infinity,
                              color: AppColors.inputFill,
                              // Image will be loaded from Supabase Storage
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_rounded, size: 56, color: AppColors.accent.withOpacity(0.6)),
                                  const SizedBox(height: 12),
                                  Text('Tap to upload clothing image',
                                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('JPG, PNG supported',
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.5))),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Details Card
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    CustomDropdown(
                        label: 'Brand', value: _selectedBrand,
                        items: AppConstants.supportedBrands, hint: 'Select brand',
                        onChanged: (v) => setState(() => _selectedBrand = v)),
                    const SizedBox(height: 20),
                    CustomDropdown(
                        label: 'Size', value: _selectedSize,
                        items: AppConstants.supportedSizes, hint: 'Select size',
                        onChanged: (v) => setState(() => _selectedSize = v)),
                  ]),
                ),
                const SizedBox(height: 28),
                CustomButton(
                    text: 'Check Fit ✨', onPressed: _handleCheckFit),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 1, onTap: _onNavTap),
    );
  }
}
