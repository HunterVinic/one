import 'package:flutter/material.dart';
import 'package:one/constants/routes.dart';
import 'package:one/services/auth/auth_exceptions.dart';
import 'package:one/services/auth/auth_service.dart';
import 'package:one/utilities/dialogs/error_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>{
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column (
        children:[
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
          ),
          RaisedButton(
            elevation: 2,
            focusElevation: 4,
            hoverElevation: 4,
            highlightElevation: 8,
            disabledElevation: 0,
            onPressed: () async{
              final email = _email.text;
              final password = _password.text;
              try {
                AuthService.firebase().logIn(
                    email: email,
                    password: password
                );
                 final user = AuthService.firebase().currentUser;
                 if (user?.isEmailVerified ??true){
                   Navigator.of(context)
                       .pushNamedAndRemoveUntil(
                       notesRoute,
                           (route) => false,
                   );
                 }
                 else {
                   Navigator.of(context)
                       .pushNamedAndRemoveUntil(
                     verifyEmailRoute,
                         (route) => false,
                   );
                 }

              }
              on UserNotFoundAuthException {
                await showErrorDialog(
                    context,
                    'User not found',
                );
              }
              on WrongPasswordAuthException{
                await showErrorDialog(context,'Wrong credentials');
              }
              on GenericAuthException {
                await showErrorDialog(
                  context,'Authentication Error',
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(onPressed: (){
            Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                    (route) => false,
            );

          }, child: const Text('Not Registered yet ? Register Here!'))
        ],
      ),
    );
  }
}


