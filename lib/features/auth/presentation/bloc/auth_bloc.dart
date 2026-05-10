// ─── Auth BLoC ────────────────────────────────────────────────────────────────
// Business logic controller for authentication — maps Events → States
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/auth/domain/entities/user_entity.dart';
import 'package:rangrej_fleet/features/auth/domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoginInProgress());

    final (user, failure) = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    if (failure != null) {
      emit(AuthLoginFailure(message: failure.message));
      return;
    }

    if (user != null) {
      emit(AuthAuthenticated(user: user));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoggedOut());
  }

  // ── Check Auth ────────────────────────────────────────────────────────────
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckInProgress());
    // Implement token check via SecureStorage if needed
    emit(const AuthUnauthenticated());
  }
}
