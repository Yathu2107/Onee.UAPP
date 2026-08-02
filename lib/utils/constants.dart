import '../app/routes/app_routes.dart';

class AppConstants {
  AppConstants._();

  static const String accountsPath = '/accounts';
  static const String jobsPath = '/jobs';
  static const String addressesPath = '/addresses';
  static const String notificationsPath = '/notifications';
  static const String complaintsPath = '/complaints';
  static const int otpLength = 6;
  static const int otpExpirySeconds = 5 * 60;
  static const int otpResendCooldownSeconds = 60;
  static const String phoneRegex = r'^07\d{8}$';
}

/// Routes nextStep values returned by verify-otp.
class AuthNextStep {
  AuthNextStep._();

  static const String homePage = 'home_page';
  static const String register = 'register';

  /// Maps API nextStep to a named app route.
  static String routeFor(String? nextStep) {
    if (nextStep == register) {
      return AppRoutes.completeRegistration;
    }
    return AppRoutes.home;
  }

  static bool isRegister(String? nextStep) => nextStep == register;
}
