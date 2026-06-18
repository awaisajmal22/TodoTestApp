import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges().listen(
      (user) {
        emit(
          state.copyWith(
            status: user == null
                ? AuthStatus.unauthenticated
                : AuthStatus.authenticated,
            user: user,
            errorMessage: null,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthUserProfile?> _subscription;

  void bootstrap() {
    emit(state.copyWith(status: AuthStatus.loading));
    final currentUser = _repository.currentUser;
    emit(
      state.copyWith(
        status: currentUser == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: currentUser,
        errorMessage: null,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _repository.signIn(email: email, password: password);
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signOut() => _repository.signOut();

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _repository.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
