import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/personality_test_models.dart';
import '../../services/personality_test_service.dart';
import '../../data/personality_questions.dart';
import 'personality_results_screen.dart';
import '../../utils/responsive_utils.dart';

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
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (FirebaseAuth.instance.currentUser == null) {
      // Delay navigation to avoid build errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/signup');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Veuillez vous connecter pour accéder au test de personnalité')),
        );
      });
    } else {
      _initializeApp();
    }
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

      // Save complete session to Firebase
      final saveSuccess = await _testService.saveTestSession(completedSession);

      if (saveSuccess) {
        // Also save a summary result for analytics
        await _testService.saveTestSummary(completedSession);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Résultats sauvegardés avec succès!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show warning if save failed but still proceed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('⚠️ Erreur de sauvegarde, mais résultats disponibles'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

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
              ? _buildLoadingInterface(context)
              : _errorMessage != null
                  ? _buildErrorInterface(context)
                  : _isTestStarted
                      ? _buildTestInterface(context)
                      : _buildIntroInterface(context),
        ),
      ),
    );
  }

  Widget _buildLoadingInterface(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.03,
            mobileLandscape: 0.02,
            tabletPortrait: 0.035,
            tabletLandscape: 0.025,
          )),
          Text(
            'Chargement des questions...',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.04,
                mobileLandscape: 0.032,
                tabletPortrait: 0.035,
                tabletLandscape: 0.03,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorInterface(BuildContext context) {
    return Padding(
      padding: context.responsivePadding(
        mobilePortrait: 0.06,
        mobileLandscape: 0.05,
        tabletPortrait: 0.07,
        tabletLandscape: 0.06,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.responsiveFontSize(
              mobilePortrait: 0.15,
              mobileLandscape: 0.12,
              tabletPortrait: 0.12,
              tabletLandscape: 0.1,
              desktopPortrait: 0.1,
              desktopLandscape: 0.08,
            ),
            color: Colors.red[400],
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.03,
            mobileLandscape: 0.02,
            tabletPortrait: 0.035,
            tabletLandscape: 0.025,
          )),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.05,
                mobileLandscape: 0.04,
                tabletPortrait: 0.045,
                tabletLandscape: 0.038,
                desktopPortrait: 0.04,
                desktopLandscape: 0.035,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.02,
            mobileLandscape: 0.015,
            tabletPortrait: 0.025,
            tabletLandscape: 0.018,
          )),
          Text(
            _errorMessage ?? 'Une erreur est survenue',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.035,
                mobileLandscape: 0.028,
                tabletPortrait: 0.03,
                tabletLandscape: 0.025,
                desktopPortrait: 0.025,
                desktopLandscape: 0.02,
              ),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.04,
            mobileLandscape: 0.03,
            tabletPortrait: 0.045,
            tabletLandscape: 0.035,
          )),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loadQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4FFF),
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Réessayer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.04,
                        mobileLandscape: 0.032,
                        tabletPortrait: 0.035,
                        tabletLandscape: 0.03,
                        desktopPortrait: 0.03,
                        desktopLandscape: 0.025,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: context.responsiveSpacing(
                mobilePortrait: 0.04,
                mobileLandscape: 0.035,
                tabletPortrait: 0.045,
                tabletLandscape: 0.04,
              )),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Retour',
                    style: TextStyle(
                      color: const Color(0xFF8A4FFF),
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.04,
                        mobileLandscape: 0.032,
                        tabletPortrait: 0.035,
                        tabletLandscape: 0.03,
                        desktopPortrait: 0.03,
                        desktopLandscape: 0.025,
                      ),
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

  Widget _buildTestInterface(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Padding(
      padding: context.responsivePadding(
        mobilePortrait: 0.06,
        mobileLandscape: 0.05,
        tabletPortrait: 0.07,
        tabletLandscape: 0.06,
      ),
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
                iconSize: context.responsiveFontSize(
                  mobilePortrait: 0.06,
                  mobileLandscape: 0.05,
                  tabletPortrait: 0.055,
                  tabletLandscape: 0.048,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} sur ${_questions.length}',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          mobilePortrait: 0.04,
                          mobileLandscape: 0.032,
                          tabletPortrait: 0.035,
                          tabletLandscape: 0.03,
                          desktopPortrait: 0.03,
                          desktopLandscape: 0.025,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(
                        height: context.responsiveSpacing(
                      mobilePortrait: 0.01,
                      mobileLandscape: 0.005,
                      tabletPortrait: 0.012,
                      tabletLandscape: 0.008,
                    )),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8A4FFF)),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showExitDialog(),
                icon: const Icon(Icons.close),
                iconSize: context.responsiveFontSize(
                  mobilePortrait: 0.06,
                  mobileLandscape: 0.05,
                  tabletPortrait: 0.055,
                  tabletLandscape: 0.048,
                ),
              ),
            ],
          ),

          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.04,
            mobileLandscape: 0.02,
            tabletPortrait: 0.045,
            tabletLandscape: 0.025,
          )),

          // Question card
          Expanded(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: context.responsivePadding(
                  mobilePortrait: 0.06,
                  mobileLandscape: 0.05,
                  tabletPortrait: 0.07,
                  tabletLandscape: 0.06,
                ),
                child: Column(
                  children: [
                    const Spacer(),

                    // Question text
                    Text(
                      currentQuestion.question,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          mobilePortrait: 0.05,
                          mobileLandscape: 0.04,
                          tabletPortrait: 0.045,
                          tabletLandscape: 0.038,
                          desktopPortrait: 0.04,
                          desktopLandscape: 0.035,
                        ),
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
                                backgroundColor:  const Color(0xFF8A4FFF),
                                padding: EdgeInsets.symmetric(
                                  vertical: context.responsiveSpacing(
                                    mobilePortrait: 0.025,
                                    mobileLandscape: 0.02,
                                    tabletPortrait: 0.03,
                                    tabletLandscape: 0.025,
                                  ),
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
                                    size: context.responsiveFontSize(
                                      mobilePortrait: 0.06,
                                      mobileLandscape: 0.05,
                                      tabletPortrait: 0.055,
                                      tabletLandscape: 0.048,
                                    ),
                                  ),
                                  SizedBox(
                                      width: context.responsiveSpacing(
                                    mobilePortrait: 0.02,
                                    mobileLandscape: 0.015,
                                    tabletPortrait: 0.025,
                                    tabletLandscape: 0.018,
                                  )),
                                  Text(
                                    'Oui',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.responsiveFontSize(
                                        mobilePortrait: 0.045,
                                        mobileLandscape: 0.035,
                                        tabletPortrait: 0.04,
                                        tabletLandscape: 0.033,
                                        desktopPortrait: 0.035,
                                        desktopLandscape: 0.03,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              width: context.responsiveSpacing(
                            mobilePortrait: 0.04,
                            mobileLandscape: 0.035,
                            tabletPortrait: 0.045,
                            tabletLandscape: 0.04,
                          )),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5722),
                                padding: EdgeInsets.symmetric(
                                  vertical: context.responsiveSpacing(
                                    mobilePortrait: 0.025,
                                    mobileLandscape: 0.02,
                                    tabletPortrait: 0.03,
                                    tabletLandscape: 0.025,
                                  ),
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
                                    size: context.responsiveFontSize(
                                      mobilePortrait: 0.06,
                                      mobileLandscape: 0.05,
                                      tabletPortrait: 0.055,
                                      tabletLandscape: 0.048,
                                    ),
                                  ),
                                  SizedBox(
                                      width: context.responsiveSpacing(
                                    mobilePortrait: 0.02,
                                    mobileLandscape: 0.015,
                                    tabletPortrait: 0.025,
                                    tabletLandscape: 0.018,
                                  )),
                                  Text(
                                    'Non',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.responsiveFontSize(
                                        mobilePortrait: 0.045,
                                        mobileLandscape: 0.035,
                                        tabletPortrait: 0.04,
                                        tabletLandscape: 0.033,
                                        desktopPortrait: 0.035,
                                        desktopLandscape: 0.03,
                                      ),
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
                            AlwaysStoppedAnimation<Color>( Color(0xFF8A4FFF)),
                      ),
                      SizedBox(
                          height: context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      )),
                      Text(
                        'Traitement de votre réponse...',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.035,
                            mobileLandscape: 0.028,
                            tabletPortrait: 0.03,
                            tabletLandscape: 0.025,
                            desktopPortrait: 0.025,
                            desktopLandscape: 0.02,
                          ),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],

                    SizedBox(
                        height: context.responsiveSpacing(
                      mobilePortrait: 0.02,
                      mobileLandscape: 0.015,
                      tabletPortrait: 0.025,
                      tabletLandscape: 0.018,
                    )),
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

  Widget _buildIntroInterface(BuildContext context) {
    return Padding(
      padding: context.responsivePadding(
        mobilePortrait: 0.06,
        mobileLandscape: 0.05,
        tabletPortrait: 0.07,
        tabletLandscape: 0.06,
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                iconSize: context.responsiveFontSize(
                  mobilePortrait: 0.06,
                  mobileLandscape: 0.05,
                  tabletPortrait: 0.055,
                  tabletLandscape: 0.048,
                ),
              ),
              Expanded(
                child: Text(
                  'Test de Personnalité',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.06,
                      mobileLandscape: 0.048,
                      tabletPortrait: 0.05,
                      tabletLandscape: 0.042,
                      desktopPortrait: 0.04,
                      desktopLandscape: 0.035,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                  width: context.responsiveSpacing(
                mobilePortrait: 0.06,
                mobileLandscape: 0.05,
                tabletPortrait: 0.07,
                tabletLandscape: 0.06,
              )),
            ],
          ),

          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.04,
            mobileLandscape: 0.02,
            tabletPortrait: 0.045,
            tabletLandscape: 0.025,
          )),

          // Main content card - Use Flexible instead of Expanded to prevent overflow
          Flexible(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: context.responsivePadding(
                  mobilePortrait: 0.06,
                  mobileLandscape: 0.05,
                  tabletPortrait: 0.07,
                  tabletLandscape: 0.06,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Title and description
                      Text(
                        'Découvrez votre profil psychotechnique',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.05,
                            mobileLandscape: 0.04,
                            tabletPortrait: 0.045,
                            tabletLandscape: 0.038,
                            desktopPortrait: 0.035,
                            desktopLandscape: 0.03,
                          ),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                          height: context.responsiveSpacing(
                        mobilePortrait: 0.03,
                        mobileLandscape: 0.02,
                        tabletPortrait: 0.035,
                        tabletLandscape: 0.025,
                      )),

                      Container(
                        width: context.responsiveWidth(
                          mobilePortrait: 0.2,
                          mobileLandscape: 0.18,
                          tabletPortrait: 0.18,
                          tabletLandscape: 0.15,
                          desktopPortrait: 0.15,
                          desktopLandscape: 0.12,
                        ),
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A4FFF), Color(0xFF8A4FFF)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      SizedBox(
                          height: context.responsiveSpacing(
                        mobilePortrait: 0.03,
                        mobileLandscape: 0.02,
                        tabletPortrait: 0.035,
                        tabletLandscape: 0.025,
                      )),

                      Text(
                        'Ce test vous permettra de découvrir votre type de personnalité parmi 8 profils distincts. Répondez honnêtement aux ${_questions.length} questions${_questions.isNotEmpty ? ' chargées depuis Firebase' : ''} pour obtenir un résultat précis.',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.04,
                            mobileLandscape: 0.032,
                            tabletPortrait: 0.035,
                            tabletLandscape: 0.03,
                            desktopPortrait: 0.03,
                            desktopLandscape: 0.025,
                          ),
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                          height: context.responsiveSpacing(
                        mobilePortrait: 0.04,
                        mobileLandscape: 0.02,
                        tabletPortrait: 0.045,
                        tabletLandscape: 0.025,
                      )),

                      // User info
                      if (_currentUser != null) ...[
                        Container(
                          padding: context.responsivePadding(
                            mobilePortrait: 0.04,
                            mobileLandscape: 0.035,
                            tabletPortrait: 0.045,
                            tabletLandscape: 0.04,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Informations du test',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    mobilePortrait: 0.04,
                                    mobileLandscape: 0.032,
                                    tabletPortrait: 0.035,
                                    tabletLandscape: 0.03,
                                    desktopPortrait: 0.03,
                                    desktopLandscape: 0.025,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              SizedBox(
                                  height: context.responsiveSpacing(
                                mobilePortrait: 0.02,
                                mobileLandscape: 0.01,
                                tabletPortrait: 0.025,
                                tabletLandscape: 0.015,
                              )),
                              Text(
                                'Nom: ${_currentUser!.displayName ?? 'Non défini'}',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    mobilePortrait: 0.035,
                                    mobileLandscape: 0.028,
                                    tabletPortrait: 0.03,
                                    tabletLandscape: 0.025,
                                    desktopPortrait: 0.025,
                                    desktopLandscape: 0.02,
                                  ),
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(
                                  height: context.responsiveSpacing(
                                mobilePortrait: 0.01,
                                mobileLandscape: 0.005,
                                tabletPortrait: 0.012,
                                tabletLandscape: 0.008,
                              )),
                              Text(
                                'Email: ${_currentUser!.email ?? 'Non défini'}',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    mobilePortrait: 0.035,
                                    mobileLandscape: 0.028,
                                    tabletPortrait: 0.03,
                                    tabletLandscape: 0.025,
                                    desktopPortrait: 0.025,
                                    desktopLandscape: 0.02,
                                  ),
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(
                                  height: context.responsiveSpacing(
                                mobilePortrait: 0.01,
                                mobileLandscape: 0.005,
                                tabletPortrait: 0.012,
                                tabletLandscape: 0.008,
                              )),
                              Text(
                                'Les résultats seront sauvegardés dans votre profil',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    mobilePortrait: 0.03,
                                    mobileLandscape: 0.025,
                                    tabletPortrait: 0.028,
                                    tabletLandscape: 0.022,
                                    desktopPortrait: 0.02,
                                    desktopLandscape: 0.018,
                                  ),
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: context.responsiveSpacing(
                          mobilePortrait: 0.04,
                          mobileLandscape: 0.02,
                          tabletPortrait: 0.045,
                          tabletLandscape: 0.025,
                        )),
                      ],

                      // Add responsive spacing instead of Spacer
                      SizedBox(
                          height: context.responsiveSpacing(
                        mobilePortrait: 0.04,
                        mobileLandscape: 0.02,
                        tabletPortrait: 0.045,
                        tabletLandscape: 0.025,
                      )),

                      // Action buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A4FFF),
                                padding: EdgeInsets.symmetric(
                                  vertical: context.responsiveSpacing(
                                    mobilePortrait: 0.02,
                                    mobileLandscape: 0.015,
                                    tabletPortrait: 0.025,
                                    tabletLandscape: 0.018,
                                  ),
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
                                      fontSize: context.responsiveFontSize(
                                        mobilePortrait: 0.04,
                                        mobileLandscape: 0.032,
                                        tabletPortrait: 0.035,
                                        tabletLandscape: 0.03,
                                        desktopPortrait: 0.03,
                                        desktopLandscape: 0.025,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                      width: context.responsiveSpacing(
                                    mobilePortrait: 0.02,
                                    mobileLandscape: 0.015,
                                    tabletPortrait: 0.025,
                                    tabletLandscape: 0.018,
                                  )),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: context.responsiveFontSize(
                                      mobilePortrait: 0.05,
                                      mobileLandscape: 0.04,
                                      tabletPortrait: 0.045,
                                      tabletLandscape: 0.038,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height: context.responsiveSpacing(
                            mobilePortrait: 0.02,
                            mobileLandscape: 0.01,
                            tabletPortrait: 0.025,
                            tabletLandscape: 0.015,
                          )),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Retour à l\'accueil',
                                style: TextStyle(
                                  color: const Color(0xFF8A4FFF),
                                  fontSize: context.responsiveFontSize(
                                    mobilePortrait: 0.035,
                                    mobileLandscape: 0.028,
                                    tabletPortrait: 0.03,
                                    tabletLandscape: 0.025,
                                    desktopPortrait: 0.025,
                                    desktopLandscape: 0.02,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
