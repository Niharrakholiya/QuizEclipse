import 'package:flutter/material.dart';
import 'package:quizeclipse/Ui/quiz_selection_page.dart';
import 'package:quizeclipse/services/auth_services/auth.dart';
import 'package:quizeclipse/Ui/leader_board.dart';  // Import LeaderboardPage

class ParticipantHomePage extends StatelessWidget {
  final AuthService auth = AuthService();

  Future<String> _getUserId() async {
    String? userId = auth.getUserId();
    if (userId != null) {
      return userId;
    } else {
      throw Exception('User not logged in or user ID not available.');
    }
  }

  void logout() async {
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(child: Text('Error retrieving user data')),
          );
        }

        String userId = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Quiz Eclipse',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.person, color: Colors.black),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile action')),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () {
                  logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged out successfully')),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Welcome back,',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ready for a challenge?',
                      style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: Hero(
                        tag: 'quiz_icon',
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'imgs/icon2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Test your knowledge with our fun and interactive quizzes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700], height: 1.5),
                    ),
                    SizedBox(height: 40),
                    _buildButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizSelectionPage(userId: userId),
                          ),
                        );
                      },
                      text: 'Start Quiz',
                      isPrimary: true,
                    ),
                    SizedBox(height: 16),
                    _buildButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaderboardPage(quizId: 'RC7WE8'),  // Pass quizId
                          ),
                        );
                      },
                      text: 'View Leaderboard',
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({required VoidCallback onPressed, required String text, required bool isPrimary}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
          colors: [Colors.blue, Colors.blue.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        borderRadius: BorderRadius.circular(28),
        border: isPrimary ? null : Border.all(color: Colors.blue, width: 2),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : Colors.blue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
