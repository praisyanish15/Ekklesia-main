import 'package:email_validator/email_validator.dart';
import '../constants/app_constants.dart';

class Validators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.fieldRequiredError;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.fieldRequiredError;
    }
    if (!EmailValidator.validate(value.trim())) {
      return AppConstants.invalidEmailError;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredError;
    }
    if (value.length < 8) {
      return AppConstants.passwordTooShortError;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional in some cases
    }
    // Basic Indian phone number validation
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return AppConstants.invalidPhoneError;
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Age is optional
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 150) {
      return 'Please enter a valid age';
    }
    return null;
  }

  static String? validateRequiredDropdown(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty || value == 'Select') {
      return AppConstants.fieldRequiredError;
    }
    return null;
  }
}
