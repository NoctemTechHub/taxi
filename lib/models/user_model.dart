class AppUser {
  final String id;
  final String role; 
  final String? plate; 
  final String? phone; 
  final bool isPremium;
  final String status; // available, busy, break, suspended
  final int likes;
  final String password;

  AppUser({
    required this.id,
    required this.role,
    this.plate,
    this.phone,
    this.isPremium = false,
    this.status = 'available',
    this.likes = 0,
    this.password = '',
  });

  bool get isAdmin => role == 'admin';
  bool get isDriver => role == 'driver';

  factory AppUser.admin(String id) {
    return AppUser(
      id: id,
      role: 'admin',
    );
  }

  factory AppUser.driver({
    required String id,
    required String plate,
    String? phone,
    bool isPremium = false,
    String status = 'available',
    int likes = 0,
    String password = '',
  }) {
    return AppUser(
      id: id,
      role: 'driver',
      plate: plate,
      phone: phone,
      isPremium: isPremium,
      status: status,
      likes: likes,
      password: password,
    );
  }

  AppUser copyWith({
    String? id,
    String? role,
    String? plate,
    String? phone,
    bool? isPremium,
    String? status,
    int? likes,
    String? password,
  }) {
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      plate: plate ?? this.plate,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
      status: status ?? this.status,
      likes: likes ?? this.likes,
      password: password ?? this.password,
    );
  }
}
