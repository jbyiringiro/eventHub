import 'package:equatable/equatable.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to trigger registration
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, phone];
}

/// Event to trigger Google Sign-In
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Event to trigger logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event to check authentication status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event to trigger password reset
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
