import 'package:flutter/material.dart';

// Update the color constants
const fluxPrimaryColor = Color(0xFF4FFF8A);
const fluxSecondaryColor = Color(0xFF92FFB8);
const fluxGradientStart = Color(0xFFE6FFF0);
const fluxGradientEnd = Color(0xFFE0FFE6);

class FluxScreen extends StatelessWidget {
  const FluxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                fluxGradientStart,
                fluxGradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.03,
              ),
              child: Column(
                children: [
                  // Header
                  Text(
                    'Flux - Le Sensitif',
                    style: TextStyle(
                      fontSize: size.width * (isSmallScreen ? 0.07 : 0.05),
                      fontWeight: FontWeight.bold,
                      color: fluxPrimaryColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Type intuitif, physique et empathique',
                    style: TextStyle(
                      fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Image with decoration
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: size.width * (isSmallScreen ? 0.6 : 0.4),
                        height: size.width * (isSmallScreen ? 0.6 : 0.4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: fluxPrimaryColor.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      Container(
                        width: size.width * (isSmallScreen ? 0.55 : 0.35),
                        height: size.width * (isSmallScreen ? 0.55 : 0.35),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: fluxPrimaryColor.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/3.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Characteristics Card
                  Container(
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Caractéristiques',
                          style: TextStyle(
                            fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
                            fontWeight: FontWeight.bold,
                            color: fluxPrimaryColor,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildTraitItem(context, '🌊', 'Sensibilité physique et intuitive'),
                        _buildTraitItem(context, '👥', 'Grande capacité d\'empathie et d\'écoute'),
                        _buildTraitItem(context, '🤝', 'Communication physique : posture, gestes, toucher contrôlé'),
                        _buildTraitItem(context, '🏔️', 'Apporte stabilité, empathie et soutien'),
                        _buildTraitItem(context, '💫', 'Peut se sentir impuissant ou débordé'),
                        _buildTraitItem(context, '🎯', 'Besoin de structure et de cadre'),
                        _buildTraitItem(context, '🌱', 'Leçon de vie : faire confiance, lâcher prise et trouver sa mission'),
                        _buildTraitItem(context, '⚡', 'Apprentissage par l\'expérience et le ressenti'),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Navigation Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fluxPrimaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: size.width * 0.05,color: Colors.white),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          'Retour aux types d\'iris',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTraitItem(BuildContext context, String emoji, String text) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: size.width * (isSmallScreen ? 0.06 : 0.04)),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
