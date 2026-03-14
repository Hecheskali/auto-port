import 'package:auto_port/auth/forgot_password_screen.dart';
import 'package:auto_port/auth/login_screen.dart';
import 'package:auto_port/home/home_screen.dart';
import 'package:auto_port/home/settings_notifications.dart';
import 'package:auto_port/providers/theme_provider.dart';
import 'package:auto_port/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? bootstrapError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    bootstrapError =
    'Unable to connect to backend services. Check Firebase setup and restart the app.\n\nDetails: $error';
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: AutoPortApp(bootstrapError: bootstrapError),
    ),
  );
}

class AutoPortApp extends StatelessWidget {
  const AutoPortApp({super.key, this.bootstrapError});

  final String? bootstrapError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoPort Operations',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: bootstrapError == null
          ? const _AuthGate()
          : _BootstrapErrorScreen(message: bootstrapError!),
      routes: {
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    const primary = Color(0xFF0F6E8C);
    const surface = Color(0xFF11263A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        secondary: const Color(0xFF1E9EB9),
        surface: surface,
        error: const Color(0xFFE76F51),
      ),
      scaffoldBackgroundColor: const Color(0xFF081A2B),
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF0D2235),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF10263A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F2A3D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A54)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1E9EB9),
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF95A6B8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E9EB9),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0D2235),
        indicatorColor: const Color(0xFF1E9EB9).withOpacity(0.2),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LaunchScreen();
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_rounded,
              size: 44,
              color: Color(0xFF1E9EB9),
            ),
            SizedBox(height: 12),
            Text(
              'AutoPort Operations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: Color(0xFFE76F51),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Startup failed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFFB3C3D3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
