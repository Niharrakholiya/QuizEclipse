import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizeclipse/services/auth_services/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(  options: const FirebaseOptions(
    apiKey: 'AIzaSyBqAqZpivK04KT6r5rML5Q9vn4vSK4N7tE',
    appId: '1:668795222324:android:b6be0fdbf26bf805c94d61',
    messagingSenderId: '668795222324',
    projectId: 'quizeclipse-84e09',
    storageBucket: 'quizeclipse-84e09.appspot.com',
  )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 115, 167, 222)),
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}
