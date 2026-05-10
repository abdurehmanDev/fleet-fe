// ─── Auth States ──────────────────────────────────────────────────────────────
// All possible output states of the AuthBloc
// ─────────────────────────────────────────────────────────────────────────────

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth status check in progress
class AuthCheckInProgress extends AuthState {
  const AuthCheckInProgress();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login is in progress (loading)
class AuthLoginInProgress extends AuthState {
  const AuthLoginInProgress();
}

/// Login failed
class AuthLoginFailure extends AuthState {
  final String message;

  const AuthLoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Logout complete
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
