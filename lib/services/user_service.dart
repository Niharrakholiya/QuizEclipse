import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeclipse/models/user.dart';
import 'package:quizeclipse/utils/constants.dart';
import 'package:quizeclipse/utils/db.dart';

addUser(User user)
{
  db.collection(USER_COLLECTION).add(user.getMap())
      .then((DocumentReference doc)=> print("user added to db"));
}
deleteUser(String email)
{

}
getUser()
{

}
updateUser(String email,User newUser)
{

}
Future<User> findUserByEmail(String email) async
{
  QuerySnapshot querySnapshot = await db.collection(USER_COLLECTION).where("email" , isEqualTo: email).get();
  DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
  return User.fromMap(documentSnapshot.data() as Map<String, dynamic>);

}