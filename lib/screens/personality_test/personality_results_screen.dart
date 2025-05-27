import 'package:flutter/material.dart';
import '../../models/personality_test_models.dart';
import '../../data/personality_questions.dart';

class PersonalityResultsScreen extends StatelessWidget {
  final TestSession testSession;

  const PersonalityResultsScreen({
    super.key,
    required this.testSession,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final profile = testSession.finalProfile!;
    final scores = testSession.scores!;
    final profileData = personalityDescriptions[profile.primaryClass]!;

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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.06),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/accueil',
                        (route) => false,
                      ),
                      icon: const Icon(Icons.home),
                      iconSize: size.width * 0.06,
                    ),
                    Expanded(
                      child: Text(
                        'Résultats du Test',
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

                SizedBox(height: size.height * 0.03),

                // Main result card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(profileData['color'] as int),
                          Color(profileData['color'] as int).withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(size.width * 0.06),
                    child: Column(
                      children: [
                        // Personality type icon/badge
                        Container(
                          width: size.width * 0.2,
                          height: size.width * 0.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          child: Center(
                            child: Text(
                              _getPersonalityIcon(profile.primaryClass),
                              style: TextStyle(
                                fontSize: size.width * 0.1,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.02),

                        // Personality name
                        Text(
                          profileData['name'] as String,
                          style: TextStyle(
                            fontSize: size.width * (isSmallScreen ? 0.06 : 0.05),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: size.height * 0.01),

                        // Confidence score
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                            vertical: size.height * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Fiabilité: ${profile.confidenceScore.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // Description card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          profile.description,
                          style: TextStyle(
                            fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Characteristics card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Caractéristiques principales',
                          style: TextStyle(
                            fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Wrap(
                          spacing: size.width * 0.02,
                          runSpacing: size.height * 0.01,
                          children: profile.characteristics.map((characteristic) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.03,
                                vertical: size.height * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Color(profileData['color'] as int).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(profileData['color'] as int).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                characteristic,
                                style: TextStyle(
                                  fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                                  color: Color(profileData['color'] as int),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Scores breakdown card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Répartition des scores',
                          style: TextStyle(
                            fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildScoreBar('Flower', scores.flower, 8, const Color(0xFFE91E63), size, isSmallScreen),
                        _buildScoreBar('Jewel', scores.jewel, 8, const Color(0xFF2196F3), size, isSmallScreen),
                        _buildScoreBar('Shaker', scores.shaker, 8, const Color(0xFFFF9800), size, isSmallScreen),
                        _buildScoreBar('Stream', scores.stream, 8, const Color(0xFF4CAF50), size, isSmallScreen),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/personality-test',
                          (route) => false,
                        ),
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
                          'Refaire le test',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/accueil',
                          (route) => false,
                        ),
                        child: Text(
                          'Retour à l\'accueil',
                          style: TextStyle(
                            color: const Color(0xFF4CAF50),
                            fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, double maxScore, Color color, Size size, bool isSmallScreen) {
    final percentage = (score / maxScore).clamp(0.0, 1.0);
    
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${score.toStringAsFixed(1)}/$maxScore',
                style: TextStyle(
                  fontSize: size.width * (isSmallScreen ? 0.03 : 0.02),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.005),
          Container(
            height: size.height * 0.01,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPersonalityIcon(PersonalityClass personalityClass) {
    switch (personalityClass) {
      case PersonalityClass.flower:
        return '🌸';
      case PersonalityClass.jewel:
        return '💎';
      case PersonalityClass.shaker:
        return '⚡';
      case PersonalityClass.stream:
        return '🌊';
      case PersonalityClass.flowerJewel:
        return '🌺💎';
      case PersonalityClass.jewelShaker:
        return '💎⚡';
      case PersonalityClass.shakerStream:
        return '⚡🌊';
      case PersonalityClass.streamFlower:
        return '🌊🌸';
    }
  }
}
