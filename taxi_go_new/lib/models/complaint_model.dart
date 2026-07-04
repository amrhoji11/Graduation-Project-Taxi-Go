class ComplaintModel {
  final int id;
  final int orderId;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;

  const ComplaintModel({
    required this.id,
    required this.orderId,
    required this.title,
    required this.description,
    required this.status,
    this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? json['complaintId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'title': title,
      'description': description,
    };
  }
}