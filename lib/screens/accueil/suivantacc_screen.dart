import 'package:flutter/material.dart';

class SuivantaccScreen extends StatelessWidget {
  const SuivantaccScreen({super.key});

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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Iris',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize:
                                size.width * (isSmallScreen ? 0.06 : 0.04),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Lock',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamedAndRemoveUntil(context, '/accueil', (route) => false),
                        child: Text(
                          'Accueil',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize:
                                size.width * (isSmallScreen ? 0.04 : 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      children: [
                        // Image Section
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: size.width * 0.6,
                              height: size.width * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      const Color(0xFF8A4FFF).withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            ClipOval(
                              child: Image.asset(
                                'assets/iris3.png',
                                width: size.width * 0.55,
                                height: size.width * 0.55,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.03),

                        // Text Content
                        Text(
                          'Découvrir l\'unicité de chacun',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize:
                                size.width * (isSmallScreen ? 0.06 : 0.04),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8A4FFF), Color(0xFF4F8AFF)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          'L\'iris est une structure biométrique complexe et unique à chaque individu.',
                          style: TextStyle(
                            fontSize:
                                size.width * (isSmallScreen ? 0.045 : 0.035),
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          'Ses motifs, distincts et inimitables, peuvent fournir des informations précieuses sur les caractéristiques physiologiques, psychologiques et comportementales d\'une personne. L\'analyse de la structure irienne permet d\'identifier des traits de personnalité, des prédispositions héréditaires, ainsi que d\'éventuelles implications sur la santé et les relations interpersonnelles.',
                          style: TextStyle(
                            fontSize:
                                size.width * (isSmallScreen ? 0.04 : 0.03),
                            color: Colors.black54,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Next Button
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/typeiris'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4FFF),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                        vertical: size.height * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Suivant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                size.width * (isSmallScreen ? 0.04 : 0.03),
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
                  SizedBox(height: size.height * 0.04),

                  // Feature Cards
                  Wrap(
                    spacing: size.width * 0.04,
                    runSpacing: size.width * 0.04,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard(
                        context,
                        '👁️',
                        'Structure Unique',
                        'Chaque iris possède une structure aussi unique qu\'une empreinte digitale',
                      ),
                      _buildFeatureCard(
                        context,
                        '🧠',
                        'Reflet de la Personnalité',
                        'Les motifs de l\'iris révèlent des aspects profonds de notre personnalité',
                      ),
                      _buildFeatureCard(
                        context,
                        '🔄',
                        'Évolution Continue',
                        'Les caractéristiques évoluent selon notre parcours de vie et nos habitudes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String emoji,
    String title,
    String description,
  ) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      width: size.width * (isSmallScreen ? 0.8 : 0.28),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: size.width * (isSmallScreen ? 0.08 : 0.06),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            description,
            style: TextStyle(
              fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
