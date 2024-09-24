
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizeclipse/Ui/participant_home.dart'; // participant home page
import 'package:quizeclipse/Ui/admin_home.dart'; // admin home page
import 'package:quizeclipse/Ui/sign_in.dart';
import 'package:quizeclipse/services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _getHomePage(User? user) async {
    if (user == null) {
      return SignIn();
    }

    // Retrieve the current user's email
    final email = user.email;
    if (email == null) {
      return SignIn();
    }

    // Find user by email from Firestore
    final userModel = await findUserByEmail(email);
    // Redirect based on user role
    if (userModel.role == 'UserRole.admin') {
      print("admin");
      return AdminHomePage(); // Admin home page
    } else {
      print("participant");
      return ParticipantHomePage(); // Participant home page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            // User is authenticated
            return FutureBuilder<Widget>(
              future: _getHomePage(snapshot.data),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (futureSnapshot.hasData) {
                  return futureSnapshot.data!;
                }

                return SignIn();
              },
            );
          }


          return SignIn();
        },
      ),
    );
  }
}
