class BusinessContact {
  final int id;
  final int userId;
  final String type; // Phone, Telegram, Viber, Messenger
  final String value;
  final int groupId;
  final bool isPrimary;

  BusinessContact({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.groupId,
    required this.isPrimary,
  });

  factory BusinessContact.fromJson(Map<String, dynamic> json) {
    return BusinessContact(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      type: json['type']?.toString().trim() ?? '',
      value: json['value']?.toString().trim() ?? '',
      groupId: int.tryParse(json['groupId']?.toString() ?? '') ?? 0,
      isPrimary: json['isPrimary'] == true,
    );
  }

  String get typeKey => type.toLowerCase();
}