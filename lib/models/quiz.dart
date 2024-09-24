import 'package:quizeclipse/models/question.dart';

class Quiz {
  String id;
  String ImageUrl;
  String Name;
  String Description;
  int timeDuration;
  int numberOfQuestions;
  List<Question> questionList;

  Quiz({
    this.id = "",
    this.ImageUrl = "",
    this.Name = "",
    this.Description = "",
    this.timeDuration = 30,
    this.numberOfQuestions = 0,
    List<Question>? questionList, // Accept nullable List<Question> for optional initialization
  }) : questionList = questionList ?? []; // Initialize the list here

  // Factory method to create a Quiz object from Firestore data
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? "",
      ImageUrl: json['imageUrl'] ?? "",
      Name: json['name'] ?? "",
      Description: json['description'] ?? "",
      timeDuration: json['timeDuration'] ?? 30,
      numberOfQuestions: json['numberOfQuestions'] ?? 0,
      questionList: (json['questionList'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
    );
  }

  // Method to convert Quiz object to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': ImageUrl,
      'name': Name,
      'description': Description,
      'timeDuration': timeDuration,
      'numberOfQuestions': numberOfQuestions,
      'questionList': questionList.map((question) => question.toJson()).toList(),
    };
  }
}
