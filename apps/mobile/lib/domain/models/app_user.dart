enum UserRole {
  consumer,
  providerStaff,
  technician,
  superAdmin;

  String get label => switch (this) {
    consumer => 'Consumer',
    providerStaff => 'Provider staff',
    technician => 'Technician',
    superAdmin => 'Super admin',
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.providerId,
  });

  final String id;
  final String name;
  final UserRole role;
  final String? providerId;
}
