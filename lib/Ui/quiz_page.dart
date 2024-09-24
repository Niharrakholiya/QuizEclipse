import 'dart:async'; // Import this for Timer
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeclipse/models/question.dart';
import 'package:battery_plus/battery_plus.dart'; // Import battery_plus
import 'leader_board.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String userId; // Add userId field

  QuizPage({required this.quizId, required this.userId}); // Include userId in constructor

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<Question> questions = [];
  int score = 0;
  late Timer _timer;
  int _remainingTime = 0; // In seconds
  String attemptId = ''; // Store attempt ID for future updates

  // Initialize the battery instance
  final Battery _battery = Battery();
  String _batteryLevel = 'Unknown'; // To store the battery level

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _recordAttempt();  // Record attempt when quiz starts
    _getBatteryLevel(); // Fetch battery level when quiz starts
  }

  // Method to fetch the current battery level
  Future<void> _getBatteryLevel() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      setState(() {
        _batteryLevel = '$batteryLevel%'; // Update battery level
      });
      if (batteryLevel < 20) {
        _showLowBatteryWarning();
      }
    } catch (e) {
      print('Failed to get battery level: $e');
    }
  }

  // Display low battery warning
  void _showLowBatteryWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Low Battery Warning'),
          content: Text('Your battery is below 20%. '
              'Please charge your device before starting the quiz.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchQuestions() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('id', isEqualTo: widget.quizId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot quizDoc = querySnapshot.docs.first;
        Map<String, dynamic> quizData = quizDoc.data() as Map<String, dynamic>;

        List<dynamic> questionsList = quizData['questionList'];
        questions = questionsList.map((q) => Question.fromJson(q)).toList();
        _remainingTime = quizData['timeDuration'] * 60; // Convert minutes to seconds
        _startTimer();
        setState(() {});
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  Future<void> _recordAttempt() async {
    try {
      // Add a new quiz attempt and store its ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();



      // Now add a new quiz attempt with the user's name
      DocumentReference attemptRef = await FirebaseFirestore.instance.collection('quizAttempts').add({
        'userId': widget.userId,
        'quizId': widget.quizId,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
      attemptId = attemptRef.id;
    } catch (e) {
      print('Error recording quiz attempt: $e');
    }
  }
  Future<void> _updateScore() async {
    try {
      // Update the score for the specific attempt in Firestore
      await FirebaseFirestore.instance.collection('quizAttempts').doc(attemptId).update({
        'score': score,
      });
    } catch (e) {
      print('Error updating score: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_remainingTime == 0) {
        timer.cancel();
        _showTimeExpiredDialog();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (selectedIndex == questions[currentQuestionIndex].correctAnswerIndex) {
      score++;
    }

    // Update score in Firestore after each question is answered
    _updateScore();
    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    _timer.cancel(); // Stop the timer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Completed'),
          content: Text('Your score: $score out of ${questions.length}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaderboardPage(quizId: widget.quizId),
                  ),
                ); // Navigate to the leaderboard page or result page
              },
            ),
          ],
        );
      },
    );
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Time\'s Up!'),
          content: Text('Your score: $score out of ${questions.length}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaderboardPage(quizId: widget.quizId),
                  ),
                ); // Navigate to the leaderboard or result page
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
        title: Text('Quiz'),
        backgroundColor: Colors.blue,
      ),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display battery status at the start of the quiz
            Text(
              'Battery Level: $_batteryLevel',
              style: TextStyle(fontSize: 16, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Time Remaining: ${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questions[currentQuestionIndex].questionText,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ...[
                      questions[currentQuestionIndex].option1,
                      questions[currentQuestionIndex].option2,
                      questions[currentQuestionIndex].option3,
                      questions[currentQuestionIndex].option4,
                    ].asMap().entries.map((entry) {
                      int index = entry.key;
                      String optionText = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          child: Text(optionText),
                          onPressed: () => _handleAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }
}
