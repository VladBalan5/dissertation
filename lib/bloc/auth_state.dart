import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class UnauthenticatedState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;
  AuthenticatedState(this.user);
}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}
