import 'package:flutter/material.dart';
import 'package:quizeclipse/models/question.dart';
import 'package:quizeclipse/models/quiz.dart';
import 'package:quizeclipse/services/quiz_service.dart';
import 'package:quizeclipse/Ui/admin_home.dart'; // Import the AdminHomePage

class AddQuestion extends StatefulWidget {
  final String quizId;
  final int numberOfQuestions;
  final Quiz quizData;

  AddQuestion({
    required this.quizId,
    required this.numberOfQuestions,
    required this.quizData,
  });

  @override
  AddQuestionState createState() => AddQuestionState();
}

class AddQuestionState extends State<AddQuestion> {
  final _formKey = GlobalKey<FormState>();
  late Question questionObj;
  List<Question> questionsList = [];
  String correctAnswerIndex = "0";
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    questionObj = Question(
      questionText: '',
      option1: '',
      option2: '',
      option3: '',
      option4: '',
      correctAnswerIndex: 0,
    );
  }

  void addQuestionHandler() {
    if (_formKey.currentState!.validate()) {
      questionObj.correctAnswerIndex = int.parse(correctAnswerIndex);

      setState(() {
        questionsList.add(questionObj);

        if (currentQuestionIndex < widget.numberOfQuestions - 1) {
          currentQuestionIndex++;
          questionObj = Question(
            questionText: '',
            option1: '',
            option2: '',
            option3: '',
            option4: '',
            correctAnswerIndex: 0,
          );
          correctAnswerIndex = "0";
          _formKey.currentState!.reset();
        }
      });
    }
  }

  Future<void> submitQuestionsHandler() async {
    if (_formKey.currentState!.validate()) {
      addQuestionHandler(); // Add the last question

      try {
        // Create a mutable copy of the current question list
        List<Question> updatedQuestionsList = List.from(widget.quizData.questionList);
        print(updatedQuestionsList);
        print(widget.quizData.questionList);
        updatedQuestionsList.addAll(questionsList); // Add the new questions to the mutable copy

        // Update the quizData object
        widget.quizData.questionList = updatedQuestionsList;
        widget.quizData.numberOfQuestions = updatedQuestionsList.length;

        // Call Firestore service to update the document
        await getQuizById(widget.quizId,widget.quizData.questionList);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Questions added successfully')),
        );

        // Navigate to the AdminHomePage and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AdminHomePage()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
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
                    'Question ${currentQuestionIndex + 1} of ${widget.numberOfQuestions}',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  _buildTextField(
                    label: 'Question Text',
                    validator: (val) => val!.isEmpty ? 'Enter question text' : null,
                    onChanged: (val) => questionObj.questionText = val,
                  ),
                  SizedBox(height: 16),
                  ...List.generate(4, (index) =>
                      Column(
                        children: [
                          _buildTextField(
                            label: 'Option ${index + 1}',
                            validator: (val) => val!.isEmpty ? 'Enter option ${index + 1}' : null,
                            onChanged: (val) {
                              switch (index) {
                                case 0: questionObj.option1 = val; break;
                                case 1: questionObj.option2 = val; break;
                                case 2: questionObj.option3 = val; break;
                                case 3: questionObj.option4 = val; break;
                              }
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                  ),
                  DropdownButtonFormField<String>(
                    value: correctAnswerIndex,
                    items: List.generate(4, (index) =>
                        DropdownMenuItem(child: Text("Option ${index + 1}"), value: index.toString())
                    ),
                    decoration: InputDecoration(
                      labelText: 'Correct Answer',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (val) => setState(() => correctAnswerIndex = val!),
                    validator: (val) => val == null ? "Select the correct option" : null,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    child: Text(
                      currentQuestionIndex == widget.numberOfQuestions - 1
                          ? 'Submit All Questions'
                          : 'Add Question',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: currentQuestionIndex == widget.numberOfQuestions - 1
                        ? submitQuestionsHandler
                        : addQuestionHandler,
                  ),
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
    required FormFieldValidator<String> validator,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}