class UserPhoto {
  final String id;
  final String imageUrl;
  final DateTime createdAt;

  UserPhoto({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      id: json['id'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserJourney {
  final String id;
  final String title;
  final String location;
  final String date;
  final int likeCount;
  final List<String> imageUrls;

  UserJourney({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.likeCount,
    required this.imageUrls,
  });

  factory UserJourney.fromJson(Map<String, dynamic> json) {
    return UserJourney(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      date: json['date'],
      likeCount: json['likeCount'],
      imageUrls: List<String>.from(json['imageUrls']),
    );
  }
}
