import '../../profile/models/user_profile_models.dart';

class OtpResponseModel {
  final bool success;
  final String message;

  const OtpResponseModel({
    required this.success,
    required this.message,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OtpResponseModel(success: false, message: '');
    }
    return OtpResponseModel(
      success: json['success'] as bool? ?? false,
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }
}

class VerifyOtpDataModel {
  final String accessToken;
  final String refreshToken;

  const VerifyOtpDataModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory VerifyOtpDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VerifyOtpDataModel(accessToken: '', refreshToken: '');
    }
    final access = json['accessToken']?.toString() ??
        json['access_token']?.toString() ??
        json['token']?.toString() ??
        json['jwt']?.toString() ??
        json['jwtToken']?.toString() ??
        '';
    final refresh = json['refreshToken']?.toString() ??
        json['refresh_token']?.toString() ??
        '';
    return VerifyOtpDataModel(
      accessToken: access.trim(),
      refreshToken: refresh.trim(),
    );
  }
}

class VerifyOtpResponseModel {
  final bool success;
  final String message;
  final VerifyOtpDataModel? data;

  const VerifyOtpResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VerifyOtpResponseModel(success: false, message: '');
    }

    VerifyOtpDataModel? parsedData;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      parsedData = VerifyOtpDataModel.fromJson(rawData);
    } else if (rawData is String && rawData.isNotEmpty) {
      parsedData = VerifyOtpDataModel(accessToken: rawData, refreshToken: '');
    } else if (json['token'] != null ||
        json['accessToken'] != null ||
        json['access_token'] != null) {
      parsedData = VerifyOtpDataModel.fromJson(json);
    }

    return VerifyOtpResponseModel(
      success: json['success'] as bool? ?? false,
      message: (json['message'] as String?)?.trim() ?? '',
      data: parsedData,
    );
  }
}

class SessionVerificationResult {
  final bool isValid;
  final bool isOffline;
  final Data? userData;
  final UserProfileModel? profile;

  const SessionVerificationResult({
    required this.isValid,
    this.isOffline = false,
    this.userData,
    this.profile,
  });
}

class OnboardingStatusData {
  final bool hasBasicInfo;
  final String nextAction;

  const OnboardingStatusData({
    required this.hasBasicInfo,
    required this.nextAction,
  });

  factory OnboardingStatusData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OnboardingStatusData(
        hasBasicInfo: false,
        nextAction: '',
      );
    }
    return OnboardingStatusData(
      hasBasicInfo: json['hasBasicInfo'] as bool? ?? false,
      nextAction: (json['nextAction'] as String?)?.trim() ?? '',
    );
  }
}

class OnboardingStatusResponse {
  final bool success;
  final String message;
  final OnboardingStatusData? data;

  const OnboardingStatusResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OnboardingStatusResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OnboardingStatusResponse(
        success: false,
        message: '',
      );
    }
    return OnboardingStatusResponse(
      success: json['success'] as bool? ?? false,
      message: (json['message'] as String?)?.trim() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? OnboardingStatusData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

