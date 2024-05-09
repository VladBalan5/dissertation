import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(UnauthenticatedState()) {
    on<SignInRequested>((event, emit) async {
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: event.email, password: event.password);
        emit(AuthenticatedState(userCredential.user!));
      } catch (_) {
        emit(AuthErrorState("Failed to sign in"));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await _auth.signOut();
      emit(UnauthenticatedState());
    });
  }
}
