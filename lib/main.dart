import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bible_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/church/create_church_screen.dart';
import 'screens/church/join_church_screen.dart';
import 'screens/testimony/testimony_vault_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Notifications
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp(
          title: 'Ekklesia',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          darkTheme: themeProvider.themeData,
          themeMode: themeProvider.currentTheme.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const AuthWrapper(),
          routes: {
            '/landing': (context) => const LandingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/create-church': (context) => const CreateChurchScreen(),
            '/join-church': (context) => const JoinChurchScreen(),
            '/testimony-vault': (context) => const TestimonyVaultScreen(),
          },
        ),
      ),
    );
  }
}


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final themeProvider = context.read<ThemeProvider>();

      await authProvider.initialize();

      // Load church theme if user is authenticated
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        await themeProvider.loadChurchTheme(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
