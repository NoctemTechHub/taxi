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
    required this.password,
    required this.likes,
    this.createdAt,
  });

  
  factory Driver.fromJson(Map<String, dynamic> json, String docId) {
    return Driver(
      id: docId,
      plate: json['plate'] ?? '',
      lat: (json['lat'] ?? 37.8444).toDouble(),
      lng: (json['lng'] ?? 27.8458).toDouble(),
      status: json['status'] ?? 'available',
      taxiStand: json['taxiStand'] ?? '',
      district: json['district'] ?? '',
      phone: json['phone'] ?? '',
      isPremium: json['isPremium'] ?? false,
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
      password: password ?? this.password,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
