class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final double? imageTop;
  final double? imageLeft;
  final double? imageRight;
  final double? imageBottom;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    this.imageTop,
    this.imageLeft,
    this.imageRight,
    this.imageBottom,
  });
}
