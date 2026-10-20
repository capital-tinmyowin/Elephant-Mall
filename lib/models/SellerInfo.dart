class SellerInfo {
  final String userName;
  final String name;
  final String? location;
  final int productCount;
  final int followerCount;
  final String? avatarUrl;
  final bool isFollowing;

  SellerInfo({
    required this.userName,
    required this.name,
    this.location,
    this.productCount = 0,
    this.followerCount = 0,
    this.avatarUrl,
    this.isFollowing = false,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      userName: json['userName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString(),
      productCount: int.tryParse(json['productCount']?.toString() ?? '') ?? 0,
      followerCount: int.tryParse(
            json['follwerCount']?.toString() ??
                json['followerCount']?.toString() ??
                '',
          ) ??
          0,
      avatarUrl: json['avatarUrl']?.toString(),
      isFollowing: json['isFollowing'] == true,
    );
  }
}