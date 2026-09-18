import 'dart:io';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import '../models/user_profile_models.dart';
import '../services/user_profile_service.dart';

class UserProfileController extends GetxController {
  final UserProfileService _userProfileService = UserProfileService();

  final Rxn<UserProfileModel> userProfileModel = Rxn<UserProfileModel>();
  final Rxn<Data> userData = Rxn<Data>();
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<File> selectedAvatarFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    if (userData.value == null) {
      fetchUserProfile();
    }
  }

  Future<void> fetchUserProfile({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _userProfileService.getUserProfile();
      userProfileModel.value = response;

      if (response.success == true && response.data != null) {
        userData.value = response.data;
      } else {
        errorMessage.value = response.message ?? AppStrings.networkError;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? fullName,
    String? email,
    String? phone,
    File? avatarFile,
  }) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final fileToUpload = avatarFile ?? selectedAvatarFile.value;
      final effectiveName = fullName ?? name;
      final response = await _userProfileService.updateUserProfile(
        name: effectiveName,
        fullName: effectiveName,
        email: email,
        phone: phone,
        avatarFile: fileToUpload,
      );

      if (response.success == true) {
        if (response.data != null) {
          userData.value = response.data;
        } else {
          final current = userData.value;
          userData.value = Data(
            id: current?.id,
            userId: current?.userId,
            name: effectiveName ?? current?.name,
            fullName: effectiveName ?? current?.fullName ?? current?.name,
            email: email ?? current?.email,
            phone: phone ?? current?.phone,
            role: current?.role,
            avatar: current?.avatar,
            avatarUrl: current?.avatarUrl,
            memberSinceYear: current?.memberSinceYear,
            createdAt: current?.createdAt,
            updatedAt: current?.updatedAt,
            blocked: current?.blocked,
            verified: current?.verified,
          );
        }
        selectedAvatarFile.value = null;
        return true;
      } else {
        errorMessage.value =
            response.message ?? AppStrings.failedToUpdateProfile;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  void setSelectedAvatar(File file) {
    selectedAvatarFile.value = file;
  }

  void clearSelectedAvatar() {
    selectedAvatarFile.value = null;
  }

  String get id => userData.value?.id ?? '';

  String get userId => userData.value?.userId ?? '';

  String get name => userData.value?.fullName ?? userData.value?.name ?? '';

  String get fullName => name;

  String get email => userData.value?.email ?? '';

  String get phone => userData.value?.phone ?? '';

  bool get isVerified => userData.value?.verified ?? false;

  bool get isBlocked => userData.value?.blocked ?? false;

  String get role => userData.value?.role ?? AppStrings.customerRole;

  String get createdAt => userData.value?.createdAt ?? '';

  String get updatedAt => userData.value?.updatedAt ?? '';

  int? get memberSinceYear => userData.value?.memberSinceYear;

  String get avatar => userData.value?.avatarUrl ?? userData.value?.avatar ?? '';

  String get avatarUrl => avatar;

  String get displayName {
    if (name.isNotEmpty) return name;
    if (email.isNotEmpty) return email.split('@').first;
    if (phone.isNotEmpty) return phone;
    return AppStrings.customerRole;
  }
}
