import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/personality_test_models.dart';
import '../data/personality_questions.dart';

class PersonalityTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new test session
  TestSession createTestSession({String? userName, String? userEmail}) {
    final user = _auth.currentUser;
    final sessionId =
        'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

    return TestSession(
      id: sessionId,
      userId: user?.uid,
      userName: userName ?? user?.displayName ?? 'Anonymous',
      userEmail: userEmail ?? user?.email ?? '',
      responses: [],
      startedAt: DateTime.now(),
    );
  }

  /// Calculates personality scores based on responses
  PersonalityScores calculateScores(
      List<UserResponse> responses, List<Question> questions) {
    double flower = 0;
    double jewel = 0;
    double shaker = 0;
    double stream = 0;
    double flowerJewel = 0;
    double jewelShaker = 0;
    double shakerStream = 0;
    double streamFlower = 0;

    for (final response in responses) {
      final question = questions.firstWhere(
        (q) => q.id == response.questionId,
        orElse: () =>
            throw Exception('Question not found: ${response.questionId}'),
      );

      final isCorrectAnswer = response.answer == question.expectedAnswer;
      if (!isCorrectAnswer) continue;

      // Attribution des points selon les classes de la question
      for (final className in question.classes) {
        switch (className) {
          case PersonalityClass.flower:
            flower += 1;
            break;
          case PersonalityClass.jewel:
            jewel += 1;
            break;
          case PersonalityClass.shaker:
            shaker += 1;
            break;
          case PersonalityClass.stream:
            stream += 1;
            break;
          case PersonalityClass.flowerJewel:
            flowerJewel += 1;
            // Contribue aussi aux classes de base
            flower += 0.5;
            jewel += 0.5;
            break;
          case PersonalityClass.jewelShaker:
            jewelShaker += 1;
            jewel += 0.5;
            shaker += 0.5;
            break;
          case PersonalityClass.shakerStream:
            shakerStream += 1;
            shaker += 0.5;
            stream += 0.5;
            break;
          case PersonalityClass.streamFlower:
            streamFlower += 1;
            stream += 0.5;
            flower += 0.5;
            break;
        }
      }
    }

    return PersonalityScores(
      flower: flower,
      jewel: jewel,
      shaker: shaker,
      stream: stream,
      flowerJewel: flowerJewel,
      jewelShaker: jewelShaker,
      shakerStream: shakerStream,
      streamFlower: streamFlower,
    );
  }

  /// Determines the personality profile based on scores
  PersonalityProfile determineProfile(PersonalityScores scores) {
    // Scores des classes de base
    final baseScores = [
      {'class': PersonalityClass.flower, 'score': scores.flower},
      {'class': PersonalityClass.jewel, 'score': scores.jewel},
      {'class': PersonalityClass.shaker, 'score': scores.shaker},
      {'class': PersonalityClass.stream, 'score': scores.stream},
    ];

    // Trier par score décroissant
    baseScores.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // Logique de détermination du profil
    PersonalityClass primaryClass;
    PersonalityClass? secondaryClass;
    bool isIntermediate = false;
    double confidenceScore = 0;

    // Get the top scores
    final firstHighest = baseScores[0];
    final secondHighest = baseScores[1];
    final thirdHighest = baseScores.length > 2 ? baseScores[2] : null;
  
    final firstScore = firstHighest['score'] as double;
    final secondScore = secondHighest['score'] as double;
    final thirdScore = thirdHighest != null ? thirdHighest['score'] as double : 0.0;
  
    final firstClass = firstHighest['class'] as PersonalityClass;
    final secondClass = secondHighest['class'] as PersonalityClass;
    final thirdClass = thirdHighest != null ? thirdHighest['class'] as PersonalityClass : null;

    // Check if the top two scores are similar (difference <= 0.5)
    final areTopTwoSimilar = (firstScore - secondScore).abs() <= 0.5 && secondScore > 0;
  
    // Check if the second and third scores are similar
    final areSecondThirdSimilar = thirdScore > 0 && (secondScore - thirdScore).abs() <= 0.5;

    // If top two scores are similar, try to find an intermediate class
    if (areTopTwoSimilar) {
      // Try to find an intermediate class for the top two scores
      PersonalityClass? intermediateClass = _findIntermediateClass(firstClass, secondClass);
      
      if (intermediateClass != null) {
        // Found a valid intermediate class
        primaryClass = intermediateClass;
        isIntermediate = true;
        confidenceScore = (firstScore / 8) * 100;
      } else if (areSecondThirdSimilar) {
        // If no intermediate class for top two, and second and third are similar,
        // try to find an intermediate class for second and third
        intermediateClass = _findIntermediateClass(secondClass, thirdClass!);
        
        if (intermediateClass != null) {
          primaryClass = intermediateClass;
          isIntermediate = true;
          confidenceScore = (secondScore / 8) * 100;
        } else {
          // No intermediate classes found, use the highest score
          primaryClass = firstClass;
          
          // If second score is significant (at least 60% of first score)
          if (secondScore > 0 && (secondScore / firstScore) >= 0.6) {
            secondaryClass = secondClass;
          }
          
          confidenceScore = (firstScore / 8) * 100;
        }
      } else {
        // No intermediate class for top two, and second and third are not similar
        // Use the highest score with the second as secondary if significant
        primaryClass = firstClass;
        
        if (secondScore > 0 && (secondScore / firstScore) >= 0.6) {
          secondaryClass = secondClass;
        }
        
        confidenceScore = (firstScore / 8) * 100;
      }
    } else {
      // Top two scores are not similar, use the highest score
      primaryClass = firstClass;
      
      // If second score is significant (at least 60% of first score)
      if (secondScore > 0 && (secondScore / firstScore) >= 0.6) {
        secondaryClass = secondClass;
      }
      
      confidenceScore = (firstScore / 8) * 100;
    }

    // Obtenir la description et les caractéristiques
    final profileData = personalityDescriptions[primaryClass]!;

    return PersonalityProfile(
      primaryClass: primaryClass,
      secondaryClass: secondaryClass,
      isIntermediate: isIntermediate,
      confidenceScore: confidenceScore.clamp(0, 100),
      description: profileData['description'] as String,
      characteristics: List<String>.from(profileData['characteristics']),
    );
  }

  /// Helper method to find an intermediate class for two personality classes
  PersonalityClass? _findIntermediateClass(PersonalityClass class1, PersonalityClass class2) {
    // Check all possible combinations
    if ((class1 == PersonalityClass.flower && class2 == PersonalityClass.jewel) ||
        (class1 == PersonalityClass.jewel && class2 == PersonalityClass.flower)) {
      return PersonalityClass.flowerJewel;
    } else if ((class1 == PersonalityClass.jewel && class2 == PersonalityClass.shaker) ||
               (class1 == PersonalityClass.shaker && class2 == PersonalityClass.jewel)) {
      return PersonalityClass.jewelShaker;
    } else if ((class1 == PersonalityClass.shaker && class2 == PersonalityClass.stream) ||
               (class1 == PersonalityClass.stream && class2 == PersonalityClass.shaker)) {
      return PersonalityClass.shakerStream;
    } else if ((class1 == PersonalityClass.stream && class2 == PersonalityClass.flower) ||
               (class1 == PersonalityClass.flower && class2 == PersonalityClass.stream)) {
      return PersonalityClass.streamFlower;
    }
  
    // No intermediate class found for this combination
    return null;
  }

  /// Processes test results and returns scores and profile
  Map<String, dynamic> processTestResults(
      List<UserResponse> responses, List<Question> questions) {
    final scores = calculateScores(responses, questions);
    final profile = determineProfile(scores);

    return {
      'scores': scores,
      'profile': profile,
    };
  }

  /// Saves test session to Firestore
  Future<bool> saveTestSession(TestSession session) async {
    try {
      await _firestore
          .collection('personality_tests')
          .doc(session.id)
          .set(session.toJson());
      return true;
    } catch (e) {
      print('Error saving test session: $e');
      return false;
    }
  }

  /// Saves a summary of test results for analytics
  Future<bool> saveTestSummary(TestSession session) async {
    try {
      final summary = {
        'sessionId': session.id,
        'userId': session.userId,
        'userEmail': session.userEmail,
        'userName': session.userName,
        'primaryPersonality':
            session.finalProfile?.primaryClass.toString().split('.').last,
        'secondaryPersonality':
            session.finalProfile?.secondaryClass?.toString().split('.').last,
        'isIntermediate': session.finalProfile?.isIntermediate ?? false,
        'confidenceScore': session.finalProfile?.confidenceScore ?? 0,
        'totalQuestions': session.responses.length,
        'testDuration':
            session.completedAt?.difference(session.startedAt).inMinutes ?? 0,
        'completedAt': session.completedAt?.toIso8601String(),
        'scores': session.scores?.toJson(),
        'deviceInfo': {
          'platform': 'flutter_mobile',
          'timestamp': DateTime.now().toIso8601String(),
        }
      };

      await _firestore
          .collection('personality_test_summaries')
          .doc(session.id)
          .set(summary);

      return true;
    } catch (e) {
      print('Error saving test summary: $e');
      return false;
    }
  }

  /// Saves individual response to Firestore
  Future<bool> saveIndividualResponse(
    String userEmail,
    String sessionId,
    UserResponse response,
  ) async {
    try {
      await _firestore
          .collection('personality_responses')
          .doc('${sessionId}_${response.questionId}')
          .set({
        'userEmail': userEmail,
        'sessionId': sessionId,
        ...response.toJson(),
      });
      return true;
    } catch (e) {
      print('Error saving individual response: $e');
      return false;
    }
  }

  /// Gets user's test history
  Future<List<TestSession>> getUserTestHistory(String userEmail) async {
    try {
      final querySnapshot = await _firestore
          .collection('personality_tests')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('startedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TestSession.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user test history: $e');
      return [];
    }
  }

  /// Gets all questions from Firebase
  Future<List<Question>> getAllQuestions() async {
    try {
      final querySnapshot =
          await _firestore.collection('questions').orderBy('id').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          id: data['id'],
          question: data['question'],
          expectedAnswer: data['expectedAnswer'],
          classes: (data['classes'] as List)
              .map((className) => _parsePersonalityClass(className))
              .toList(),
          weight: data['weight'] ?? 1,
        );
      }).toList();
    } catch (e) {
      print('Error getting questions from Firebase: $e');
      // Fallback to local questions if Firebase fails
      return personalityQuestions;
    }
  }

  /// Helper method to parse personality class from string
  PersonalityClass _parsePersonalityClass(String className) {
    switch (className.toLowerCase()) {
      case 'flower':
        return PersonalityClass.flower;
      case 'jewel':
        return PersonalityClass.jewel;
      case 'shaker':
        return PersonalityClass.shaker;
      case 'stream':
        return PersonalityClass.stream;
      case 'flower-jewel':
        return PersonalityClass.flowerJewel;
      case 'jewel-shaker':
        return PersonalityClass.jewelShaker;
      case 'shaker-stream':
        return PersonalityClass.shakerStream;
      case 'stream-flower':
        return PersonalityClass.streamFlower;
      default:
        throw Exception('Unknown personality class: $className');
    }
  }

  /// Initialize Firebase data (questions, families, etc.)
  Future<bool> initializeFirebaseData() async {
    try {
      // Check if questions already exist
      final questionsSnapshot =
          await _firestore.collection('questions').limit(1).get();

      if (questionsSnapshot.docs.isEmpty) {
        print('Initializing Firebase data...');
        await _initializeQuestions();
        await _initializePersonalityFamilies();
        print('Firebase data initialized successfully!');
      } else {
        print('Firebase data already exists');
      }

      return true;
    } catch (e) {
      print('Error initializing Firebase data: $e');
      return false;
    }
  }

  /// Initialize questions in Firebase
  Future<void> _initializeQuestions() async {
    for (final question in personalityQuestions) {
      await _firestore.collection('questions').doc(question.id.toString()).set({
        'id': question.id,
        'question': question.question,
        'expectedAnswer': question.expectedAnswer,
        'classes':
            question.classes.map((c) => c.toString().split('.').last).toList(),
        'weight': question.weight,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Initialize personality families in Firebase
  Future<void> _initializePersonalityFamilies() async {
    final families = [
      {
        'id': 'flower',
        'name': 'Flower',
        'description': 'Personnalité émotionnelle, créative et empathique',
        'characteristics': ['Émotionnel', 'Créatif', 'Empathique', 'Intuitif'],
        'color': 0xFFE91E63,
      },
      {
        'id': 'jewel',
        'name': 'Jewel',
        'description': 'Personnalité structurée, analytique et méthodique',
        'characteristics': ['Structuré', 'Analytique', 'Méthodique', 'Logique'],
        'color': 0xFF2196F3,
      },
      {
        'id': 'shaker',
        'name': 'Shaker',
        'description': 'Personnalité dynamique, aventurière et spontanée',
        'characteristics': ['Dynamique', 'Aventurier', 'Spontané', 'Énergique'],
        'color': 0xFFFF9800,
      },
      {
        'id': 'stream',
        'name': 'Stream',
        'description': 'Personnalité harmonieuse, collaborative et adaptable',
        'characteristics': [
          'Harmonieux',
          'Collaboratif',
          'Adaptable',
          'Diplomate'
        ],
        'color': 0xFF4CAF50,
      },
    ];

    for (final family in families) {
      await _firestore
          .collection('personality_families')
          .doc(family['id'] as String)
          .set(family);
    }
  }

  /// Gets personality class info
  Map<String, dynamic>? getPersonalityClassInfo(
      PersonalityClass personalityClass) {
    return personalityDescriptions[personalityClass];
  }

  /// Gets user test statistics
  Future<Map<String, dynamic>> getUserTestStatistics(String userEmail) async {
    try {
      final summariesSnapshot = await _firestore
          .collection('personality_test_summaries')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('completedAt', descending: true)
          .get();

      final summaries =
          summariesSnapshot.docs.map((doc) => doc.data()).toList();

      if (summaries.isEmpty) {
        return {
          'totalTests': 0,
          'lastTestDate': null,
          'mostCommonPersonality': null,
          'averageConfidence': 0.0,
          'personalityHistory': [],
        };
      }

      // Calculate statistics
      final totalTests = summaries.length;
      final lastTestDate = summaries.first['completedAt'];

      // Find most common personality
      final personalityCount = <String, int>{};
      double totalConfidence = 0;

      for (final summary in summaries) {
        final personality = summary['primaryPersonality'] as String?;
        if (personality != null) {
          personalityCount[personality] =
              (personalityCount[personality] ?? 0) + 1;
        }
        totalConfidence +=
            (summary['confidenceScore'] as num?)?.toDouble() ?? 0;
      }

      final mostCommonPersonality = personalityCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final averageConfidence = totalConfidence / totalTests;

      return {
        'totalTests': totalTests,
        'lastTestDate': lastTestDate,
        'mostCommonPersonality': mostCommonPersonality,
        'averageConfidence': averageConfidence,
        'personalityHistory': summaries
            .map((s) => {
                  'personality': s['primaryPersonality'],
                  'confidence': s['confidenceScore'],
                  'date': s['completedAt'],
                  'isIntermediate': s['isIntermediate'],
                })
            .toList(),
      };
    } catch (e) {
      print('Error getting user test statistics: $e');
      return {
        'totalTests': 0,
        'lastTestDate': null,
        'mostCommonPersonality': null,
        'averageConfidence': 0.0,
        'personalityHistory': [],
      };
    }
  }
}



