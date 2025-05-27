import 'package:flutter/material.dart';

// Update the color constants
const fleurPrimaryColor = Color(0xFF8A4FFF);
const fleurSecondaryColor = Color(0xFFB892FF);
const fleurGradientStart = Color(0xFFF0E6FF);
const fleurGradientEnd = Color(0xFFE6E0FF);

class FleurScreen extends StatelessWidget {
  const FleurScreen({Key? key}) : super(key: key);

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
                fleurGradientStart,
                fleurGradientEnd,
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
                    'Fleur - Le Sentimental',
                    style: TextStyle(
                      fontSize: size.width * (isSmallScreen ? 0.07 : 0.05),
                      fontWeight: FontWeight.bold,
                      color: fleurPrimaryColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Profil axé sur les émotions et la créativité',
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
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
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
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/1.png'),
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
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildTraitItem(
                            context, '💭', 'Profil axé sur les sentiments'),
                        _buildTraitItem(context, '❤️',
                            'Émotions profondes, vécues et exprimées intensément'),
                        _buildTraitItem(context, '👂',
                            'Très sensibles aux paroles, tendance à l\'auto-critique'),
                        _buildTraitItem(context, '🔊',
                            'Mode d\'apprentissage auditif, réactifs aux sons et aux mots'),
                        _buildTraitItem(context, '🎨',
                            'Spontanés, créatifs, flexibles mais facilement distraits'),
                        _buildTraitItem(context, '🤲',
                            'Besoin de reconnaissance et d\'approbation'),
                        _buildTraitItem(context, '👨',
                            'Proximité avec le père, parfois complexe'),
                        _buildTraitItem(context, '🌱',
                            'Leçon de vie : apprendre à s\'affirmer et à se structurer'),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Navigation Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fleurPrimaryColor,
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
                        Icon(Icons.arrow_back,
                            size: size.width * 0.05, color: Colors.white),
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

