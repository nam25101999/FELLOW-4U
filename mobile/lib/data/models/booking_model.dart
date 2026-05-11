import 'explore_model.dart';

class Booking {
  final String id;
  final String tripTitle;
  final String location;
  final String date;
  final String timeSlot;
  final String guideName;
  final String guideAvatarUrl;
  final int travelers;
  final double totalFee;
  final String status;
  final String paymentStatus;
  final List<Attraction> attractions;

  Booking({
    required this.id,
    required this.tripTitle,
    required this.location,
    required this.date,
    required this.timeSlot,
    required this.guideName,
    required this.guideAvatarUrl,
    required this.travelers,
    required this.totalFee,
    required this.status,
    required this.paymentStatus,
    required this.attractions,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      tripTitle: json['tripTitle'],
      location: json['location'],
      date: json['date'],
      timeSlot: json['timeSlot'],
      guideName: json['guideName'],
      guideAvatarUrl: json['guideAvatarUrl'],
      travelers: json['travelers'],
      totalFee: (json['totalFee'] as num).toDouble(),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      attractions: (json['attractions'] as List).map((i) => Attraction.fromJson(i)).toList(),
    );
  }
}

class Attraction {
  final String id;
  final String name;
  final String imageUrl;
  final String city;

  Attraction({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.city,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      city: json['city'],
    );
  }
}
