import 'package:flutter_test/flutter_test.dart';
import 'package:onee_uapp/utils/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    test('accepts valid Sri Lankan local numbers', () {
      expect(PhoneValidator.isValidLocal('0712345678'), isTrue);
      expect(PhoneValidator.isValidLocal('0771234567'), isTrue);
    });

    test('rejects invalid numbers', () {
      expect(PhoneValidator.isValidLocal('712345678'), isFalse);
      expect(PhoneValidator.isValidLocal('94712345678'), isFalse);
      expect(PhoneValidator.isValidLocal('071234567'), isFalse);
      expect(PhoneValidator.isValidLocal('0812345678'), isFalse);
      expect(PhoneValidator.isValidLocal(''), isFalse);
      expect(PhoneValidator.isValidLocal(null), isFalse);
    });

    test('validate returns error messages', () {
      expect(PhoneValidator.validate(null), isNotNull);
      expect(PhoneValidator.validate('0712345678'), isNull);
    });
  });
}
