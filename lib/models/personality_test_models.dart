// Models for the personality test

enum PersonalityClass {
  flower,
  jewel,
  shaker,
  stream,
  flowerJewel,
  jewelShaker,
  shakerStream,
  streamFlower,
}

class Question {
  final int id;
  final String question;
  final bool expectedAnswer;
  final List<PersonalityClass> classes;
  final int weight;

  Question({
    required this.id,
    required this.question,
    required this.expectedAnswer,
    required this.classes,
    this.weight = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'expectedAnswer': expectedAnswer,
      'classes': classes.map((c) => c.toString().split('.').last).toList(),
      'weight': weight,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      expectedAnswer: json['expectedAnswer'],
      classes: (json['classes'] as List)
          .map((c) => PersonalityClass.values
              .firstWhere((e) => e.toString().split('.').last == c))
          .toList(),
      weight: json['weight'] ?? 1,
    );
  }
}

class UserResponse {
  final int questionId;
  final bool answer;
  final DateTime timestamp;

  UserResponse({
    required this.questionId,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      questionId: json['questionId'],
      answer: json['answer'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class PersonalityScores {
  final double flower;
  final double jewel;
  final double shaker;
  final double stream;
  final double flowerJewel;
  final double jewelShaker;
  final double shakerStream;
  final double streamFlower;

  PersonalityScores({
    this.flower = 0,
    this.jewel = 0,
    this.shaker = 0,
    this.stream = 0,
    this.flowerJewel = 0,
    this.jewelShaker = 0,
    this.shakerStream = 0,
    this.streamFlower = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'flower': flower,
      'jewel': jewel,
      'shaker': shaker,
      'stream': stream,
      'flowerJewel': flowerJewel,
      'jewelShaker': jewelShaker,
      'shakerStream': shakerStream,
      'streamFlower': streamFlower,
    };
  }

  factory PersonalityScores.fromJson(Map<String, dynamic> json) {
    return PersonalityScores(
      flower: (json['flower'] ?? 0).toDouble(),
      jewel: (json['jewel'] ?? 0).toDouble(),
      shaker: (json['shaker'] ?? 0).toDouble(),
      stream: (json['stream'] ?? 0).toDouble(),
      flowerJewel: (json['flowerJewel'] ?? 0).toDouble(),
      jewelShaker: (json['jewelShaker'] ?? 0).toDouble(),
      shakerStream: (json['shakerStream'] ?? 0).toDouble(),
      streamFlower: (json['streamFlower'] ?? 0).toDouble(),
    );
  }
}

class PersonalityProfile {
  final PersonalityClass primaryClass;
  final PersonalityClass? secondaryClass;
  final bool isIntermediate;
  final double confidenceScore;
  final String description;
  final List<String> characteristics;

  PersonalityProfile({
    required this.primaryClass,
    this.secondaryClass,
    required this.isIntermediate,
    required this.confidenceScore,
    required this.description,
    required this.characteristics,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryClass': primaryClass.toString().split('.').last,
      'secondaryClass': secondaryClass?.toString().split('.').last,
      'isIntermediate': isIntermediate,
      'confidenceScore': confidenceScore,
      'description': description,
      'characteristics': characteristics,
    };
  }

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    return PersonalityProfile(
      primaryClass: PersonalityClass.values
          .firstWhere((e) => e.toString().split('.').last == json['primaryClass']),
      secondaryClass: json['secondaryClass'] != null
          ? PersonalityClass.values.firstWhere(
              (e) => e.toString().split('.').last == json['secondaryClass'])
          : null,
      isIntermediate: json['isIntermediate'],
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      description: json['description'],
      characteristics: List<String>.from(json['characteristics']),
    );
  }
}

class TestSession {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final List<UserResponse> responses;
  final PersonalityScores? scores;
  final PersonalityProfile? finalProfile;
  final DateTime startedAt;
  final DateTime? completedAt;

  TestSession({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    required this.responses,
    this.scores,
    this.finalProfile,
    required this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'responses': responses.map((r) => r.toJson()).toList(),
      'scores': scores?.toJson(),
      'finalProfile': finalProfile?.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TestSession.fromJson(Map<String, dynamic> json) {
    return TestSession(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      responses: (json['responses'] as List)
          .map((r) => UserResponse.fromJson(r))
          .toList(),
      scores: json['scores'] != null
          ? PersonalityScores.fromJson(json['scores'])
          : null,
      finalProfile: json['finalProfile'] != null
          ? PersonalityProfile.fromJson(json['finalProfile'])
          : null,
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
