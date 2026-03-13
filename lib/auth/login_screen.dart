import 'dart:ui';

import 'package:auto_port/auth/auth_validators.dart';
import 'package:auto_port/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Animation controllers for advanced color shifting
  late final AnimationController _gradientController;
  late final Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    // Setup a repeating gradient shift (color collaboration)
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _gradientAnimation = CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    );

    // Add listeners to update UI when input changes (for dynamic color)
    _emailController.addListener(_updateColorFromInput);
    _passwordController.addListener(_updateColorFromInput);
  }

  void _updateColorFromInput() {
    // Change the primary color intensity based on input length
    // (a simple "color collaboration" effect)
    setState(() {});
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _emailController.removeListener(_updateColorFromInput);
    _passwordController.removeListener(_updateColorFromInput);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authService.loginWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_formatError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatError(Object error) {
    return error is String ? error : 'Unable to sign in. Please try again.';
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(),
          ).animate().shake(duration: 600.ms, hz: 5),
          backgroundColor: isError
              ? const Color(0xFFB00020)
              : const Color(0xFF00F5FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // Dynamic primary color based on input length (color collaboration)
  Color get _dynamicCyan {
    final base = const Color(0xFF00F5FF);
    final intensity =
        (_emailController.text.length + _passwordController.text.length).clamp(
          0,
          20,
        ) /
        20.0; // max 20 chars combined
    return Color.lerp(base, const Color(0xFFAA00FF), intensity)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === CUTTING-EDGE LIVING BACKGROUND ===
          // Animated gradient background that shifts over time
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF05121F),
                        const Color(0xFF2A0E3F),
                        _gradientAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF0A2540),
                        const Color(0xFF1A3A5F),
                        _gradientAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF132F5E),
                        const Color(0xFF3E1E6B),
                        _gradientAnimation.value,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Futuristic Lottie particles / data grid overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/animations/tech.json', // Replace with your Lottie file
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              ),
            ),
          ),

          // Main content (glass card)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: _dynamicCyan.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _dynamicCyan.withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // === ANIMATED 3D LOGO WITH ROTATION ===
                            Center(
                              child:
                                  Animate(
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true),
                                        child: Image.asset(
                                          'assets/animations/balance.png',
                                          width: 92,
                                          height: 92,
                                        ),
                                      )
                                      .scale(
                                        duration: 800.ms,
                                        curve: Curves.elasticOut,
                                      )
                                      .then()
                                      .shimmer(
                                        duration: 1800.ms,
                                        color: _dynamicCyan,
                                      )
                                      .then()
                                      .rotate(
                                        begin: 0,
                                        end: 0.05,
                                        duration: 6.seconds,
                                        curve: Curves.easeInOut,
                                      ),
                            ),
                            const SizedBox(height: 16),

                            // Title + subtitle with parallax slide
                            Text(
                                  'AutoPort Operations',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: _dynamicCyan,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                            Text(
                                  'Secure access for terminal staff',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF9FB1C2),
                                  ),
                                )
                                .animate(delay: 200.ms)
                                .fadeIn()
                                .slideY(begin: 0.3),

                            const SizedBox(height: 32),

                            // Descriptive text with shimmer
                            Text(
                                  'Sign in to monitor AGVs, cranes, and delivery operations in real time.',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: const Color(0xFFB3C3D3),
                                  ),
                                )
                                .animate(delay: 400.ms)
                                .fadeIn()
                                .slideY(begin: 0.2)
                                .shimmer(
                                  delay: 1000.ms,
                                  duration: 1800.ms,
                                  color: Colors.white30,
                                ),

                            const SizedBox(height: 24),

                            // Neon info panel with animated border (color collaboration)
                            Animate(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _dynamicCyan.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: _dynamicCyan,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Accounts are created manually by the administrator in Firebase.',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFFCEEAF0),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .animate(
                                  delay: 600.ms,
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .fadeIn()
                                .scale()
                                .then()
                                .shimmer(
                                  duration: 3.seconds,
                                  color: Colors.white24,
                                )
                                .then()
                                .custom(
                                  duration: 4.seconds,
                                  builder: (context, value, child) {
                                    final border = Border.lerp(
                                      Border.all(color: _dynamicCyan, width: 1),
                                      Border.all(
                                        color: const Color(0xFFAA00FF),
                                        width: 2,
                                      ),
                                      value,
                                    )!;
                                    return DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: border,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: child,
                                    );
                                  },
                                ),

                            const SizedBox(height: 32),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Email field with dynamic neon focus
                                  Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        // Trigger a subtle scale animation on the whole card?
                                      }
                                    },
                                    child:
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            labelText: 'Email Address',
                                            labelStyle: GoogleFonts.inter(),
                                            prefixIcon: Icon(
                                              Icons.mail_outline,
                                              color: _dynamicCyan,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: _dynamicCyan,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFB00020),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            final error = AuthValidators.email(
                                              value,
                                            );
                                            if (error != null) {
                                              // Trigger a shake animation on the field
                                              return error;
                                            }
                                            return null;
                                          },
                                        ).animate().shake(
                                          delay: 500.ms,
                                          duration: 600.ms,
                                          hz: 3,
                                        ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field with morphing eye
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _login(),
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: GoogleFonts.inter(),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: _dynamicCyan,
                                      ),
                                      suffixIcon: AnimatedSwitcher(
                                        duration: 300.ms,
                                        transitionBuilder: (child, animation) {
                                          return RotationTransition(
                                            turns: animation,
                                            child: child,
                                          );
                                        },
                                        child: IconButton(
                                          key: ValueKey(_obscurePassword),
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: _dynamicCyan,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: _dynamicCyan,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFB00020),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      final error = AuthValidators.password(
                                        value,
                                      );
                                      if (error != null) {
                                        return error;
                                      }
                                      return null;
                                    },
                                  ).animate().shake(
                                    delay: 500.ms,
                                    duration: 600.ms,
                                    hz: 3,
                                  ),

                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => Navigator.pushNamed(
                                              context,
                                              '/forgot-password',
                                            ),
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.inter(
                                          color: _dynamicCyan,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Next-gen glowing button with intelligent pulse
                                  Animate(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 56,
                                          child: ElevatedButton(
                                            onPressed: _isLoading
                                                ? null
                                                : _login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _dynamicCyan,
                                              foregroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 8,
                                              shadowColor: _dynamicCyan
                                                  .withValues(alpha: 0.8),
                                            ),
                                            child: _isLoading
                                                ? SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    Colors
                                                                        .black,
                                                                  ),
                                                              strokeWidth: 3,
                                                            )
                                                            .animate(
                                                              onPlay:
                                                                  (
                                                                    controller,
                                                                  ) => controller
                                                                      .repeat(),
                                                            )
                                                            .rotate(
                                                              duration: 800.ms,
                                                              curve:
                                                                  Curves.linear,
                                                            ),
                                                  )
                                                : Text(
                                                    'Sign In',
                                                    style: GoogleFonts.orbitron(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      )
                                      .animate(
                                        delay: 1100.ms,
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true),
                                      )
                                      .fadeIn()
                                      .scale()
                                      .then()
                                      .shimmer(
                                        duration: 1800.ms,
                                        color: Colors.white70,
                                      )
                                      .then()
                                      .scale(
                                        duration: 2.seconds,
                                        curve: Curves.easeInOut,
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.03, 1.03),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
