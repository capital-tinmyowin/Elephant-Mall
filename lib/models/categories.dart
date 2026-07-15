class Category {
  final String name;
  final String? icon;

  Category({
    required this.name,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      icon: json['icon'],
    );
  }
}