class AvatarModel {
  final int id;
  final String name;
  final String imagePath;
  final int priceStars;
  final bool isDefault;

  AvatarModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.priceStars,
    this.isDefault = false,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'],
      name: json['name'],
      imagePath: json['image_path'] ?? '',
      priceStars: json['price_stars'] ?? 0,
      isDefault: json['is_default'] ?? false,
    );
  }
}