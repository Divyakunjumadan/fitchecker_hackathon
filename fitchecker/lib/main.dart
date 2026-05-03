import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/login_screen.dart';
import 'screens/user_selection_screen.dart';
import 'screens/add_person_screen.dart';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/result_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.primary,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FitCheckerApp());
}

class FitCheckerApp extends StatelessWidget {
  const FitCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Fit Checker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        // Check auth state and route accordingly
        home: const _AuthGate(),
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case AppRoutes.login:
              page = const LoginScreen();
              break;
            case AppRoutes.userSelection:
              page = const UserSelectionScreen();
              break;
            case AppRoutes.addPerson:
              page = const AddPersonScreen();
              break;
            case AppRoutes.home:
              page = const HomeScreen();
              break;
            case AppRoutes.upload:
              page = const UploadScreen();
              break;
            case AppRoutes.result:
              page = const ResultScreen();
              break;
            case AppRoutes.profile:
              page = const ProfileScreen();
              break;
            default:
              page = const LoginScreen();
          }
          return FadeSlideRoute(page: page);
        },
      ),
    );
  }
}

/// Gate widget that checks auth state and navigates accordingly
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoggedIn) {
      return const UserSelectionScreen();
    }
    return const LoginScreen();
  }
}
