import 'package:flutter_test/flutter_test.dart';
import 'package:onee_uapp/app/routes/app_routes.dart';
import 'package:onee_uapp/utils/constants.dart';

void main() {
  group('AuthNextStep.routeFor', () {
    test('routes register nextStep to Complete Registration', () {
      expect(
        AuthNextStep.routeFor(AuthNextStep.register),
        AppRoutes.completeRegistration,
      );
      expect(AuthNextStep.isRegister('register'), isTrue);
    });

    test('routes home_page nextStep to Home', () {
      expect(
        AuthNextStep.routeFor(AuthNextStep.homePage),
        AppRoutes.home,
      );
      expect(AuthNextStep.isRegister('home_page'), isFalse);
    });

    test('defaults unknown or null nextStep to Home', () {
      expect(AuthNextStep.routeFor(null), AppRoutes.home);
      expect(AuthNextStep.routeFor(''), AppRoutes.home);
      expect(AuthNextStep.routeFor('something_else'), AppRoutes.home);
    });
  });
}
