class PostulationModel {
  final String id;
  final String userId;
  final String offerId;
  final String status;
  final DateTime appliedAt;
  final bool pendingSync;

  const PostulationModel({
    required this.id,
    required this.userId,
    required this.offerId,
    required this.status,
    required this.appliedAt,
    required this.pendingSync,
  });

  PostulationModel copyWith({
    String? id,
    String? userId,
    String? offerId,
    String? status,
    DateTime? appliedAt,
    bool? pendingSync,
  }) {
    return PostulationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      offerId: offerId ?? this.offerId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'offerId': offerId,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  factory PostulationModel.fromFirestore(Map<String, dynamic> data) {
    return PostulationModel(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      offerId: data['offerId'] as String? ?? '',
      status: data['status'] as String? ?? '',
      appliedAt: DateTime.parse(data['appliedAt'] as String? ?? ''),
      pendingSync: data['pendingSync'] as bool? ?? false,
    );
  }
}
