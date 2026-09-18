class UserProfileModel {
  bool? success;
  String? message;
  Data? data;
  String? timestamp;

  UserProfileModel({this.success, this.message, this.data, this.timestamp});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    dataMap['timestamp'] = timestamp;
    return dataMap;
  }
}

class Data {
  String? id;
  String? userId;
  String? name;
  String? fullName;
  String? email;
  String? phone;
  String? role;
  String? avatar;
  String? avatarUrl;
  int? memberSinceYear;
  String? createdAt;
  String? updatedAt;
  bool? blocked;
  bool? verified;

  Data({
    this.id,
    this.userId,
    this.name,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.avatar,
    this.avatarUrl,
    this.memberSinceYear,
    this.createdAt,
    this.updatedAt,
    this.blocked,
    this.verified,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['_id']?.toString();
    userId = json['userId']?.toString();
    fullName = json['fullName']?.toString() ?? json['name']?.toString();
    name = fullName;
    email = json['email']?.toString();
    phone = json['phone']?.toString() ?? json['phoneNumber']?.toString();
    role = json['role']?.toString();
    avatarUrl = json['avatarUrl']?.toString() ??
        json['avatar']?.toString() ??
        json['image']?.toString();
    avatar = avatarUrl;
    memberSinceYear = json['memberSinceYear'] is int
        ? json['memberSinceYear'] as int
        : int.tryParse(json['memberSinceYear']?.toString() ?? '');
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    blocked = json['blocked'] as bool? ?? false;
    verified = json['verified'] as bool? ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    dataMap['userId'] = userId;
    dataMap['name'] = name;
    dataMap['fullName'] = fullName;
    dataMap['email'] = email;
    dataMap['phone'] = phone;
    dataMap['role'] = role;
    dataMap['avatar'] = avatar;
    dataMap['avatarUrl'] = avatarUrl;
    dataMap['memberSinceYear'] = memberSinceYear;
    dataMap['createdAt'] = createdAt;
    dataMap['updatedAt'] = updatedAt;
    dataMap['blocked'] = blocked;
    dataMap['verified'] = verified;
    return dataMap;
  }
}
