import 'dart:async';

import '../../domain/entities/auth_user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository() {
    _controller.add(null);
  }

  final StreamController<AuthUserProfile?> _controller =
      StreamController<AuthUserProfile?>.broadcast();
  AuthUserProfile? _currentUser;

  @override
  Stream<AuthUserProfile?> authStateChanges() => _controller.stream;

  @override
  AuthUserProfile? get currentUser => _currentUser;

  @override
  Future<AuthUserProfile> signIn({
    required String email,
    required String password,
  }) async {
    _currentUser = AuthUserProfile(
      id: 'local-${email.trim()}',
      email: email.trim(),
      displayName: email.split('@').first,
      photoUrl: null,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUserProfile> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _currentUser = AuthUserProfile(
      id: 'local-${email.trim()}',
      email: email.trim(),
      displayName: displayName?.trim().isNotEmpty == true
          ? displayName!.trim()
          : email.split('@').first,
      photoUrl: null,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AuthUserProfile> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_currentUser == null) {
      throw StateError('No signed-in user');
    }

    _currentUser = AuthUserProfile(
      id: _currentUser!.id,
      email: _currentUser!.email,
      displayName: displayName?.trim().isNotEmpty == true
          ? displayName!.trim()
          : _currentUser!.displayName,
      photoUrl: photoUrl?.trim().isNotEmpty == true
          ? photoUrl!.trim()
          : _currentUser!.photoUrl,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }
}
