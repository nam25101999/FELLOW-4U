class Tour {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final double price;
  final String? location;
  final String? duration;
  final String? startDate;
  final double? rating;

  Tour({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.price,
    this.location,
    this.duration,
    this.startDate,
    this.rating,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      location: json['location'],
      duration: json['duration'],
      startDate: json['startDate'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }
}

class Experience {
  final String id;
  final String title;
  final String imageUrl;
  final String authorName;
  final String authorImageUrl;

  Experience({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.authorName,
    required this.authorImageUrl,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      authorName: json['authorName'],
      authorImageUrl: json['authorImageUrl'],
    );
  }
}

class TravelNews {
  final String id;
  final String title;
  final String imageUrl;
  final String publishedDate;

  TravelNews({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.publishedDate,
  });

  factory TravelNews.fromJson(Map<String, dynamic> json) {
    return TravelNews(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      publishedDate: json['publishedDate'],
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? location;
  final String? bio;
  final double? rating;
  final int? reviewCount;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.location,
    this.bio,
    this.rating,
    this.reviewCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'],
      location: json['location'],
      bio: json['bio'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'],
    );
  }
}

class ExploreResponse {
  final List<Tour> topJourneys;
  final List<User> bestGuides;
  final List<Experience> topExperiences;
  final List<Tour> featuredTours;
  final List<TravelNews> travelNews;

  ExploreResponse({
    required this.topJourneys,
    required this.bestGuides,
    required this.topExperiences,
    required this.featuredTours,
    required this.travelNews,
  });

  factory ExploreResponse.fromJson(Map<String, dynamic> json) {
    return ExploreResponse(
      topJourneys: (json['topJourneys'] as List).map((i) => Tour.fromJson(i)).toList(),
      bestGuides: (json['bestGuides'] as List).map((i) => User.fromJson(i)).toList(),
      topExperiences: (json['topExperiences'] as List).map((i) => Experience.fromJson(i)).toList(),
      featuredTours: (json['featuredTours'] as List).map((i) => Tour.fromJson(i)).toList(),
      travelNews: (json['travelNews'] as List).map((i) => TravelNews.fromJson(i)).toList(),
    );
  }
}
