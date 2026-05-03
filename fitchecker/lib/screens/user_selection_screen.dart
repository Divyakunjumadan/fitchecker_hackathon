import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedProfileId;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().userId;
      if (uid != null) context.read<ProfileProvider>().loadProfiles(uid);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    final pp = context.read<ProfileProvider>();
    final sel = pp.profiles.firstWhere((p) => p.id == _selectedProfileId);
    pp.selectProfile(sel);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    CustomCard(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Text('USER AS',
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 28),
                          if (pp.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: AppColors.accent, strokeWidth: 2),
                            )
                          else if (pp.profiles.isNotEmpty) ...[
                            _buildDropdown(pp),
                            if (_selectedProfileId != null) ...[
                              const SizedBox(height: 20),
                              CustomButton(text: 'Continue', onPressed: _onContinue),
                            ],
                          ] else
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('No profiles yet. Add a person to get started!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: AppColors.textSecondary)),
                            ),
                          const SizedBox(height: 24),
                          _buildOrDivider(),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Add new person details',
                            isOutlined: true,
                            icon: Icons.add_circle_outline_rounded,
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRoutes.addPerson),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(ProfileProvider pp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProfileId,
          hint: Text('${pp.profiles.first.name} ?',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textSecondary.withOpacity(0.6))),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accent, size: 24),
          dropdownColor: AppColors.inputFill,
          borderRadius: BorderRadius.circular(16),
          items: pp.profiles
              .map((p) => DropdownMenuItem<String>(
                    value: p.id,
                    child: Row(children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.secondary,
                        backgroundImage:
                            p.profileImageUrl != null ? NetworkImage(p.profileImageUrl!) : null,
                        child: p.profileImageUrl == null
                            ? Text(p.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(p.name, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
                    ]),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedProfileId = v),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(children: [
      Expanded(child: Divider(color: AppColors.divider.withOpacity(0.5))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('OR',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      Expanded(child: Divider(color: AppColors.divider.withOpacity(0.5))),
    ]);
  }
}
