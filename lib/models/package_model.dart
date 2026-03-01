class TaxiPackage {
  final String id;
  final String name;
  final String price;
  final String duration;
  final bool isPremium;
  final String? description;

  TaxiPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.isPremium,
    this.description,
  });

  factory TaxiPackage.fromJson(Map<String, dynamic> json, String docId) {
    return TaxiPackage(
      id: docId,
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      duration: json['duration'] ?? '',
      isPremium: json['isPremium'] ?? false,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'isPremium': isPremium,
      'description': description,
    };
  }
}
