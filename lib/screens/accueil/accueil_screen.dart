import 'package:flutter/material.dart';
import 'package:pfa_mobile/forms/iris-form.dart';
import 'package:pfa_mobile/Auth/user_toggle_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  children: [
                    _buildNavBar(context, size, isSmallScreen),
                    SizedBox(height: size.height * 0.03),
                    _buildMainContent(context, size, isSmallScreen),
                    SizedBox(height: size.height * 0.04),
                    _buildFeatures(context, size, isSmallScreen),
                    SizedBox(height: size.height * 0.02),
                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const IrisForm()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A4FFF),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04,
                                vertical: size.height * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: size.width *
                                      (isSmallScreen ? 0.05 : 0.04),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Flexible(
                                  child: Text(
                                    'Analyser mon iris',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.035 : 0.025),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/personality-test');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04,
                                vertical: size.height * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.psychology,
                                  color: Colors.white,
                                  size: size.width *
                                      (isSmallScreen ? 0.05 : 0.04),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Flexible(
                                  child: Text(
                                    'Test de Personnalité',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.035 : 0.025),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, Size size, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'IrisLock',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        FirebaseAuth.instance.currentUser == null
            ? Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      'Connexion',
                      style: TextStyle(
                        color: const Color(0xFF8A4FFF),
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4FFF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                      ),
                    ),
                  ),
                ],
              )
            : UserToggleIcon(
                onSignOut: () {
                  // Optional: Refresh UI or navigate after sign out
                  Navigator.pushReplacementNamed(context, '/accueil');
                },
              ),
      ],
    );
  }

  Widget _buildMainContent(
      BuildContext context, Size size, bool isSmallScreen) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Iris & Identité',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: size.width * (isSmallScreen ? 0.08 : 0.06),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Container(
              width: size.width * 0.15,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A4FFF), Color(0xFF6E3FCC)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Chaque iris est une signature unique. Notre système de profilage biométrique offre une sécurité inégalée, inspirée directement par la nature humaine.',
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size.width * (isSmallScreen ? 0.7 : 0.5),
                    height: size.width * (isSmallScreen ? 0.7 : 0.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8A4FFF).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      'assets/iris.png',
                      width: size.width * (isSmallScreen ? 0.65 : 0.45),
                      height: size.width * (isSmallScreen ? 0.65 : 0.45),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/suivantacc'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A4FFF),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Commencer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: size.width * (isSmallScreen ? 0.05 : 0.04),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, Size size, bool isSmallScreen) {
    return Column(
      children: [
        _buildFeatureCard(
          '🔍',
          'Analyse Précise',
          'Identification des traits de personnalité à travers les motifs de l\'iris',
          size,
          isSmallScreen,
        ),
        SizedBox(height: size.height * 0.02),
        _buildFeatureCard(
          '🧬',
          'Base Scientifique',
          'Fondée sur des recherches approfondies en iridologie et biométrie',
          size,
          isSmallScreen,
        ),
        SizedBox(height: size.height * 0.02),
        _buildFeatureCard(
          '🔐',
          'Sécurité Avancée',
          'Protection des données et confidentialité garanties',
          size,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String icon,
    String title,
    String description,
    Size size,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.1 : 0.08),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              title,
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
