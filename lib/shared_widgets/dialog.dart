import 'package:flutter/material.dart';

void errorDialogBox(BuildContext context, String errorMessage)
{
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);  // this will close the dialog box
              },
            )
          ],
        );
      });
}
void redirectDialogBox(BuildContext context,String message,destination)
{
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>destination));// this will close the dialog box
              },
            )
          ],
        );
      });
}