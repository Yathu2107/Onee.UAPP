import 'package:flutter_test/flutter_test.dart';
import 'package:onee_uapp/app/routes/app_routes.dart';
import 'package:onee_uapp/utils/constants.dart';

void main() {
  test('Auth nextStep routing smoke', () {
    expect(
      AuthNextStep.routeFor('home_page'),
      AppRoutes.home,
    );
    expect(
      AuthNextStep.routeFor('register'),
      AppRoutes.completeRegistration,
    );
  });
}
