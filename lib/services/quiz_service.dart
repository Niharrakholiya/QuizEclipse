import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeclipse/models/question.dart';
import 'package:quizeclipse/models/quiz.dart';

Future<String> addQuiz(Quiz quiz) async {
  try {
    final docRef = await FirebaseFirestore.instance.collection('quizzes').add(quiz.toJson());
    return docRef.id;
  } catch (e) {
    print('Error adding quiz: $e');
    throw e;
  }
}



Future<void> getQuizById(String quizId, List<Question> updatedQuestionsList) async {
  // Access the Firestore instance
  final firestore = FirebaseFirestore.instance;

  // Perform a query to find the document where the 'id' field matches the quizId
  final querySnapshot = await firestore
      .collection('quizzes')
      .where('id', isEqualTo: quizId)
      .get();

  // Check if any documents were found
  if (querySnapshot.docs.isNotEmpty) {
    // If found, get the first document's reference
    final quizDocument = querySnapshot.docs.first;
    final quizDocRef = quizDocument.reference;

    // Update the questionList and numberOfQuestions in Firestore
    await quizDocRef.update({
      'questionList': updatedQuestionsList.map((question) => question.toJson()).toList(),
    });

    print('Quiz updated successfully!');
  } else {
    // If no documents were found
    print('No quiz found with id: $quizId');
  }
}
