import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizeclipse/Ui/add_question.dart';
import 'package:quizeclipse/models/quiz.dart';
import 'package:quizeclipse/services/quiz_service.dart';
import 'package:quizeclipse/shared_widgets/appbar.dart';
import 'dart:math';

class CreateQuiz extends StatefulWidget {
  @override
  CreateQuizState createState() => CreateQuizState();
}

class CreateQuizState extends State<CreateQuiz> {
  final _formKey = GlobalKey<FormState>();
  late Quiz quiz;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    quiz = Quiz(id: _generateQuizCode());
  }

  String _generateQuizCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create a New Quiz',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildTextField(
                    label: 'Quiz Image URL (optional)',
                    icon: Icons.image,
                    onChanged: (val) => quiz.ImageUrl = val,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Quiz Name',
                    icon: Icons.quiz,
                    validator: (val) => val!.isEmpty ? 'Enter Quiz name' : null,
                    onChanged: (val) => quiz.Name = val,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description',
                    icon: Icons.description,
                    validator: (val) => val!.isEmpty ? 'Enter Quiz Description' : null,
                    onChanged: (val) => quiz.Description = val,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Number of Questions',
                    icon: Icons.format_list_numbered,
                    validator: (val) {
                      if (val!.isEmpty) return 'Enter number of questions';
                      if (int.tryParse(val) == null) return 'Enter a valid number';
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onChanged: (val) => quiz.numberOfQuestions = int.tryParse(val) ?? 1,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Time Duration (minutes)',
                    icon: Icons.timer,
                    validator: (val) {
                      if (val!.isEmpty) return 'Enter time duration';
                      if (int.tryParse(val) == null) return 'Enter a valid number';
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onChanged: (val) => quiz.timeDuration = int.tryParse(val) ?? 30,
                  ),
                  SizedBox(height: 24),
                  _buildSubmitButton(),
                  SizedBox(height: 24),
                  _buildQuizCodeDisplay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Future<void> quizCreationHandler() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await addQuiz(quiz);
      if (!mounted) return;

      setState(() => _isLoading = false);

      // Navigate to the AddQuestion page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddQuestion(
          quizId: quiz.id,
          numberOfQuestions: quiz.numberOfQuestions,
          quizData: quiz,
        )),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : quizCreationHandler,
        child: _isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Create Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildQuizCodeDisplay() {
    return Column(
      children: [
        Text(
          'Quiz Code',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                quiz.id,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: quiz.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Quiz code copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}