import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitializer extends AuthEvent {
  const AuthEventInitializer ();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
final String password;
const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const  AuthEventLogOut();
}