class TraceModel {
  final String id;
  final String postulationId;
  final String description;
  final DateTime timestamp;
  final String createdBy;
  final bool pendingSync;

  const TraceModel({
    required this.id,
    required this.postulationId,
    required this.description,
    required this.timestamp,
    required this.createdBy,
    required this.pendingSync,
  });

  TraceModel copyWith({
    String? id,
    String? postulationId,
    String? description,
    DateTime? timestamp,
    String? createdBy,
    bool? pendingSync,
  }) {
    return TraceModel(
      id: id ?? this.id,
      postulationId: postulationId ?? this.postulationId,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      createdBy: createdBy ?? this.createdBy,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'postulationId': postulationId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory TraceModel.fromFirestore(Map<String, dynamic> data) {
    return TraceModel(
      id: data['id'] as String? ?? '',
      postulationId: data['postulationId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      timestamp: DateTime.parse(data['timestamp'] as String? ?? ''),
      createdBy: data['createdBy'] as String? ?? '',
      pendingSync: data['pendingSync'] as bool? ?? false,
    );
  }
}
