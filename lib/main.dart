import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one/services/auth/bloc/auth_bloc.dart';
import 'package:one/services/auth/bloc/auth_event.dart';
import 'package:one/services/auth/bloc/auth_state.dart';
import 'package:one/services/auth/firebase_auth_provider.dart';
import 'package:one/views/login_view.dart';
import 'package:one/views/notes/create_update_note_view.dart';
import 'package:one/views/notes/notes_view.dart';
import 'package:one/views/register_view.dart';
import 'package:one/views/verify_email_view.dart';
import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitializer());
    return BlocBuilder<AuthBloc, AuthState>
      (builder: (context, state){
      if (state is AuthStateLoggedIn){
        return const NotesView();
      }else if (state is AuthStateNeedsVerification){
        return const VerifyEmailView();
      }else if (state is AuthStateLoggedOut){
        return const LoginView();
      }else {
        return const Scaffold (
          body: CircularProgressIndicator(),
        );
      }
    },);
  }
}
