import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtual_clinic_system/api/auth_service.dart';
import 'package:virtual_clinic_system/screens/wrapper.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_text_field.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  
  String _selectedUserType = 'patient';
  String _selectedGender = 'male';
  DateTime? _selectedDateOfBirth;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<Map<String, dynamic>> _userTypes = [
    {'value': 'patient', 'label': 'Patient'},
    {'value': 'doctor', 'label': 'Doctor'},
    {'value': 'staff', 'label': 'Staff'},
  ];

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your date of birth'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      
      User? result = await _auth.register(
        _nameController.text.trim(), 
        _emailController.text.trim().toLowerCase(), 
        _passwordController.text, 
        _phoneController.text, 
        _addressController.text, 
        _selectedUserType,
        _nationalIdController.text.trim(),
        _selectedGender,
        _selectedDateOfBirth!,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        if(result == null){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again later.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Wrapper()),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Create Account',
        backgroundColor: Colors.transparent,
        textColor: AppTheme.textPrimaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Up',
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to get started',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // User Type Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I am a:',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUserType,
                          isExpanded: true,
                          elevation: 2,
                          style: AppTheme.bodyStyle,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedUserType = newValue;
                              });
                            }
                          },
                          items: _userTypes.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                            return DropdownMenuItem<String>(
                              value: item['value'],
                              child: Text(item['label']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name Field
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: Validators.validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // National ID Field
                CustomTextField(
                  label: 'National ID',
                  hint: 'Enter your national ID number',
                  controller: _nationalIdController,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'National ID is required';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid national ID';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Gender Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          elevation: 2,
                          style: AppTheme.bodyStyle,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            }
                          },
                          items: _genderOptions.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                            return DropdownMenuItem<String>(
                              value: item['value'],
                              child: Text(item['label']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date of Birth Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateOfBirth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppTheme.textSecondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDateOfBirth != null
                                  ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
                                  : 'Select your date of birth',
                              style: AppTheme.bodyStyle.copyWith(
                                color: _selectedDateOfBirth != null 
                                    ? AppTheme.textPrimaryColor 
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
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
                
                // Phone Field
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: Validators.validatePhoneNumber,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                
                // Address Field
                CustomTextField(
                  label: 'Address',
                  hint: 'Enter your address',
                  controller: _addressController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  validator: Validators.validateAddress,
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
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 32),
                
                // Register Button
                CommonButton(
                  text: 'Register',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: AppTheme.bodySmallStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Login',
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