class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? role;
  // final String? avatarUrl;
  // final DateTime createdDate;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.role,
    // this.avatarUrl,
    // required this.createdDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRole = json['name'] ?? json['role'];
    String? parsedRole;
    if (rawRole is List) {
      parsedRole = rawRole.join(', ');
    } else if (rawRole != null) {
      parsedRole = rawRole.toString();
    }
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      role: parsedRole,
      // avatarUrl: json['avatarUrl'],
      // createdDate: json['createdDate'] != null
      //     ? DateTime.parse(json['createdDate'])
      //     : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      // 'avatarUrl': avatarUrl,
      // 'createdDate': createdDate.toIso8601String(),
    };
  }
}