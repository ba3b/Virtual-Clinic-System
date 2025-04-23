import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/custom_app_bar.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';
import 'new_password_screen.dart';

class ConfirmationCodeScreen extends StatefulWidget {
  final String email;

  const ConfirmationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<ConfirmationCodeScreen> createState() => _ConfirmationCodeScreenState();
}

class _ConfirmationCodeScreenState extends State<ConfirmationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers = List.generate(
    6, 
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, 
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCodeDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  String _getFullCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // This is a placeholder for actual code verification logic
      // In a real app, you would use AuthService to verify the code
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(
              email: widget.email,
              code: _getFullCode(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code resent'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Verification',
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
                Text(
                  'Enter Verification Code',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ve sent a verification code to ${widget.email}. Enter it below to reset your password.',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Code Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 48,
                      child: TextFormField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTheme.headingStyle.copyWith(fontSize: 24),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                          ),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onCodeDigitChanged(index, value),
                        validator: (value) => value == null || value.isEmpty
                            ? ''  // Just show red border
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Resend Code
                Center(
                  child: TextButton(
                    onPressed: _resendCode,
                    child: Text(
                      'Didn\'t receive the code? Resend',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Verify Button
                CommonButton(
                  text: 'Verify',
                  isLoading: _isLoading,
                  onPressed: _verifyCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}