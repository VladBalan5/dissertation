abstract class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email, password;
  SignInRequested(this.email, this.password);
}

class SignOutRequested extends AuthEvent {}
