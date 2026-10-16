//
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/snackbar_helper.dart';
import '../models/complaint_model.dart';
import '../services/complaint_repository.dart';

class ComplaintController extends GetxController {
  final ComplaintRepository _repo = ComplaintRepository();
  final _picker = ImagePicker();

  final RxList<ComplaintModel> complaints = <ComplaintModel>[].obs;
  final Rx<ComplaintModel?> selected = Rx<ComplaintModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isReopening = false.obs;
  final RxBool hasError = false.obs;
  final RxString activeFilter = ''.obs; // '' = All

  final RxList<XFile> pickedImages = <XFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadComplaints();
  }

  Future<void> loadComplaints({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    hasError.value = false;

    final res = await _repo.fetchMyComplaints(
      status: activeFilter.value.isEmpty ? null : activeFilter.value,
    );

    isLoading.value = false;

    if (res != null && res.success) {
      complaints.assignAll(res.data?.content ?? []);
    } else {
      hasError.value = true;
    }
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
    loadComplaints();
  }

  Future<void> loadDetails(String id) async {
    if (selected.value == null) {
      isLoadingDetails.value = true;
    }
    try {
      final res = await _repo.fetchComplaintDetails(id);
      if (res != null && res.success && res.data != null) {
        selected.value = res.data;
      }
    } catch (_) {
      // Keep existing data if present
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (img != null && pickedImages.length < 3) {
      pickedImages.add(img);
    }
  }

  void removeImage(int index) => pickedImages.removeAt(index);

  Future<bool> submitComplaint({
    required String category,
    required String title,
    required String description,
  }) async {
    isSubmitting.value = true;

    final paths = pickedImages.map((f) => f.path).toList();
    final (ok, msg) = await _repo.fileComplaint(
      category: category,
      title: title,
      description: description,
      attachmentPaths: paths,
    );

    isSubmitting.value = false;

    if (ok) {
      pickedImages.clear();
      await loadComplaints(silent: true);
    } else {
      SnackbarHelper.showGetError(
        msg.isNotEmpty ? msg : AppStrings.complaintSubmitFailed,
      );
    }

    return ok;
  }

  Future<bool> reopenComplaint(String id, String reason) async {
    isReopening.value = true;

    final (ok, msg) = await _repo.reopenComplaint(id, reason);

    isReopening.value = false;

    if (ok) {
      SnackbarHelper.showGetSuccess(AppStrings.complaintReopenSuccess);
      await loadDetails(id);
      await loadComplaints(silent: true);
    } else {
      final display = (msg.contains('RESOLVED') || msg.contains('reopen'))
          ? AppStrings.complaintReopenCannotMsg
          : msg.isNotEmpty
          ? msg
          : AppStrings.complaintReopenFailed;

      SnackbarHelper.showGetError(display);
    }

    return ok;
  }
}
