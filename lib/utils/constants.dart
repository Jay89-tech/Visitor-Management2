// lib/utils/constants.dart

class AppConstants {
  // App Info
  static const String appName = 'Visitor Management';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Check-In System';

  // Time Constants
  static const int qrValidityHours = 2;
  static const int sessionTimeoutMinutes = 30;
  static const int refreshInterval = 60; // seconds

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxNotesLength = 500;
  static const int minPhoneLength = 10;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxDocumentSizeMB = 10;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx'];

  // Visit Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusDenied = 'denied';
  static const String statusCancelled = 'cancelled';

  // Notification Types
  static const String notifVisitApproved = 'visit_approved';
  static const String notifVisitDenied = 'visit_denied';
  static const String notifVisitReminder = 'visit_reminder';
  static const String notifCheckInSuccess = 'check_in_success';
  static const String notifCheckOutSuccess = 'check_out_success';
  static const String notifWelcome = 'welcome';

  // Firestore Collections
  static const String collectionVisitors = 'visitors';
  static const String collectionVisits = 'visits';
  static const String collectionCheckIns = 'checkins';
  static const String collectionNotifications = 'notifications';
  static const String collectionAdmins = 'admins';

  // Storage Paths
  static const String storageProfiles = 'profiles';
  static const String storageDocuments = 'documents';

  // Error Messages
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorPermission = 'Permission denied.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorInvalidQR = 'Invalid QR code.';

  // Success Messages
  static const String successVisitCreated =
      'Visit request submitted successfully';
  static const String successVisitCancelled = 'Visit cancelled successfully';
  static const String successCheckIn = 'Checked in successfully';
  static const String successCheckOut = 'Checked out successfully';
  static const String successProfileUpdated = 'Profile updated successfully';

  // Departments
  static const List<String> departments = [
    'IT',
    'HR',
    'Finance',
    'Operations',
    'Marketing',
    'Sales',
    'Administration',
    'Legal',
    'Customer Service',
    'Research & Development',
    'Other',
  ];

  // Visit Purposes
  static const List<String> visitPurposes = [
    'Business Meeting',
    'Interview',
    'Delivery',
    'Maintenance',
    'Training',
    'Consultation',
    'Client Visit',
    'Inspection',
    'Event',
    'Other',
  ];

  // Time Slots (in hours)
  static const List<String> timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  // Animation Durations
  static const int animationDurationShort = 300;
  static const int animationDurationMedium = 500;
  static const int animationDurationLong = 800;

  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  static final RegExp nameRegex = RegExp(
    r'^[a-zA-Z\s]+$',
  );

  // URLs
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
  static const String supportEmail = 'support@yourapp.com';
  static const String supportPhone = '+27 XXX XXX XXXX';
}
