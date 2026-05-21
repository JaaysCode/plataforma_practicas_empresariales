class DocumentModel {
  final String id;
  final String postulationId;
  final String type;
  final String name;
  final String url;
  final bool pendingSync;

  const DocumentModel({
    required this.id,
    required this.postulationId,
    required this.type,
    required this.name,
    required this.url,
    required this.pendingSync,
  });

  DocumentModel copyWith({
    String? id,
    String? postulationId,
    String? type,
    String? name,
    String? url,
    bool? pendingSync,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      postulationId: postulationId ?? this.postulationId,
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'postulationId': postulationId,
      'type': type,
      'name': name,
      'url': url,
    };
  }

  factory DocumentModel.fromFirestore(Map<String, dynamic> data) {
    return DocumentModel(
      id: data['id'] as String? ?? '',
      postulationId: data['postulationId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      name: data['name'] as String? ?? '',
      url: data['url'] as String? ?? '',
      pendingSync: data['pendingSync'] as bool? ?? false,
    );
  }
}
