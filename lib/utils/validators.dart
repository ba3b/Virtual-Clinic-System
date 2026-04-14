class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'invalid_email';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required';
    }
    
    if (value.length < 6) {
      return 'password_min_length';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'name_required';
    }
    
    if (value.length < 2) {
      return 'name_min_length';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_required';
    }
    
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'invalid_phone';
    }
    
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'address_required';
    }
    
    if (value.length < 5) {
      return 'address_incomplete';
    }
    
    return null;
  }

  static String? validateConfirmationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'code_required';
    }
    
    if (value.length != 6) {
      return 'code_length';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'code_numbers_only';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'confirm_password_required';
    }
    
    if (value != password) {
      return 'passwords_dont_match';
    }
    
    return null;
  }

  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
}