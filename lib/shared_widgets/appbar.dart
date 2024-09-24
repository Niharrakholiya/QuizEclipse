import "package:flutter/material.dart";

Widget appBar(context)
{
  return  RichText(
    text: TextSpan(
      style: TextStyle(fontSize:22,color: Color.fromARGB(255, 16, 91, 188)),
      children: const <TextSpan>[
        TextSpan(text: 'Quiz', style : TextStyle(color: Colors.black,fontWeight: FontWeight.w500)),
        TextSpan(text: 'App',style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}