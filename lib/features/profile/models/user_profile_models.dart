//
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
  String? name;
  String? email;
  String? phone;
  String? role;
  String? avatar;
  String? createdAt;
  bool? blocked;
  bool? verified;

  Data({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.avatar,
    this.createdAt,
    this.blocked,
    this.verified,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['_id']?.toString();
    name = json['name']?.toString() ?? json['fullName']?.toString();
    email = json['email']?.toString();
    phone = json['phone']?.toString() ?? json['phoneNumber']?.toString();
    role = json['role']?.toString();
    avatar = json['avatar']?.toString() ?? json['image']?.toString();
    createdAt = json['createdAt']?.toString();
    blocked = json['blocked'] as bool? ?? false;
    verified = json['verified'] as bool? ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    dataMap['name'] = name;
    dataMap['email'] = email;
    dataMap['phone'] = phone;
    dataMap['role'] = role;
    dataMap['avatar'] = avatar;
    dataMap['createdAt'] = createdAt;
    dataMap['blocked'] = blocked;
    dataMap['verified'] = verified;
    return dataMap;
  }
}
