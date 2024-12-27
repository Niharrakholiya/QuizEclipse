import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  final String quizId;

  LeaderboardPage({required this.quizId});

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    print("========== Starting Leaderboard Fetch ==========");
    try {
      print("Fetching quiz attempts for quizId: $quizId");

      // 1. Fetch quiz attempts
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quizAttempts')
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();

      print("Found ${querySnapshot.docs.length} quiz attempts");

      List<Map<String, dynamic>> leaderboard = [];

      // 2. Process each attempt
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String userId = data['userId'] ?? 'unknown';
        print('\nProcessing attempt:');
        print('- Attempt ID: ${doc.id}');
        print('- User ID: $userId');
        print('- Score: ${data['score']}');

        try {
          // 3. Fetch user data using the correct userId from the attempt
          print('Fetching user data for userId: $userId');
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('user')
              .doc(userId)
              .get();

          String userName;
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            userName = userData['name'] ?? 'Unknown User';
            print('✅ Found user: $userName');
          } else {
            userName = data['userName'] ?? 'Unknown User';
            print('⚠️ User document not found, using attempt userName: $userName');
          }

          // 4. Add to leaderboard
          leaderboard.add({
            'userName': userName,
            'score': data['score'] ?? 0,
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'userId': userId,
          });

        } catch (userError) {
          print('❌ Error fetching user data:');
          print('- Error: $userError');
          // Still add to leaderboard with available data
          leaderboard.add({
            'userName': data['userName'] ?? 'Unknown User',
            'score': data['score'] ?? 0,
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'userId': userId,
          });
        }
      }

      print("\n✅ Successfully compiled leaderboard with ${leaderboard.length} entries");
      return leaderboard;

    } catch (e) {
      print('❌ CRITICAL ERROR in _fetchLeaderboard:');
      print('- Error: $e');
      print('- Stack trace: ${StackTrace.current}');
      return [];
    } finally {
      print("========== Ending Leaderboard Fetch ==========\n");
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
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading leaderboard',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          List<Map<String, dynamic>> leaderboard = snapshot.data ?? [];

          if (leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No attempts found for this quiz',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              var entry = leaderboard[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPositionColor(index),
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    entry['userName'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score: ${entry['score']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        _formatDate(entry['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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

  Color _getPositionColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.blueGrey; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}