import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/personality_test_models.dart';
import '../../services/personality_test_service.dart';
import '../../data/personality_questions.dart';
import 'personality_results_screen.dart';

class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  final PersonalityTestService _testService = PersonalityTestService();

  // Test data
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  List<UserResponse> _responses = [];
  TestSession? _testSession;

  // UI state
  bool _isTestStarted = false;
  bool _isLoading = false;
  bool _isLoadingQuestions = true;
  String? _errorMessage;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadQuestions();
    _initializeTest();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoadingQuestions = true;
        _errorMessage = null;
      });

      // Initialize Firebase data if needed
      await _testService.initializeFirebaseData();

      // Load questions from Firebase
      final questions = await _testService.getAllQuestions();

      setState(() {
        _questions = questions;
        _isLoadingQuestions = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des questions: $e';
        _isLoadingQuestions = false;
        // Fallback to local questions
        _questions = personalityQuestions;
      });
    }
  }

  void _initializeTest() {
    _testSession = _testService.createTestSession(
      userName: _currentUser?.displayName ?? 'Anonymous',
      userEmail: _currentUser?.email ?? '',
    );
  }

  void _startTest() {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune question disponible. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isTestStarted = true;
      _currentQuestionIndex = 0;
      _responses = [];
    });

    if (_testSession != null) {
      _testSession = TestSession(
        id: _testSession!.id,
        userId: _testSession!.userId,
        userName: _testSession!.userName,
        userEmail: _testSession!.userEmail,
        responses: [],
        startedAt: DateTime.now(),
      );
    }
  }

  Future<void> _answerQuestion(bool answer) async {
    if (_testSession == null) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final response = UserResponse(
      questionId: currentQuestion.id,
      answer: answer,
      timestamp: DateTime.now(),
    );

    setState(() {
      _responses.add(response);
      _isLoading = true;
    });

    // Save individual response
    if (_currentUser != null) {
      await _testService.saveIndividualResponse(
        _currentUser!.email ?? '',
        _testSession!.id,
        response,
      );
    }

    // Move to next question or complete test
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isLoading = false;
      });
    } else {
      await _completeTest();
    }
  }

  Future<void> _completeTest() async {
    if (_testSession == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate results
      final results = _testService.processTestResults(_responses, _questions);
      final scores = results['scores'] as PersonalityScores;
      final profile = results['profile'] as PersonalityProfile;

      // Update test session
      final completedSession = TestSession(
        id: _testSession!.id,
        userId: _testSession!.userId,
        userName: _testSession!.userName,
        userEmail: _testSession!.userEmail,
        responses: _responses,
        scores: scores,
        finalProfile: profile,
        startedAt: _testSession!.startedAt,
        completedAt: DateTime.now(),
      );

      // Save complete session
      await _testService.saveTestSession(completedSession);

      // Navigate to results
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalityResultsScreen(
              testSession: completedSession,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du traitement des résultats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
          ),
        ),
        child: SafeArea(
          child: _isLoadingQuestions
              ? _buildLoadingInterface(size, isSmallScreen)
              : _errorMessage != null
                  ? _buildErrorInterface(size, isSmallScreen)
                  : _isTestStarted
                      ? _buildTestInterface(size, isSmallScreen)
                      : _buildIntroInterface(size, isSmallScreen),
        ),
      ),
    );
  }

  Widget _buildLoadingInterface(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            'Chargement des questions...',
            style: TextStyle(
              fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorInterface(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: size.width * 0.15,
            color: Colors.red[400],
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: size.width * (isSmallScreen ? 0.05 : 0.04),
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            _errorMessage ?? 'Une erreur est survenue',
            style: TextStyle(
              fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.04),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loadQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Réessayer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Retour',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestInterface(Size size, bool isSmallScreen) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        children: [
          // Header with progress
          Row(
            children: [
              IconButton(
                onPressed: _currentQuestionIndex > 0
                    ? () {
                        setState(() {
                          _currentQuestionIndex--;
                          _responses.removeLast();
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
                iconSize: size.width * 0.06,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} sur ${_questions.length}',
                      style: TextStyle(
                        fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50)),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showExitDialog(),
                icon: const Icon(Icons.close),
                iconSize: size.width * 0.06,
              ),
            ],
          ),

          SizedBox(height: size.height * 0.04),

          // Question card
          Expanded(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.06),
                child: Column(
                  children: [
                    const Spacer(),

                    // Question text
                    Text(
                      currentQuestion.question,
                      style: TextStyle(
                        fontSize: size.width * (isSmallScreen ? 0.05 : 0.04),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Answer buttons
                    if (!_isLoading) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.025,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: size.width *
                                        (isSmallScreen ? 0.06 : 0.05),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    'Oui',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.045 : 0.035),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5722),
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.025,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: size.width *
                                        (isSmallScreen ? 0.06 : 0.05),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    'Non',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.045 : 0.035),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Traitement de votre réponse...',
                        style: TextStyle(
                          fontSize:
                              size.width * (isSmallScreen ? 0.035 : 0.025),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quitter le test'),
          content: const Text(
              'Êtes-vous sûr de vouloir quitter le test ? Votre progression sera perdue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuer le test'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Quitter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntroInterface(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                iconSize: size.width * 0.06,
              ),
              Expanded(
                child: Text(
                  'Test de Personnalité',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: size.width * 0.06),
            ],
          ),

          SizedBox(height: size.height * 0.04),

          // Main content card
          Expanded(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.06),
                child: Column(
                  children: [
                    // Title and description
                    Text(
                      'Découvrez votre profil psychotechnique',
                      style: TextStyle(
                        fontSize: size.width * (isSmallScreen ? 0.05 : 0.035),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: size.height * 0.03),

                    Container(
                      width: size.width * 0.2,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    Text(
                      'Ce test vous permettra de découvrir votre type de personnalité parmi 8 profils distincts. Répondez honnêtement aux ${_questions.length} questions${_questions.isNotEmpty ? ' chargées depuis Firebase' : ''} pour obtenir un résultat précis.',
                      style: TextStyle(
                        fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: size.height * 0.04),

                    // User info
                    if (_currentUser != null) ...[
                      Container(
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Informations du test',
                              style: TextStyle(
                                fontSize:
                                    size.width * (isSmallScreen ? 0.04 : 0.03),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Text(
                              'Nom: ${_currentUser!.displayName ?? 'Non défini'}',
                              style: TextStyle(
                                fontSize: size.width *
                                    (isSmallScreen ? 0.035 : 0.025),
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              'Email: ${_currentUser!.email ?? 'Non défini'}',
                              style: TextStyle(
                                fontSize: size.width *
                                    (isSmallScreen ? 0.035 : 0.025),
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              'Les résultats seront sauvegardés dans votre profil',
                              style: TextStyle(
                                fontSize:
                                    size.width * (isSmallScreen ? 0.03 : 0.02),
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                    ],

                    const Spacer(),

                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startTest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Commencer le Test',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width *
                                        (isSmallScreen ? 0.04 : 0.03),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: size.width *
                                      (isSmallScreen ? 0.05 : 0.04),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Retour à l\'accueil',
                              style: TextStyle(
                                color: const Color(0xFF4CAF50),
                                fontSize: size.width *
                                    (isSmallScreen ? 0.035 : 0.025),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
