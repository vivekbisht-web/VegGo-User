//
class AddAddressRequestModel {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String label;

  AddAddressRequestModel({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.label = 'Home',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'addressLine1': addressLine1.trim(),
      'addressLine2': addressLine2.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'postalCode': postalCode.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'label': label.isNotEmpty ? label.trim() : 'Home',
    };
    return data;
  }
}

class AddAddressResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  AddAddressResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AddAddressResponseModel.fromJson(Map<String, dynamic> json) {
    final bool hasError = json.containsKey('error') ||
        (json['status'] is int && (json['status'] as int) >= 400);
    final bool isSuccess =
        (json['success'] as bool?) ?? (!hasError && (json['data'] != null || json['id'] != null));
    return AddAddressResponseModel(
      success: isSuccess,
      message: json['message']?.toString() ?? json['error']?.toString() ?? '',
      data: json['data'],
    );
  }
}

class AddressDataModel {
  final String id;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String label;

  AddressDataModel({
    required this.id,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.label = 'Home',
  });

  factory AddressDataModel.fromJson(Map<String, dynamic> json) {
    return AddressDataModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['addressId']?.toString() ??
          json['address_id']?.toString() ??
          '',
      addressLine1:
          json['addressLine1']?.toString() ??
          json['address_line1']?.toString() ??
          json['address']?.toString() ??
          '',
      addressLine2:
          json['addressLine2']?.toString() ??
          json['address_line2']?.toString() ??
          '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode:
          json['postalCode']?.toString() ??
          json['postal_code']?.toString() ??
          json['zip']?.toString() ??
          '',
      latitude: (json['latitude'] != null)
          ? (json['latitude'] is num
              ? (json['latitude'] as num).toDouble()
              : (double.tryParse(json['latitude'].toString()) ?? 0.0))
          : (json['lat'] is num
              ? (json['lat'] as num).toDouble()
              : (double.tryParse(json['lat']?.toString() ?? '') ?? 0.0)),
      longitude: (json['longitude'] != null)
          ? (json['longitude'] is num
              ? (json['longitude'] as num).toDouble()
              : (double.tryParse(json['longitude'].toString()) ?? 0.0))
          : (json['lng'] is num
              ? (json['lng'] as num).toDouble()
              : (double.tryParse(json['lng']?.toString() ?? '') ?? 0.0)),
      isDefault:
          json['default'] as bool? ??
          json['isDefault'] as bool? ??
          json['is_default'] as bool? ??
          false,
      label: json['label']?.toString() ?? json['title']?.toString() ?? 'Home',
    );
  }
}

class GetAddressesResponseModel {
  final bool success;
  final List<AddressDataModel> addresses;

  GetAddressesResponseModel({required this.success, required this.addresses});

  factory GetAddressesResponseModel.fromJson(dynamic json) {
    if (json == null) {
      return GetAddressesResponseModel(success: false, addresses: []);
    }
    dynamic rawList;
    bool success = true;

    if (json is List) {
      rawList = json;
      success = true;
    } else if (json is Map<String, dynamic>) {
      final bool hasError = json.containsKey('error') ||
          (json['status'] is int && (json['status'] as int) >= 400);
      success = (json['success'] as bool?) ?? (!hasError);
      rawList = json['data'] ?? json['addresses'] ?? json['content'] ?? [];
    }

    List<AddressDataModel> parsed = [];
    if (rawList is List) {
      parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => AddressDataModel.fromJson(e))
          .toList();
    }

    return GetAddressesResponseModel(
      success: success,
      addresses: parsed,
    );
  }
}

class AddressModel {
  String? _id;
  String get id => _id ?? '';
  set id(String? value) => _id = value ?? '';

  String title;
  String address;
  dynamic icon;
  bool isDefault;
  AddressDataModel? rawAddressData;

  AddressModel({
    String? id,
    required this.title,
    required this.address,
    required this.icon,
    this.isDefault = false,
    this.rawAddressData,
  }) : _id = id ?? '';
}
