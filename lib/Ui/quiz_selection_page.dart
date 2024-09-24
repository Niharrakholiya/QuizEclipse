import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeclipse/models/quiz.dart';
import 'package:quizeclipse/Ui/quiz_page.dart';

class QuizSelectionPage extends StatelessWidget {
  final String userId;

  QuizSelectionPage({required this.userId});

  Future<bool> _hasAttemptedQuiz(String quizId) async {
    print(userId);
    print(quizId);
    final query = await FirebaseFirestore.instance
        .collection('quizAttempts')
        .where('userId', isEqualTo: userId)
        .where('quizId', isEqualTo: quizId)
        .get();
    print(query.docs.isNotEmpty);
    return query.docs.isNotEmpty;
  }

  void _showQuizCodeDialog(BuildContext context, String quizCode, String quizId) {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Quiz Code'),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(hintText: 'Enter the quiz code'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                String enteredCode = codeController.text.trim();
                if (enteredCode == quizCode) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(quizId: quizId, userId: userId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect quiz code!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Quiz'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String quizCode = data['id'];
              Quiz quiz = Quiz.fromJson(data);

              return FutureBuilder<bool>(
                future: _hasAttemptedQuiz(quiz.id),
                builder: (context, attemptSnapshot) {
                  if (attemptSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  bool hasAttempted = attemptSnapshot.data ?? false;

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(quiz.Name),
                      subtitle: Text('${quiz.numberOfQuestions} questions'),
                      trailing: hasAttempted
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.arrow_forward_ios),
                      onTap: hasAttempted
                          ? null  // Disable tap for attempted quizzes
                          : () => _showQuizCodeDialog(context, quizCode, quiz.id),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}