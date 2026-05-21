class CompanyModel {
  final String nit;
  final String name;
  final String address;
  final String sector;
  final bool pendingSync;

  const CompanyModel({
    required this.nit,
    required this.name,
    required this.address,
    required this.sector,
    required this.pendingSync,
  });


  CompanyModel copyWith({
    String? nit,
    String? name,
    String? address,
    String? sector,
    bool? pendingSync,
  }) {
    return CompanyModel(
      nit: nit ?? this.nit,
      name: name ?? this.name,
      address: address ?? this.address,
      sector: sector ?? this.sector,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nit': nit,
      'name': name,
      'address': address,
      'sector': sector,
    };
  }

  factory CompanyModel.fromFirestore(Map<String, dynamic> data) {
    return CompanyModel(
      nit: data['nit'] as String? ?? '',
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      sector: data['sector'] as String? ?? '',
      pendingSync: false as bool? ?? false,
    );
  }
}