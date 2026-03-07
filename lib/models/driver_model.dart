import 'package:taxi/utils/district_coordinates.dart';

class Driver {
  final String id;
  final String plate;
  final double lat;
  final double lng;
  final String status; 
  final String taxiStand;
  final String district;
  final String phone;
  final bool isPremium;
  final bool isVip;
  final String password;
  final int likes;
  final DateTime? createdAt;

  Driver({
    required this.id,
    required this.plate,
    required this.lat,
    required this.lng,
    required this.status,
    required this.taxiStand,
    required this.district,
    required this.phone,
    required this.isPremium,
    this.isVip = false,
    required this.password,
    required this.likes,
    this.createdAt,
  });

  
  factory Driver.fromJson(Map<String, dynamic> json, String docId) {
    final district = json['district'] ?? '';
    final rawLat = (json['lat'] as num?)?.toDouble();
    final rawLng = (json['lng'] as num?)?.toDouble();
    final plate = json['plate'] ?? '';
    final isLiveLocation = json['isLiveLocation'] == true;

    double lat;
    double lng;

    // Canlı konum takibi açık ve gerçek GPS koordinatı varsa,
    // doğrudan Firebase'deki koordinatı kullan (sürücü hareket halinde).
    if (isLiveLocation && rawLat != null && rawLng != null) {
      lat = rawLat;
      lng = rawLng;
    } else {
      // İlçe merkezini kullan + plakaya göre küçük offset
      final districtCoords = DistrictCoordinates.getCoordinates(district);
      if (districtCoords != null) {
        final hash = plate.hashCode;
        final offsetLat = ((hash % 100) - 50) * 0.0001;
        final offsetLng = (((hash ~/ 100) % 100) - 50) * 0.0001;
        lat = districtCoords.lat + offsetLat;
        lng = districtCoords.lng + offsetLng;
      } else if (rawLat != null && rawLng != null) {
        lat = rawLat;
        lng = rawLng;
      } else {
        lat = 37.8444;
        lng = 27.8458;
      }
    }

    return Driver(
      id: docId,
      plate: plate,
      lat: lat,
      lng: lng,
      status: json['status'] ?? 'available',
      taxiStand: json['taxiStand'] ?? '',
      district: district,
      phone: json['phone'] ?? '',
      isPremium: json['isPremium'] ?? false,
      isVip: json['isVip'] ?? false,
      password: json['password'] ?? '',
      likes: json['likes'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'plate': plate,
      'lat': lat,
      'lng': lng,
      'status': status,
      'taxiStand': taxiStand,
      'district': district,
      'phone': phone,
      'isPremium': isPremium,
      'isVip': isVip,
      'password': password,
      'likes': likes,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  
  Driver copyWith({
    String? id,
    String? plate,
    double? lat,
    double? lng,
    String? status,
    String? taxiStand,
    String? district,
    String? phone,
    bool? isPremium,
    bool? isVip,
    String? password,
    int? likes,
    DateTime? createdAt,
  }) {
    return Driver(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      status: status ?? this.status,
      taxiStand: taxiStand ?? this.taxiStand,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
      isVip: isVip ?? this.isVip,
      password: password ?? this.password,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
