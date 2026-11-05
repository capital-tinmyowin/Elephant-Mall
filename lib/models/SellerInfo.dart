class SellerInfo {
  final String userName;
  final String name;
  final String? location;
  final int productCount;
  final int followerCount;
  final String? avatarUrl;
  final String? coverUrl;
  final bool isFollowing;

  SellerInfo({
    required this.userName,
    required this.name,
    this.location,
    required this.productCount,
    required this.followerCount,
    this.avatarUrl,
    this.coverUrl,
    required this.isFollowing,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      userName: json['userName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString(),
      productCount:
          int.tryParse(json['productCount']?.toString() ?? '') ?? 0,
      followerCount:
          int.tryParse(json['follwerCount']?.toString() ?? '') ?? 0,
      avatarUrl: json['avatarUrl']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      isFollowing: json['isFollowing'] == true,
    );
  }
}