import 'package:flutter/material.dart';

class IrisDiversityScreen extends StatelessWidget {
  const IrisDiversityScreen({super.key});

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
                            fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
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
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Retour',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
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
                        Text(
                          'La Diversité des Iris',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
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
                        SizedBox(height: size.height * 0.03),

                        // Iris Circle Image
                        Container(
                          width: size.width * 0.8,
                          height: size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF8A4FFF).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/Repere2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),

                        // Text Sections
                        Container(
                          padding: EdgeInsets.all(size.width * 0.04),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(15),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF8A4FFF),
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Le Repère des Types d\'Iris',
                                style: TextStyle(
                                  fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                'L\'image ci-dessus présente le repère des différents types d\'iris et leurs relations. '
                                'Cette représentation permet de visualiser comment les caractéristiques des quatre types fondamentaux '
                                '(Fleur, Bijou, Shaker et Flux) s\'organisent et s\'influencent mutuellement.',
                                style: TextStyle(
                                  fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                                  color: Colors.black54,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          padding: EdgeInsets.all(size.width * 0.04),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(15),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF8A4FFF),
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'La Diversité des Profils',
                                style: TextStyle(
                                  fontSize: size.width * (isSmallScreen ? 0.045 : 0.035),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                'Bien que ces quatre types représentent les catégories principales, il est rare qu\'un individu '
                                'corresponde parfaitement à un seul profil. En réalité, la majorité des personnes présentent des formes '
                                'intermédiaires, mêlant des caractéristiques issues de plusieurs types. Cette diversité reflète la richesse et la '
                                'complexité unique de chaque être humain.',
                                style: TextStyle(
                                  fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                                  color: Colors.black54,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.03),

                  // Back Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: size.width * (isSmallScreen ? 0.05 : 0.04),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          'Retour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                            fontWeight: FontWeight.w600,
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
}


