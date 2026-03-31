/// Access roles for the tube sealer system.
enum UserRole {
  operator,
  supervisor,
  admin,
  service;

  String get label {
    switch (this) {
      case UserRole.operator:
        return 'Operator';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.admin:
        return 'Admin';
      case UserRole.service:
        return 'Service';
    }
  }

  /// Whether this role can edit recipes.
  bool get canEditRecipes =>
      this == UserRole.admin || this == UserRole.service;

  /// Whether this role can access maintenance.
  bool get canAccessMaintenance =>
      this == UserRole.service;

  /// Whether this role can access settings admin section.
  bool get canAccessAdminSettings =>
      this == UserRole.admin || this == UserRole.service;
}
