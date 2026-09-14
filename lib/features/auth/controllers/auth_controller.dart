//
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/network/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/local_storage/shared_prefs_helper.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../profile/controllers/address_controller.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;
  final RxInt resendCooldown = 0.obs;
  Timer? _resendTimer;
  String? _verificationId;
  int? _resendToken;

  @override
  void onClose() {
    _cancelTimer();
    super.onClose();
  }

  void _cancelTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  void resetLoading() {
    isLoading.value = false;
  }

  void startResendCooldown({int seconds = 30}) {
    _cancelTimer();
    resendCooldown.value = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 1) {
        resendCooldown.value--;
      } else {
        resendCooldown.value = 0;
        timer.cancel();
      }
    });
  }

  /// Extracts clean 10-digit mobile number and returns formatted `+91XXXXXXXXXX`
  String? sanitizePhone(String rawPhone) {
    var digits = rawPhone.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.length != 10) return null;
    return '${AppStrings.phonePrefix}$digits';
  }

  // Future<bool> requestOtp(String rawPhone, {bool showSnackbar = true}) async {
  //   if (isLoading.value) return false;

  //   final formattedPhone = sanitizePhone(rawPhone);
  //   if (formattedPhone == null) {
  //     if (showSnackbar) {
  //       _showSnackbar(AppStrings.invalidPhoneError, isError: true);
  //     }
  //     return false;
  //   }

  //   isLoading.value = true;
  //   try {
  //     final response = await _authService.requestOtp(formattedPhone);
  //     if (isClosed) return false;

  //     if (response.success) {
  //       startResendCooldown();
  //       if (showSnackbar) {
  //         _showSnackbar(
  //           response.message.isNotEmpty
  //               ? response.message
  //               : AppStrings.otpSentSuccess,
  //           isError: false,
  //         );
  //       }
  //       return true;
  //     } else {
  //       if (showSnackbar) {
  //         _showSnackbar(
  //           response.message.isNotEmpty
  //               ? response.message
  //               : AppStrings.otpRequestFailed,
  //           isError: true,
  //         );
  //       }
  //       return false;
  //     }
  //   } catch (_) {
  //     if (showSnackbar) {
  //       _showSnackbar(AppStrings.otpRequestFailed, isError: true);
  //     }
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<bool> verifyOtp({
  //   required String phone,
  //   required String otp,
  //   bool showSnackbar = true,
  // }) async {
  //   if (isLoading.value) return false;

  //   final cleanOtp = otp.replaceAll(RegExp(r'\D'), '');
  //   if (cleanOtp.length != 6) {
  //     if (showSnackbar) {
  //       _showSnackbar(AppStrings.invalidOtpError, isError: true);
  //     }
  //     return false;
  //   }

  //   final formattedPhone = sanitizePhone(phone);
  //   if (formattedPhone == null) {
  //     if (showSnackbar) {
  //       _showSnackbar(AppStrings.invalidPhoneError, isError: true);
  //     }
  //     return false;
  //   }

  //   isLoading.value = true;
  //   try {
  //     final response = await _authService.verifyOtp(formattedPhone, cleanOtp);
  //     if (isClosed) return false;

  //     if (response.success) {
  //       final accessToken = response.data?.accessToken ?? '';
  //       if (accessToken.isNotEmpty) {
  //         await SharedPrefsHelper.saveAccessToken(accessToken);
  //       }
  //       final refreshToken = response.data?.refreshToken ?? '';
  //       if (refreshToken.isNotEmpty) {
  //         await SharedPrefsHelper.saveRefreshToken(refreshToken);
  //       }

  //       if (showSnackbar) {
  //         _showSnackbar(
  //           response.message.isNotEmpty
  //               ? response.message
  //               : AppStrings.otpVerifiedSuccess,
  //           isError: false,
  //         );
  //       }
  //       _cancelTimer();
  //       Get.offAllNamed(AppRoutes.dashboard);
  //       return true;
  //     } else {
  //       if (showSnackbar) {
  //         _showSnackbar(
  //           response.message.isNotEmpty
  //               ? response.message
  //               : AppStrings.otpVerificationFailed,
  //           isError: true,
  //         );
  //       }
  //       return false;
  //     }
  //   } catch (_) {
  //     if (showSnackbar) {
  //       _showSnackbar(AppStrings.otpVerificationFailed, isError: true);
  //     }
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void logout(BuildContext context) {
    AppDialogs.showConfirmationDialog(
      context,
      title: AppStrings.logout,
      message: AppStrings.logoutConfirmationMessage,
      confirmText: AppStrings.logout,
      onConfirm: () async {
        await _clearSession();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  void forceLogout() async {
    _showSnackbar(AppStrings.sessionExpired, isError: true);
    await _clearSession();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _clearSession() async {
    _cancelTimer();
    isLoading.value = false;
    await SharedPrefsHelper.clearAll();

    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearCart();
      Get.delete<CartController>(force: true);
    }
    if (Get.isRegistered<AddressController>()) {
      Get.delete<AddressController>(force: true);
    }
    if (Get.isRegistered<OrdersController>()) {
      Get.delete<OrdersController>(force: true);
    }
    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final token = await _firebaseAuth.currentUser?.getIdToken(forceRefresh);
    if (token != null) {
      debugPrint('🔥 [FirebaseAuthService.getIdToken]: $token');
    }
    return token;
  }

  Future<bool> requestOtp(
    String rawPhone, {
    bool showSnackbar = true,
    bool isResend = false,
    required void Function() onCodeSent,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    if (isLoading.value) return false;

    final formattedPhone = sanitizePhone(rawPhone);

    if (formattedPhone == null) {
      if (showSnackbar) {
        _showSnackbar(AppStrings.invalidPhoneError, isError: true);
      }
      return false;
    }

    isLoading.value = true;

    final completer = Completer<bool>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        forceResendingToken: isResend ? _resendToken : null,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          if (isClosed) return;

          onAutoVerified?.call(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          if (isClosed) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            return;
          }

          isLoading.value = false;

          if (showSnackbar) {
            _showSnackbar(
              e.message ?? AppStrings.otpRequestFailed,
              isError: true,
            );
          }

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          if (isClosed) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            return;
          }

          _verificationId = verificationId;
          _resendToken = resendToken;

          isLoading.value = false;

          startResendCooldown();

          if (showSnackbar) {
            _showSnackbar(AppStrings.otpSentSuccess, isError: false);
          }

          onCodeSent();

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return await completer.future;
    } catch (_) {
      if (!isClosed) {
        isLoading.value = false;

        if (showSnackbar) {
          _showSnackbar(AppStrings.otpRequestFailed, isError: true);
        }
      }

      if (!completer.isCompleted) {
        completer.complete(false);
      }

      return false;
    }
  }

  Future<bool> verifyOtp(String otp, {bool showSnackbar = true}) async {
    if (isLoading.value) return false;

    if (_verificationId == null || _verificationId!.isEmpty) {
      if (showSnackbar) {
        _showSnackbar(
          'Verification session expired. Please request OTP again.',
          isError: true,
        );
      }
      return false;
    }

    if (otp.trim().length != 6) {
      if (showSnackbar) {
        _showSnackbar('Please enter a valid 6-digit OTP.', isError: true);
      }
      return false;
    }

    isLoading.value = true;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp.trim(),
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      isLoading.value = false;

      if (userCredential.user != null) {
        if (userCredential.user != null) {
          final idToken = await userCredential.user!.getIdToken();
          if (idToken != null && idToken.isNotEmpty) {
            final res = await _apiClient.post(
              "/auth/otp/verify/firebase",

              data: {'idToken': idToken, "role": "VENDOR"},
            );
            if (res.statusCode == 200 || res.statusCode == 201) {
              SharedPrefsHelper.saveAccessToken(
                res.data['data']['accessToken'] ?? "",
              );
              SharedPrefsHelper.saveRefreshToken(
                res.data['data']['refreshToken'] ?? "",
              );
              _cancelTimer();
              Get.offAllNamed(AppRoutes.dashboard);
              return true;
            } else {
              return false;
            }
            // Authenticate with backend
          }
        }
      }

      return false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      if (showSnackbar) {
        String message;

        switch (e.code) {
          case 'invalid-verification-code':
            message = 'Invalid OTP. Please check and try again.';
            break;

          case 'session-expired':
            message = 'OTP has expired. Please request a new OTP.';
            break;

          case 'invalid-verification-id':
            message =
                'Verification session is invalid. Please request OTP again.';
            break;

          case 'credential-already-in-use':
            message = 'This phone number is already linked to another account.';
            break;

          default:
            message = e.message ?? 'OTP verification failed.';
        }

        _showSnackbar(message, isError: true);
      }

      return false;
    } catch (e) {
      isLoading.value = false;

      if (showSnackbar) {
        _showSnackbar(
          'Something went wrong while verifying OTP.',
          isError: true,
        );
      }

      return false;
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    if (Get.context == null) return;
    Get.snackbar(
      AppStrings.appName,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      colorText: AppColors.surface,
      duration: const Duration(seconds: 2),
    );
  }
}
