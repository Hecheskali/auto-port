import 'package:auto_port/auth/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Function to send the reset email
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // Firebase Auth call
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // Customize error messages
      String message;
      if (e.code == 'user-not-found') {
        message = 'If this email exists, a password reset email has been sent.';
      } else {
        message = e.message ?? 'Unable to send reset email. Please try again.';
      }

      _showError(message);
    } catch (e) {
      if (!mounted) return;
      _showError('Unable to send reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Show error snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFB00020),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Recovery')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF061523), Color(0xFF0A2235)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: !_emailSent ? _buildForm() : _buildSuccessState(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Form UI
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset your password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your account email to receive a password reset link.',
          style: TextStyle(color: Color(0xFFB3C3D3)),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _sendResetEmail(),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendResetEmail,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Link'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Success UI
  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: Color(0xFF72CCE0),
        ),
        const SizedBox(height: 16),
        const Text(
          'Email sent',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'If ${_emailController.text.trim()} exists, a password reset email has been sent.',
          style: const TextStyle(color: Color(0xFFB3C3D3)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
