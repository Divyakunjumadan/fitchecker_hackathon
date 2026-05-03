import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../models/fit_result.dart';
import '../providers/profile_provider.dart';
import '../services/fit_check_service.dart';
import '../services/ai_service.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  FitResult? _fitResult;
  bool _isLoadingAI = true;
  bool _hasInitialized = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _runAnalysis();
    }
  }

  Future<void> _runAnalysis() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    final clothingImage = args['clothingImage'] as File;
    final brand = args['brand'] as String;
    final size = args['size'] as String;

    final pp = context.read<ProfileProvider>();
    final measurement = pp.selectedMeasurement;

    // 1. Run rule-based fit check
    if (measurement != null) {
      final fitService = FitCheckService();
      final result = fitService.checkFit(
          userMeasurements: measurement, brand: brand, size: size);
      setState(() => _fitResult = result);
    } else {
      setState(() => _fitResult = FitResult(
          status: FitStatus.slightAdjustments,
          statusText: 'Measurements Missing',
          adjustments: [],
          summary: 'Please add your measurements to get accurate fit results.'));
    }

    // 2. Run AI analysis
    try {
      final aiService = AIService();
      final profile = pp.selectedProfile;
      final advice = await aiService.generateStylingAdvice(
        clothingImage: clothingImage,
        gender: profile?.gender ?? 'Female',
        height: profile?.height,
        weight: profile?.weight,
      );
      setState(() {
        _fitResult = _fitResult?.copyWith(aiAnalysis: advice);
        _isLoadingAI = false;
      });
    } catch (e) {
      setState(() => _isLoadingAI = false);
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.upload);
        break;
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
            child: _fitResult == null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                      const SizedBox(height: 16),
                      Text('Analyzing your fit...',
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                    ]))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(children: [
                      const SizedBox(height: 16),
                      Text('Results',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 20),
                      // AI Analysis Section
                      _buildAISection(),
                      const SizedBox(height: 16),
                      // Fit Result Section
                      _buildFitSection(),
                      const SizedBox(height: 28),
                      CustomButton(
                          text: 'Try Another',
                          icon: Icons.refresh_rounded,
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.upload)),
                      const SizedBox(height: 12),
                      CustomButton(
                          text: 'Back to Home',
                          isOutlined: true,
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home)),
                      const SizedBox(height: 40),
                    ]),
                  ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 1, onTap: _onNavTap),
    );
  }

  Widget _buildAISection() {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('General Analysis',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 16),
        Divider(color: AppColors.divider.withOpacity(0.5), height: 1),
        const SizedBox(height: 16),
        if (_isLoadingAI)
          Column(children: [
            const LinearProgressIndicator(
                color: AppColors.accent, backgroundColor: AppColors.inputFill, minHeight: 2),
            const SizedBox(height: 12),
            Text('Generating styling advice...',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          ])
        else
          Text(_fitResult?.aiAnalysis ?? 'AI analysis unavailable.',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.7)),
      ]),
    );
  }

  Widget _buildFitSection() {
    final result = _fitResult!;
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('📏', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('Fit Result',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 16),
        Divider(color: AppColors.divider.withOpacity(0.5), height: 1),
        const SizedBox(height: 16),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _statusColor(result.status).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _statusColor(result.status).withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(result.statusEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(result.statusText,
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: _statusColor(result.status))),
          ]),
        ),
        const SizedBox(height: 20),
        // Summary
        Text(result.summary,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
        // Adjustment details
        if (result.adjustments.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...result.adjustments.map((adj) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(adj.direction == 'tight' ? Icons.compress_rounded : Icons.expand_rounded,
                      size: 18,
                      color: adj.direction == 'tight' ? AppColors.error : AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(adj.suggestion,
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.5))),
                ]),
              )),
        ],
      ]),
    );
  }

  Color _statusColor(FitStatus status) {
    switch (status) {
      case FitStatus.perfectFit:
        return AppColors.success;
      case FitStatus.slightAdjustments:
        return AppColors.warning;
      case FitStatus.notRecommended:
        return AppColors.error;
    }
  }
}
