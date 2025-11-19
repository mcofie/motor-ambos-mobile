import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(
    const UserProfile(
      id: 'user_001',
      name: 'Max',
      phone: '+233 20 000 0000',
      email: 'max@example.com',
      homeLocation: 'Accra, Ghana',
      marketingOptIn: true,
      pushNotificationsEnabled: true,
    ),
  );

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateHomeLocation(String? location) {
    state = state.copyWith(homeLocation: location);
  }

  void setMarketingOptIn(bool value) {
    state = state.copyWith(marketingOptIn: value);
  }

  void setPushNotificationsEnabled(bool value) {
    state = state.copyWith(pushNotificationsEnabled: value);
  }
}

final userProfileProvider =
StateNotifierProvider<UserProfileNotifier, UserProfile>(
      (ref) => UserProfileNotifier(),
);