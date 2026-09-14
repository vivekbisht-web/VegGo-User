//
class BannerDataModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;

  BannerDataModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  factory BannerDataModel.fromJson(Map<String, dynamic> json) {
    return BannerDataModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}

class GetBannersResponseModel {
  final bool success;
  final String message;
  final List<BannerDataModel> banners;

  GetBannersResponseModel({
    required this.success,
    required this.message,
    required this.banners,
  });

  factory GetBannersResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? [];
    return GetBannersResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      banners: rawData is List
          ? rawData
                .whereType<Map<String, dynamic>>()
                .map((e) => BannerDataModel.fromJson(e))
                .toList()
          : [],
    );
  }
}
