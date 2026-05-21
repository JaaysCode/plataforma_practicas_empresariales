class OfferModel {
  final String id;
  final String companyNit;
  final String title;
  final String description;
  final String position;
  final String salary;
  final String requirements;
  final bool pendingSync;

  const OfferModel({
    required this.id,
    required this.companyNit,
    required this.title,
    required this.description,
    required this.position,
    required this.salary,
    required this.requirements,
    required this.pendingSync,
  });

  OfferModel copyWith({
    String? id,
    String? companyNit,
    String? title,
    String? description,
    String? position,
    String? salary,
    String? requirements,
    bool? pendingSync,
  }) {
    return OfferModel(
      id: id ?? this.id,
      companyNit: companyNit ?? this.companyNit,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      requirements: requirements ?? this.requirements,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'companyNit': companyNit,
      'title': title,
      'description': description,
      'position': position,
      'salary': salary,
      'requirements': requirements,
    };
  }

  factory OfferModel.fromFirestore(Map<String, dynamic> data) {
    return OfferModel(
      id: data['id'] as String? ?? '',
      companyNit: data['companyNit'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      position: data['position'] as String? ?? '',
      salary: data['salary'] as String? ?? '',
      requirements: data['requirements'] as String? ?? '',
      pendingSync: false as bool? ?? false,
    );
  }
}