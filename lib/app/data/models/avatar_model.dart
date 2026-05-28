class AvatarModel {
  final int id;
  final String name;
  final String imageUrl;
  final int priceStars;
  final bool isDefault;

  AvatarModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.priceStars,
    this.isDefault = false,
  });
}