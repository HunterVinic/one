import 'package:flutter/material.dart';
import 'package:one/utilities/dialogs/generic_dialog.dart';
Future<bool> showLogoutDialog(BuildContext context){
  return showGenericDialog<bool>(
      context: context,
      title: 'Log Out',
      content: 'Are you sure that you want to LogOut ?',
    optionsBuilder: () =>{
        'Cancel' : false,
      'Log Out ': true,
    },
  ).then(
      (value) => value ?? false,
  );
}