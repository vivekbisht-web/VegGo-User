import 'dart:convert';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';

abstract final class ChatAccessState {
  static bool get isCustomer {
    if (Get.isRegistered<UserProfileController>()) {
      final role = Get.find<UserProfileController>().userData.value?.role;
      if (role != null && role.isNotEmpty) return _isCustomerRole(role);
    }

    String? token;
    try {
      token = SharedPrefsHelper.getAccessToken();
    } catch (_) {
      return true;
    }
    if (token == null) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map) return true;
      for (final key in ['role', 'roles', 'authorities']) {
        final claim = payload[key];
        if (claim != null) return _isCustomerRole(claim);
      }
    } catch (_) {}
    return true;
  }

  static bool get canUseChat => isCustomer;

  static bool _isCustomerRole(Object role) {
    final values = role is Iterable ? role : [role];
    return values.any((value) {
      final normalized = value.toString().toUpperCase().replaceFirst(
        'ROLE_',
        '',
      );
      return normalized == AppStrings.customerRole;
    });
  }
}
