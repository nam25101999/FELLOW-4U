class UserNotification {
  final String id;
  final String title;
  final String message;
  final String? avatarUrl;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionType;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    this.avatarUrl,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.actionType,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      avatarUrl: json['avatarUrl'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      actionType: json['actionType'],
    );
  }
}
