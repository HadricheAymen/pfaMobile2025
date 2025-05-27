import 'package:flutter/material.dart';
import 'package:pfa_mobile/forms/iris-form.dart';

class Iris2Screen extends StatelessWidget {
  const Iris2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: [
                // Header
                Text(
                  'Les Types d\'Iris',
                  style: TextStyle(
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Découvrez les quatre profils fondamentaux et leurs caractéristiques',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Iris Cards
                Column(
                  children: [
                    _buildIrisCard(
                      context: context,
                      name: 'Fleur',
                      tagline: 'Le Sentimental',
                      description:
                          'Profil axé sur les émotions et la créativité. Expressif, spontané et artistique.',
                      imagePath: 'assets/1.png',
                      route: '/fleur',
                      color: const Color(0xFF4F8AFF), // Fleur color
                    ),
                    SizedBox(height: size.height * 0.03),
                    _buildIrisCard(
                      context: context,
                      name: 'Bijou',
                      tagline: 'Le Réfléchi',
                      description:
                          'Type analytique et mental. Observateur, précis et orienté vers la réflexion.',
                      imagePath: 'assets/2.png',
                      route: '/bijou',
                      color: const Color(0xFF4F8AFF), // Bijou color
                    ),
                    SizedBox(height: size.height * 0.03),
                    _buildIrisCard(
                      context: context,
                      name: 'Flux',
                      tagline: 'L\'Intuitif',
                      description:
                          'Profil sensible et intuitif. Empathique, adaptable et orienté vers les autres.',
                      imagePath: 'assets/3.png',
                      route: '/flux',
                      color: const Color(0xFF4F8AFF), // Flux color
                    ),
                    SizedBox(height: size.height * 0.03),
                    _buildIrisCard(
                      context: context,
                      name: 'Shaker',
                      tagline: 'Le Visionnaire',
                      description:
                          'Type motivé, expressif et orienté action. Énergique, innovant et inspirant.',
                      imagePath: 'assets/4.png',
                      route: '/shaker',
                      color: const Color(0xFF4F8AFF), // Shaker color
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),

                // Analyser mon iris button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IrisForm()),
                    );
                  },
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
                        Icons.camera_alt,
                        color: Colors.white,
                        size: size.width * (isSmallScreen ? 0.05 : 0.04),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Analyser mon iris',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/iris-diversity');
                      },
                      icon: const Text('Diversité des iris'),
                      label: const Icon(Icons.arrow_forward),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIrisCard({
    required BuildContext context,
    required String name,
    required String tagline,
    required String description,
    required String imagePath,
    required String route,
    required Color color,
  }) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        height: size.height * 0.28, // Increased height slightly
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Added this
              children: [
                // Top Row: Image, Name, and Tagline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Added this
                  children: [
                    // Image
                    Container(
                      height: size.height * 0.08,
                      width: size.height * 0.08,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    // Name and Tagline
                    Expanded(
                      // Added this
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: size.width * 0.055, // Slightly reduced
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          SizedBox(height: 4), // Fixed spacing
                          Text(
                            tagline,
                            style: TextStyle(
                              fontSize: size.width * 0.035, // Slightly reduced
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                // Description
                Expanded(
                  // Added this
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.035, // Slightly reduced
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                // Button
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: size.height * 0.012, // Slightly reduced
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Découvrir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
