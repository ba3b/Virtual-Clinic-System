import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_text_field.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';
import '../../utils/validators.dart';
import '../../api/auth_service.dart';
import '../../localization/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

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
      
      try {
        String? error = await _authService.sendPasswordResetEmail(_emailController.text.trim());
        
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          if (error == null) {
            setState(() {
              _emailSent = true;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmailForm() {
    final tr = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.translate('reset_password'),
          style: AppTheme.headingStyle,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 32),
        
        CustomTextField(
          label: tr.translate('email'),
          hint: tr.translate('enter_email'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: Validators.validateEmail,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _sendResetEmail(),
          enabled: !_isLoading,
        ),
        const SizedBox(height: 32),
        
        CommonButton(
          text: tr.translate('send_link'),
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _sendResetEmail,
        ),
        
        const SizedBox(height: 16),
        
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text(
              'Back to Login',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppTheme.successColor,
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Check Your Email',
          style: AppTheme.headingStyle,
        ),
        const SizedBox(height: 8),
        
        Text(
          'We\'ve sent a password reset link to ${_emailController.text.trim()}',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next Steps:',
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Check your email inbox (and spam folder)\n2. Click the reset link in the email\n3. Follow the instructions to set a new password\n4. Return to the app and login',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        CommonButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
        
        const SizedBox(height: 16),
        
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
              });
            },
            child: Text(
              'Send to Different Email',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: tr.translate('forgot_password'),
        backgroundColor: Colors.transparent,
        textColor: AppTheme.textPrimaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: _emailSent ? _buildSuccessMessage() : _buildEmailForm(),
          ),
        ),
      ),
    );
  }
}