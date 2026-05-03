import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
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

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.upload);
        break;
      case 2:
        break;
    }
  }

  Future<void> _deleteProfile(UserProfile profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete ${profile.name}\'s profile?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final uid = context.read<AuthProvider>().userId;
      if (uid != null && profile.id != null) {
        await context.read<ProfileProvider>().deleteProfile(profile.id!, uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile deleted', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.accent,
          ));
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign Out',
                  style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<ProfileProvider>().clear();
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pp = context.watch<ProfileProvider>();

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
                Text('Profile',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Account info card
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.secondary,
                      child: Icon(Icons.person_rounded, size: 40, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    // Email
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(auth.userEmail ?? 'No email',
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
                    ]),
                    const SizedBox(height: 8),
                    // Phone placeholder
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Not provided',
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                    ]),
                  ]),
                ),

                const SizedBox(height: 24),

                // Saved Profiles section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Saved Profiles',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('${pp.profiles.length} profile${pp.profiles.length != 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),

                if (pp.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                  )
                else if (pp.profiles.isEmpty)
                  CustomCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      Icon(Icons.person_add_rounded, size: 40, color: AppColors.accent.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text('No profiles saved yet',
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                    ]),
                  )
                else
                  ...pp.profiles.map((p) => _buildProfileCard(p)),

                const SizedBox(height: 16),

                // Add new profile
                CustomButton(
                  text: 'Add New Profile',
                  icon: Icons.person_add_rounded,
                  isOutlined: true,
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addPerson),
                ),

                const SizedBox(height: 24),

                // Logout button
                CustomButton(
                  text: 'Sign Out',
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  textColor: AppColors.error,
                  icon: Icons.logout_rounded,
                  onPressed: _handleLogout,
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 2, onTap: _onNavTap),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    final isSelected = context.read<ProfileProvider>().selectedProfile?.id == profile.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        color: isSelected ? AppColors.secondary.withOpacity(0.3) : null,
        child: Row(children: [
          // Profile image
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.secondary,
            backgroundImage:
                profile.profileImageUrl != null ? NetworkImage(profile.profileImageUrl!) : null,
            // Image will be loaded from Supabase Storage
            child: profile.profileImageUrl == null
                ? Text(profile.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary))
                : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(profile.name,
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Active',
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accent)),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text('${profile.gender} • ${profile.height.toStringAsFixed(0)} cm • ${profile.weight.toStringAsFixed(0)} kg',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
            color: AppColors.cardFill,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'delete') _deleteProfile(profile);
              if (v == 'select') {
                context.read<ProfileProvider>().selectProfile(profile);
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'select',
                  child: Row(children: [
                    Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text('Use Profile', style: GoogleFonts.poppins(fontSize: 13)),
                  ])),
              PopupMenuItem(value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Delete', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.error)),
                  ])),
            ],
          ),
        ]),
      ),
    );
  }
}
