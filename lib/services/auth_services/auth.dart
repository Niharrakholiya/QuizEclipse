import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:quizeclipse/models/user.dart' as models;
import 'package:quizeclipse/services/user_service.dart';
class AuthService{
  // instance of the auth
  final FirebaseAuth auth = FirebaseAuth.instance;
  // firebase auth service methods :
// 1. sign up
  Future<UserCredential> signUpWithEmailPassword(String email, String password , String name , String role) async
  {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      // add user to the datbase
      models.User user = models.User(name:name, email:email,role: role);
      await addUser(user);
      return userCredential;
    }
    on Exception catch (e)
    {
      throw e;
    }
  }
// 2. sign in
  Future<UserCredential> signInWithEmailPassword(String email,String password) async
  {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      print(UserCredential);
      return userCredential;
    }
    on FirebaseAuthException catch (e)
    {
      throw e;
    }
  }
// 3. log out
  Future<void> signOut() async {
    return await auth.signOut();
  }
  String? getUserId() {
    User? user = auth.currentUser;
    return user?.uid;
  }
//
}

//