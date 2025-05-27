import 'package:flutter/material.dart';

const shakerPrimaryColor = Color(0xFF4F8AFF);
const shakerSecondaryColor = Color(0xFF92B8FF);
const shakerGradientStart = Color(0xFFE6F0FF);
const shakerGradientEnd = Color(0xFFE0E6FF);

class ShakerScreen extends StatelessWidget {
  const ShakerScreen({Key? key}) : super(key: key);

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
                shakerGradientStart,
                shakerGradientEnd,
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
                    'Shaker - Le Visionnaire',
                    style: TextStyle(
                      fontSize: size.width * (isSmallScreen ? 0.07 : 0.05),
                      fontWeight: FontWeight.bold,
                      color: shakerPrimaryColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Type motivé, expressif et orienté action',
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
                            color: shakerPrimaryColor.withOpacity(0.3),
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
                              color: shakerPrimaryColor.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/4.png'),
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
                            fontSize:
                                size.width * (isSmallScreen ? 0.06 : 0.04),
                            fontWeight: FontWeight.bold,
                            color: shakerPrimaryColor,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildTraitItem(context, '🚀',
                            'Type motivé, expressif, pionnier, orienté action et innovation'),
                        _buildTraitItem(context, '💡',
                            'Dépasse la pensée conventionnelle, énergique et inspirant'),
                        _buildTraitItem(context, '🔄',
                            'Combine les forces de Bijou (visuel) et Fleur (auditif)'),
                        _buildTraitItem(
                            context, '⚡', 'Décide vite et tient ses choix'),
                        _buildTraitItem(context, '🏃',
                            'Apprentissage par le mouvement, le toucher et l\'intuition'),
                        _buildTraitItem(context, '👋',
                            'Communique avec gestes dynamiques et passion'),
                        _buildTraitItem(context, '🔄',
                            'Agent de changement, inventif, motivateur, leader né'),
                        _buildTraitItem(context, '⚠️',
                            'Peut devenir instable, autoritaire, autocritique'),
                        _buildTraitItem(context, '🌱',
                            'Leçon de vie : cultiver la cohérence, la confiance et l\'ancrage'),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Navigation Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: shakerPrimaryColor,
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
                        Icon(
                          Icons.arrow_back,
                          size: size.width * 0.05,
                          color: Colors.white
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          'Retour aux types d\'iris',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                size.width * (isSmallScreen ? 0.04 : 0.03),
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
            style:
                TextStyle(fontSize: size.width * (isSmallScreen ? 0.06 : 0.04)),
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

