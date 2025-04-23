import 'package:flutter/material.dart';
import '../../components/app_logo.dart';
import '../../components/custom_text_field.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';
import '../../utils/validators.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// Placeholder imports for the home screens which will be implemented later
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../staff/staff_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // This is a placeholder for actual login logic
      // In a real app, you would use AuthService to authenticate the user
      // and navigate to the appropriate home screen based on user type
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo, we'll navigate to different screens based on email
      String email = _emailController.text.toLowerCase();
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        if (email.contains('patient')) {
          // Navigate to patient home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
          );
        } else if (email.contains('doctor')) {
          // Navigate to doctor home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
          );
        } else if (email.contains('staff')) {
          // Navigate to staff home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StaffHomeScreen()),
          );
        } else {
          // Default to patient
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: AppLogo(
                    size: 100,
                    showText: true,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Login',
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Please login to your account',
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
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Button
                CommonButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 24),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: AppTheme.bodySmallStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}