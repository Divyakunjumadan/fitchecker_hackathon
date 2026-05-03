import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
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
        break; // Already on home
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.upload);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final name = pp.selectedProfile?.name ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background placeholder
                  // Replace this with your own background image asset
                  // Example: Image.asset('assets/background.jpg', fit: BoxFit.cover)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background,
                          AppColors.primary.withOpacity(0.6),
                          AppColors.secondary.withOpacity(0.4),
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.08,
                        child: Icon(
                          Icons.checkroom_rounded,
                          size: 200,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  // REPLACE_WITH_BACKGROUND_IMAGE
                  // To use a custom background:
                  // 1. Add your image to assets/ folder
                  // 2. Add it to pubspec.yaml under assets
                  // 3. Replace the Container above with:
                  //    Image.asset('assets/your_background.jpg', fit: BoxFit.cover)

                  // Content overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withOpacity(0.3),
                          AppColors.background.withOpacity(0.1),
                          AppColors.background.withOpacity(0.7),
                          AppColors.background.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Welcome text
                        Text(
                          'Welcome $name!',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Effortless style begins\nwith the perfect fit',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Spacer(flex: 3),

                        // Upload CTA
                        CustomButton(
                          text: 'Upload an image',
                          icon: Icons.cloud_upload_outlined,
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.upload),
                        ),

                        const SizedBox(height: 16),

                        // Switch profile
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.userSelection),
                          child: Text(
                            'Switch profile',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 0, onTap: _onNavTap),
    );
  }
}
