import 'package:flutter/material.dart';

Widget Button(BuildContext context, String text) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(34),
    ),
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width - 48,
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}
