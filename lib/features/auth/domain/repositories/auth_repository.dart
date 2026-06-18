import '../entities/auth_user_profile.dart';

abstract class AuthRepository {
  Stream<AuthUserProfile?> authStateChanges();
  AuthUserProfile? get currentUser;
  Future<AuthUserProfile> signIn({
    required String email,
    required String password,
  });
  Future<AuthUserProfile> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> signOut();
  Future<AuthUserProfile> updateProfile({
    String? displayName,
    String? photoUrl,
  });
}
