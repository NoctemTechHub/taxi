class TaxiRequest {
  final String id;
  final String plate;
  final String type; 
  final Map<String, dynamic> data;
  final String status; 
  final DateTime? createdAt;

  TaxiRequest({
    required this.id,
    required this.plate,
    required this.type,
    required this.data,
    required this.status,
    this.createdAt,
  });

  factory TaxiRequest.fromJson(Map<String, dynamic> json, String docId) {
    return TaxiRequest(
      id: docId,
      plate: json['plate'] ?? '',
      type: json['type'] ?? '',
      data: json['data'] ?? {},
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate': plate,
      'type': type,
      'data': data,
      'status': status,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }
}
