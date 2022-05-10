import 'package:flutter/material.dart';
import 'package:one/utilities/dialogs/generic_dialog.dart';
Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure that you want to delete this item?',
    optionsBuilder: () =>{
      'Cancel' : false,
      'Log Out ': true,
    },
  ).then(
        (value) => value ?? false,
  );
}