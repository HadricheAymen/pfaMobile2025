import 'package:flutter/material.dart';

class TypeirisScreen extends StatelessWidget {
  const TypeirisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: const [
                          TextSpan(text: 'Iris'),
                          TextSpan(
                            text: 'Lock',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Retour'),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.02),

                // Main Content
                Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Les Types d\'Iris',
                        style: TextStyle(
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Découvrez les quatre profils fondamentaux qui définissent notre personnalité à travers l\'analyse de l\'iris.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Info Cards Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: size.width * 0.03,
                        mainAxisSpacing: size.width * 0.03,
                        childAspectRatio: isSmallScreen ? 0.8 : 1.0,
                        children: const [
                          InfoCard(
                            icon: '🧬',
                            title: 'Unicité',
                            description:
                                'Chaque iris est unique et révèle des aspects spécifiques de notre personnalité',
                          ),
                          InfoCard(
                            icon: '🔄',
                            title: 'Évolution',
                            description:
                                'Les caractéristiques de l\'iris évoluent avec notre parcours de vie',
                          ),
                          InfoCard(
                            icon: '🧩',
                            title: 'Combinaison',
                            description:
                                'Nous portons en nous les quatre types fondamentaux en proportions variables',
                          ),
                          InfoCard(
                            icon: '👨‍👩‍👧‍👦',
                            title: 'Influence Familiale',
                            description:
                                'Notre rang dans la fratrie influence l\'expression de notre type d\'iris',
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Action Buttons
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/iris2');
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(double.infinity, size.height * 0.06),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Découvrir les types'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/iris-diversity');
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(double.infinity, size.height * 0.06),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Diversité des iris'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: size.width * 0.08),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            title,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            description,
            style: TextStyle(
              fontSize: size.width * 0.03,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
