import '../../../utils/json_helpers.dart';

class OtpVerifyResult {
  const OtpVerifyResult({
    this.message,
    this.userName,
    this.email,
    this.role,
    this.token,
    this.refreshToken,
    this.refreshTokenExpiration,
    this.nextStep,
  });

  final String? message;
  final String? userName;
  final String? email;
  final String? role;
  final String? token;
  final String? refreshToken;
  final String? refreshTokenExpiration;
  final String? nextStep;

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResult(
      message: json['message']?.toString(),
      userName: json['userName']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      token: json['token']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      refreshTokenExpiration: json['refreshTokenExpiration']?.toString(),
      nextStep: json['nextStep']?.toString(),
    );
  }
}

class UserDetails {
  const UserDetails({
    this.name,
    this.email,
    this.phoneNumber,
    this.proImg,
    this.isOnline,
    this.isActive,
    this.latitude,
    this.longitude,
  });

  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? proImg;
  final bool? isOnline;
  final bool? isActive;
  final double? latitude;
  final double? longitude;

  bool get hasName => name != null && name!.trim().isNotEmpty;

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: JsonHelpers.pickString(json, ['name', 'Name', 'userName', 'UserName']),
      email: JsonHelpers.pickString(json, ['email', 'Email']),
      phoneNumber: JsonHelpers.pickString(json, [
        'phoneNumber',
        'PhoneNumber',
        'phone',
        'Phone',
      ]),
      proImg: JsonHelpers.pickString(json, [
        'proImg',
        'ProImg',
        'profileImage',
        'image',
      ]),
      isOnline: JsonHelpers.pickBool(json, ['isOnline', 'IsOnline']),
      isActive: JsonHelpers.pickBool(json, ['isActive', 'IsActive']),
      latitude: JsonHelpers.pickDouble(json, ['latitude', 'Latitude']),
      longitude: JsonHelpers.pickDouble(json, ['longitude', 'Longitude']),
    );
  }
}
