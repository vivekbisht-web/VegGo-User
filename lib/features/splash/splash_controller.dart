import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/core/services/push_notification_service.dart';
import 'package:vegon_user/features/auth/models/auth_models.dart';
import 'package:vegon_user/features/auth/services/auth_service.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';
import 'package:vegon_user/features/profile/models/user_profile_models.dart';
import 'package:vegon_user/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final DateTime splashStartTime = DateTime.now();

    try {
      final String? accessToken = SharedPrefsHelper.getAccessToken();
      final String? refreshToken = SharedPrefsHelper.getRefreshToken();

      // 1. Both tokens missing -> Clear & Logout
      if ((accessToken == null || accessToken.trim().isEmpty) &&
          (refreshToken == null || refreshToken.trim().isEmpty)) {
        await _logoutAndNavigate(splashStartTime);
        return;
      }

      // 2. Check token expirations & restore session if needed
      final String? activeToken = await _restoreOrRefreshSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      if (activeToken == null) {
        await _logoutAndNavigate(splashStartTime);
        return;
      }

      // 3. Verify user session with backend
      final verification = await _verifySession(
        activeToken: activeToken,
        refreshToken: refreshToken,
      );

      if (verification.isValid) {
        _updateUserProfile(verification.userData, verification.profile);
        PushNotificationService.instance.registerDeviceToken();
        await _waitForSplashAnimation(splashStartTime);
        _navigateNext(isLoggedIn: true);
        return;
      }

      // 4. Handle offline with valid local token
      final bool isAccessExpired = SharedPrefsHelper.isTokenExpired(activeToken);
      if (verification.isOffline && !isAccessExpired) {
        debugPrint('SplashController: Device offline with valid local token. Proceeding.');
        PushNotificationService.instance.registerDeviceToken();
        await _waitForSplashAnimation(splashStartTime);
        _navigateNext(isLoggedIn: true);
        return;
      }

      // 5. Unauthenticated / Invalid user
      await _logoutAndNavigate(splashStartTime);
    } catch (e) {
      debugPrint('SplashController: Authentication error: $e');
      await _logoutAndNavigate(splashStartTime);
    }
  }

  Future<String?> _restoreOrRefreshSession({
    required String? accessToken,
    required String? refreshToken,
  }) async {
    final bool isAccessExpired = SharedPrefsHelper.isTokenExpired(accessToken);
    final bool isRefreshExpired = SharedPrefsHelper.isTokenExpired(refreshToken);

    // Both expired
    if (isAccessExpired && (refreshToken == null || isRefreshExpired)) {
      return null;
    }

    // Access token expired, but refresh token is valid
    if (isAccessExpired && refreshToken != null && !isRefreshExpired) {
      return await _authService.refreshToken(refreshToken);
    }

    // Access token is valid
    return accessToken?.trim();
  }

  Future<SessionVerificationResult> _verifySession({
    required String activeToken,
    required String? refreshToken,
  }) async {
    final result = await _authService.verifySession(token: activeToken);
    if (result.isValid || result.isOffline) {
      return result;
    }

    // If server rejected token (e.g. 401 or 500), try refreshing once if refreshToken is alive
    final bool isRefreshExpired = SharedPrefsHelper.isTokenExpired(refreshToken);
    if (refreshToken != null && !isRefreshExpired) {
      final newAccess = await _authService.refreshToken(refreshToken);
      if (newAccess != null) {
        return await _authService.verifySession(token: newAccess);
      }
    }

    return result;
  }

  void _updateUserProfile(Data? userData, UserProfileModel? model) {
    if (userData == null) return;
    final profileController = Get.isRegistered<UserProfileController>()
        ? Get.find<UserProfileController>()
        : Get.put(UserProfileController());
    profileController.userData.value = userData;
    if (model != null) {
      profileController.userProfileModel.value = model;
    }
  }

  Future<void> _logoutAndNavigate(DateTime splashStartTime) async {
    await SharedPrefsHelper.clearToken();
    await _waitForSplashAnimation(splashStartTime);
    _navigateNext(isLoggedIn: false);
  }

  Future<void> _waitForSplashAnimation(DateTime startTime) async {
    const minDuration = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }
  }

  void _navigateNext({required bool isLoggedIn}) {
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else if (SharedPrefsHelper.isOnboardingComplete()) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
