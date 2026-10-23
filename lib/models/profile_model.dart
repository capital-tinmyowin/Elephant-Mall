class ProfileModel {
  final int? userId;
  final String userName;
  final String name;
  final String avatarUrl;
  final String coverUrl;
  final String email;
  final String phone;
  final List<String> roles;
  final String dateOfBirth;
  final String gender;
  final String createdDate;
  final String location;
  final String bio;
  final String shopName;
  final String businessType;
  final String businessLocation;
  final String businessDescription;
  final dynamic userContacts;
  final dynamic businessContacts;

  const ProfileModel({
    this.userId,
    this.userName = '',
    this.name = '',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.email = '',
    this.phone = '',
    this.roles = const [],
    this.dateOfBirth = '',
    this.gender = '',
    this.createdDate = '',
    this.location = '',
    this.bio = '',
    this.shopName = '',
    this.businessType = '',
    this.businessLocation = '',
    this.businessDescription = '',
    this.userContacts,
    this.businessContacts,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['role'];
    final roles = rawRoles is List
        ? rawRoles.map((value) => value.toString()).toList()
        : rawRoles == null || rawRoles.toString().isEmpty
            ? <String>[]
            : <String>[rawRoles.toString()];

    return ProfileModel(
      userId: _asInt(json['userId']),
      userName: _asString(json['userName']),
      name: _asString(json['name']),
      avatarUrl: _asString(json['avatarUrl']),
      coverUrl: _asString(json['coverUrl']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      roles: roles,
      dateOfBirth: _asString(json['dateOfBirth']),
      gender: _asString(json['gender']),
      createdDate: _asString(json['createdDate']),
      location: _asString(json['location']),
      bio: _asString(json['bio']),
      shopName: _asString(json['shopName']),
      businessType: _asString(json['businessType']),
      businessLocation: _asString(json['businessLocation']),
      businessDescription: _asString(json['businessDescription']),
      userContacts: json['userContacts'],
      businessContacts: json['businessContacts'],
    );
  }

  static String _asString(dynamic value) => value == null ? '' : value.toString();

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
