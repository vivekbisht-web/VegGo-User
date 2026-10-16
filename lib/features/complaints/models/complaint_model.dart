class ComplaintModel {
  final String id;
  final String ticketNumber;
  final String createdAt;
  final String updatedAt;
  final String userId;
  final String userRole;
  final String userName;
  final String userPhone;
  final String category;
  final String title;
  final String description;
  final List<String> attachments;
  final String status;
  final bool canReopen;
  final String? adminNote;

  ComplaintModel({
    required this.id,
    required this.ticketNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.userRole,
    required this.userName,
    required this.userPhone,
    required this.category,
    required this.title,
    required this.description,
    required this.attachments,
    required this.status,
    required this.canReopen,
    this.adminNote,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
        id: json['id'] as String? ?? '',
        ticketNumber: json['ticketNumber'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        userRole: json['userRole'] as String? ?? '',
        userName: json['userName'] as String? ?? '',
        userPhone: json['userPhone'] as String? ?? '',
        category: json['category'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        status: json['status'] as String? ?? '',
        canReopen: json['canReopen'] as bool? ?? false,
        adminNote: json['adminNote'] as String?,
      );
}
