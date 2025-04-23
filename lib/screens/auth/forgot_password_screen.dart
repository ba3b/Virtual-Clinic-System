import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_text_field.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';
import '../../utils/validators.dart';
import 'confirmation_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // This is a placeholder for actual password reset logic
      // In a real app, you would use AuthService to send a reset email
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset code sent to your email'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationCodeScreen(
              email: _emailController.text,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Forgot Password',
        backgroundColor: Colors.transparent,
        textColor: AppTheme.textPrimaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Password',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address. We\'ll send you a code to reset your password.',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendResetEmail(),
                ),
                const SizedBox(height: 32),
                
                // Send Reset Email Button
                CommonButton(
                  text: 'Send Reset Code',
                  isLoading: _isLoading,
                  onPressed: _sendResetEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}