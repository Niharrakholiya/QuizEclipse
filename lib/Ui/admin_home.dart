import 'package:flutter/material.dart';
import 'package:quizeclipse/Ui/create_quiz.dart';
import 'package:quizeclipse/services/auth_services/auth.dart';

class AdminHomePage extends StatelessWidget {
  final AuthService auth = AuthService();

  Future<void> logout(BuildContext context) async {
    try {
      await auth.signOut();
      // Navigate to login page or show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App Admin', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Handle profile action
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 40),
                Center(
                  child: Hero(
                    tag: 'quiz_icon',
                    child: Container(
                      width: 120,
                      height: 120,
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
                    'Welcome, Admin!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Create quizzes to test knowledge and engage participants.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                SizedBox(height: 48),
                _buildButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateQuiz()),
                    );
                  },
                  text: 'Create New Quiz',
                  icon: Icons.add_circle_outline,
                ),
                SizedBox(height: 16),
                _buildButton(
                  onPressed: () {
                    // Navigate to view all quizzes
                  },
                  text: 'View All Quizzes',
                  icon: Icons.list_alt,
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    bool isPrimary = true,
  }) {
    return Container(
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
        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isPrimary ? Colors.white : Colors.blue),
        label: Text(
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
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}