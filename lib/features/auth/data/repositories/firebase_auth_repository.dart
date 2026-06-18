import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<AuthUserProfile?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AuthUserProfile? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<AuthUserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _mapUser(credential.user)!;
  }

  @override
  Future<AuthUserProfile> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
    }
    return _mapUser(_auth.currentUser)!;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AuthUserProfile> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    await _auth.currentUser?.updateDisplayName(
      displayName?.trim().isEmpty == true ? null : displayName?.trim(),
    );
    await _auth.currentUser?.updatePhotoURL(
      photoUrl?.trim().isEmpty == true ? null : photoUrl?.trim(),
    );
    await _auth.currentUser?.reload();
    return _mapUser(_auth.currentUser)!;
  }

  AuthUserProfile? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUserProfile(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
