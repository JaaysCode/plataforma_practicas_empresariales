class UserModel {
  final String cc;
  final String name;
  final String lastName;
  final String email;
  final bool pendingSync;

  const UserModel({
    required this.cc,
    required this.name,
    required this.lastName,
    required this.email,
    required this.pendingSync,
  });

  UserModel copyWith({
    String? cc,
    String? name,
    String? lastName,
    String? email,
    bool? pendingSync,
  }) {
    return UserModel(
      cc: cc ?? this.cc,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cc': cc,
      'name': name,
      'lastName': lastName,
      'email': email,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      cc: data['cc'] as String? ?? '',
      name: data['name'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      pendingSync: false as bool? ?? false,
    );
  }
}