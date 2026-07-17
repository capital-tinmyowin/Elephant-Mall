class Promo {
  final int promoId;
  final String title;
  final String imagePath;
  final String? link;
  final int sortOrder;
  final bool isActive;

  Promo({
    required this.promoId,
    required this.title,
    required this.imagePath,
    this.link,
    required this.sortOrder,
    required this.isActive,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      promoId: json["promoId"],
      title: json["title"] ?? "",
      imagePath: json["imagePath"] ?? "",
      link: json["link"],
      sortOrder: json["sortOrder"] ?? 0,
      isActive: json["isActive"] ?? true,
    );
  }

  @override
  String toString() {
    return 'Promo(id:$promoId, image:$imagePath)';
  }
}
