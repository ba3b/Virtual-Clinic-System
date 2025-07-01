import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:virtual_clinic_system/api/auth_service.dart';
import 'package:virtual_clinic_system/constants/departments.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_text_field.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';
import '../../utils/validators.dart';

class StaffRegisterUserScreen extends StatefulWidget {
  const StaffRegisterUserScreen({super.key});

  @override
  State<StaffRegisterUserScreen> createState() => _StaffRegisterUserScreenState();
}

class _StaffRegisterUserScreenState extends State<StaffRegisterUserScreen>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();

  String _selectedUserType = 'doctor';
  String _selectedGender = 'male';
  String _selectedSpecialty = DepartmentConstants.generalMedicine;
  DateTime? _selectedDateOfBirth;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  final List<Map<String, dynamic>> _userTypeOptions = [
    {'value': 'doctor', 'label': 'Doctor', 'icon': Icons.medical_services_outlined},
    {'value': 'staff', 'label': 'Staff', 'icon': Icons.admin_panel_settings_outlined},
  ];

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'male', 'label': 'Male', 'icon': Icons.male},
    {'value': 'female', 'label': 'Female', 'icon': Icons.female},
  ];

  final List<String> _specialties = DepartmentConstants.allDepartments;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _passwordController.addListener(() {
      _updatePasswordStrength();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);

    setState(() {
      _passwordStrength = strength;
      if (password.isEmpty) {
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.grey;
      } else if (strength < 0.3) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.7) {
        _passwordStrengthText = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  bool _isPasswordStrong() {
    return _passwordStrength >= 0.7;
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
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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

  String? _validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'National ID is required';
    }
    if (value.length != 10) {
      return 'National ID must be exactly 10 digits';
    }
    if (!RegExp(r'^[12]\d{9}$').hasMatch(value)) {
      return 'National ID must start with 1 or 2 and contain only numbers';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
      return 'Phone number must start with 05 and contain only numbers';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!_isPasswordStrong()) {
      return 'Password is not strong enough';
    }
    return null;
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateOfBirth == null) {
        _showErrorSnackBar('Please select date of birth');
        return;
      }

      if (!_isPasswordStrong()) {
        _showErrorSnackBar('Please use a stronger password');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        User? result = await _auth.registerUserByStaff(
          _nameController.text.trim(),
          _emailController.text.trim().toLowerCase(),
          _passwordController.text,
          _phoneController.text,
          _addressController.text,
          _selectedUserType,
          _nationalIdController.text.trim(),
          _selectedGender,
          _selectedDateOfBirth!,
          _selectedUserType == 'doctor' ? _selectedSpecialty : null,
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          if (result != null) {
            _showSuccessDialog();
          } else {
            _showErrorSnackBar('Registration failed. Please try again.');
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          String errorMessage = 'Registration failed';
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'An account with this email already exists';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Password is too weak';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Invalid email format';
          } else {
            errorMessage = 'Registration failed: ${e.toString().replaceAll('Exception: ', '')}';
          }
          _showErrorSnackBar(errorMessage);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.successColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Success!',
              style: AppTheme.headingStyle.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_selectedUserType == 'doctor' ? 'Doctor' : 'Staff'} account created successfully!\n\nYou will be redirected to the login screen to continue.',
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please sign in with your staff credentials to continue working.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CommonButton(
              text: 'Continue to Login',
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.shade300,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _passwordStrength,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: _passwordStrengthColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _passwordStrengthColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _passwordStrengthColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _passwordStrengthText,
                style: TextStyle(
                  color: _passwordStrengthColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Password must contain: uppercase, lowercase, number, and special character (min 8 chars)',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(
        title: 'Register New User',
        backgroundColor: Colors.transparent,
        textColor: AppTheme.textPrimaryColor,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildUserTypeSelector(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildContactInfoSection(),
                    const SizedBox(height: 24),
                    _buildSecuritySection(),
                    const SizedBox(height: 32),
                    _buildRegisterButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withGreen(180),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register New User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create accounts for doctors and staff members',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'User Type',
                style: AppTheme.subheadingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _userTypeOptions.map((option) {
              final isSelected = _selectedUserType == option['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUserType = option['value'];
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: option['value'] == 'doctor' ? 8 : 0,
                      left: option['value'] == 'staff' ? 8 : 0,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          option['icon'],
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['label'],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Personal Information',
                style: AppTheme.subheadingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Full Name',
            hint: 'Enter full name',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
            validator: Validators.validateName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'National ID',
            hint: 'Enter 10-digit national ID',
            controller: _nationalIdController,
            prefixIcon: const Icon(Icons.badge_outlined),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: _validateNationalId,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
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
                          items: _genderOptions.map<DropdownMenuItem<String>>((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Row(
                                children: [
                                  Icon(
                                    option['icon'],
                                    size: 18,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(option['label']),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppTheme.textSecondaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDateOfBirth != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_selectedDateOfBirth!)
                                    : 'Select date',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: _selectedDateOfBirth != null
                                      ? AppTheme.textPrimaryColor
                                      : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedUserType == 'doctor') ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Medical Specialty',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSpecialty,
                      isExpanded: true,
                      elevation: 2,
                      style: AppTheme.bodyStyle,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSpecialty = newValue;
                          });
                        }
                      },
                      items: _specialties.map<DropdownMenuItem<String>>((specialty) {
                        return DropdownMenuItem<String>(
                          value: specialty,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _selectedSpecialty == specialty 
                                      ? AppTheme.primaryColor 
                                      : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  specialty,
                                  style: TextStyle(
                                    fontWeight: _selectedSpecialty == specialty 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected specialty: $_selectedSpecialty',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.contact_mail_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: AppTheme.subheadingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Email',
            hint: 'Enter email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: Validators.validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter phone number (05xxxxxxxx)',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: _validatePhoneNumber,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Address',
            hint: 'Enter address',
            controller: _addressController,
            prefixIcon: const Icon(Icons.location_on_outlined),
            validator: Validators.validateAddress,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Security Information',
                style: AppTheme.subheadingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Password',
                hint: 'Enter password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: _validatePassword,
                textInputAction: TextInputAction.next,
              ),
              _buildPasswordStrengthIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Confirm password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: _toggleConfirmPasswordVisibility,
            ),
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _registerUser(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return CommonButton(
      text: 'Register ${_selectedUserType == 'doctor' ? 'Doctor' : 'Staff'}',
      isLoading: _isLoading,
      onPressed: _registerUser,
    );
  }
}