// ─── Auth Events ──────────────────────────────────────────────────────────────
// All possible inputs/triggers for the AuthBloc
// ─────────────────────────────────────────────────────────────────────────────

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when user submits login form
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when user taps logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Triggered on app start to check auth state
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
