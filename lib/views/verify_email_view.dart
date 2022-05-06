import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar (title: const Text('Verify Email'),),
      body: Column(
        children: [
          const Text
            ("We've send you an email verification. Please verify your account"),
          const Text
            ("If you haven't received your email yet, Press the button below"),
          TextButton(
              onPressed:() async {
                final user = (FirebaseAuth.instance.currentUser);
                await user?.sendEmailVerification();
              },
              child: const Text('Send email Verification'), ),
          TextButton(
            onPressed: () async{
             await FirebaseAuth.instance.signOut();
             Navigator.of(context).pushNamedAndRemoveUntil(
                 registerRoute,
                     (route) => false,
             );
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
