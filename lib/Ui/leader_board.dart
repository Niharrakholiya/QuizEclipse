import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  final String quizId;

  LeaderboardPage({required this.quizId});

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quizAttempts')
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .orderBy('timestamp', descending: false)  // Changed to ascending
          .limit(50)  // Limit to top 50 scores for performance
          .get();

      List<Map<String, dynamic>> leaderboard = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        print('Fetching user for userId: ${data['userId']}');

        // Fetch user name from users collection based on userId
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc('YmmU9zvMUgeMhBxbEUVRkI9ebvB3')  // Replace with a valid userId
            .get();

        if (userDoc.exists) {
          // Extract the required fields from the user document
          String userName = userDoc['name'] ?? 'Unknown';
          String email = userDoc['email'] ?? 'Unknown Email';
          String role = userDoc['role'] ?? 'Unknown Role';

          print('User Name: $userName');
          print('Email: $email');
          print('Role: $role');
        } else {
          print('User not found');
        }
        // Check if the user document exists
        String userName = 'Unknown User';
        if (userDoc.exists) {
          userName = userDoc.get('name') ?? 'Unknown User';
        }

        leaderboard.add({
          'userName': userName,
          'score': data['score'],
          'timestamp': data['timestamp'],
        });
      }

      return leaderboard;
    } catch (e) {
      print('Error fetching leaderboard data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching leaderboard'));
          }

          List<Map<String, dynamic>> leaderboard = snapshot.data!;

          if (leaderboard.isEmpty) {
            return Center(child: Text('No attempts found for this quiz.'));
          }

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              var entry = leaderboard[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(entry['userName'], style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score: ${entry['score']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(entry['timestamp']),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
