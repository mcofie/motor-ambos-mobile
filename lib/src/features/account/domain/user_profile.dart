class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? homeLocation; // e.g. "East Legon, Accra"
  final bool marketingOptIn;
  final bool pushNotificationsEnabled;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.homeLocation,
    this.marketingOptIn = true,
    this.pushNotificationsEnabled = true,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? homeLocation,
    bool? marketingOptIn,
    bool? pushNotificationsEnabled,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      homeLocation: homeLocation ?? this.homeLocation,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      pushNotificationsEnabled:
      pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }
}