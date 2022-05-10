import 'package:flutter/cupertino.dart';
import 'package:one/utilities/dialogs/generic_dialog.dart';

Future <void> showErrorDialog(
BuildContext context,
String text
    ){
  return showGenericDialog(
    context: context,
    title: 'an Error occurred',
    content: text,
    optionsBuilder: () => {
      'OK': null
    });

}
