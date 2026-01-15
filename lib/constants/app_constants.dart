class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ifztzseuhhlsyhomtvff.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmenR6c2V1aGhsc3lob210dmZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0ODc1MTgsImV4cCI6MjA4NDA2MzUxOH0.sV2rdtixAop7ecPRS-qhGpS0mYcGsBbaEe125EhCKHA';

  // Razorpay Configuration
  // TODO: Replace with your Razorpay Test Key ID from https://dashboard.razorpay.com/app/keys
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID'; // e.g., 'rzp_test_xxxxx'
  // TODO: Replace with your Razorpay Key Secret (keep this private!)
  static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';

  // Bible API Configuration
  static const String bibleApiUrl = 'https://bible-api.com';

  // Image Upload Constraints
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  // Form Validation Messages
  static const String fieldRequiredError = 'This field cannot be left blank';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String invalidPhoneError = 'Please enter a valid phone number';
  static const String passwordTooShortError =
      'Password must be at least 8 characters';

  // Gender Options
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Bible Versions
  static const List<String> bibleVersions = [
    'KJV',
    'NIV',
    'ESV',
    'NKJV',
    'NLT',
  ];

  // Font Size Range
  static const double minFontSize = 12.0;
  static const double maxFontSize = 30.0;
  static const double defaultFontSize = 16.0;
}
