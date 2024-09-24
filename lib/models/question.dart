class Question {
  String questionText;
  String option1;
  String option2;
  String option3;
  String option4;
  int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswerIndex,
  });

  // Method to convert Question object to Map
  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  // Factory method to create Question object from Firestore map
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'],
      option1: json['option1'],
      option2: json['option2'],
      option3: json['option3'],
      option4: json['option4'],
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }
}
