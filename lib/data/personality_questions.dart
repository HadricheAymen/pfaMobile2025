import '../models/personality_test_models.dart';

// Questions du test psychotechnique - Ported from Angular app
final List<Question> personalityQuestions = [
  // Questions Flower (1-4)
  Question(
    id: 1,
    question: "Vous vous laissez guider par vos émotions ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flower],
  ),
  Question(
    id: 2,
    question: "Vous aimez aider les autres spontanément ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flower],
  ),
  Question(
    id: 3,
    question: "Vous êtes souvent dans l'imaginaire ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flower],
  ),
  Question(
    id: 4,
    question: "Vous appréciez les environnements créatifs ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flower],
  ),

  // Questions Jewel (5-8)
  Question(
    id: 5,
    question: "Vous préférez planifier vos activités à l'avance ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewel],
  ),
  Question(
    id: 6,
    question: "Vous aimez analyser les détails avant de prendre une décision ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewel],
  ),
  Question(
    id: 7,
    question: "Vous vous sentez à l'aise avec les règles et les procédures ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewel],
  ),
  Question(
    id: 8,
    question: "Vous préférez les environnements structurés ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewel],
  ),

  // Questions Shaker (9-12)
  Question(
    id: 9,
    question: "Vous aimez prendre des risques calculés ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shaker],
  ),
  Question(
    id: 10,
    question: "Vous vous adaptez facilement aux changements ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shaker],
  ),
  Question(
    id: 11,
    question: "Vous préférez l'action à la réflexion prolongée ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shaker],
  ),
  Question(
    id: 12,
    question: "Vous aimez explorer de nouveaux territoires ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shaker],
  ),

  // Questions Stream (13-16)
  Question(
    id: 13,
    question: "Vous préférez travailler en équipe ?",
    expectedAnswer: true,
    classes: [PersonalityClass.stream],
  ),
  Question(
    id: 14,
    question: "Vous cherchez l'harmonie dans vos relations ?",
    expectedAnswer: true,
    classes: [PersonalityClass.stream],
  ),
  Question(
    id: 15,
    question: "Vous évitez les conflits autant que possible ?",
    expectedAnswer: true,
    classes: [PersonalityClass.stream],
  ),
  Question(
    id: 16,
    question: "Vous vous adaptez facilement aux autres ?",
    expectedAnswer: true,
    classes: [PersonalityClass.stream],
  ),

  // Questions Flower-Jewel (17-20)
  Question(
    id: 17,
    question: "Vous combinez créativité et méthode dans votre travail ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flowerJewel],
  ),
  Question(
    id: 18,
    question: "Vous planifiez vos projets créatifs avec soin ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flowerJewel],
  ),
  Question(
    id: 19,
    question: "Vous aimez structurer vos idées artistiques ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flowerJewel],
  ),
  Question(
    id: 20,
    question: "Vous recherchez la perfection dans vos créations ?",
    expectedAnswer: true,
    classes: [PersonalityClass.flowerJewel],
  ),

  // Questions Jewel-Shaker (21-24)
  Question(
    id: 21,
    question: "Vous prenez des décisions rapides basées sur l'analyse ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewelShaker],
  ),
  Question(
    id: 22,
    question: "Vous aimez optimiser les processus existants ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewelShaker],
  ),
  Question(
    id: 23,
    question: "Vous êtes efficace sous pression ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewelShaker],
  ),
  Question(
    id: 24,
    question: "Vous innovez tout en respectant les contraintes ?",
    expectedAnswer: true,
    classes: [PersonalityClass.jewelShaker],
  ),

  // Questions Shaker-Stream (25-28)
  Question(
    id: 25,
    question: "Vous motivez les autres à prendre des initiatives ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shakerStream],
  ),
  Question(
    id: 26,
    question: "Vous adaptez votre style de leadership selon la situation ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shakerStream],
  ),
  Question(
    id: 27,
    question: "Vous encouragez l'innovation en équipe ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shakerStream],
  ),
  Question(
    id: 28,
    question: "Vous créez une dynamique positive dans les groupes ?",
    expectedAnswer: true,
    classes: [PersonalityClass.shakerStream],
  ),

  // Questions Stream-Flower (29-32)
  Question(
    id: 29,
    question: "Vous exprimez vos émotions de manière harmonieuse ?",
    expectedAnswer: true,
    classes: [PersonalityClass.streamFlower],
  ),
  Question(
    id: 30,
    question: "Vous créez des liens émotionnels profonds avec les autres ?",
    expectedAnswer: true,
    classes: [PersonalityClass.streamFlower],
  ),
  Question(
    id: 31,
    question: "Vous utilisez votre intuition pour comprendre les autres ?",
    expectedAnswer: true,
    classes: [PersonalityClass.streamFlower],
  ),
  Question(
    id: 32,
    question: "Vous favorisez l'expression créative collective ?",
    expectedAnswer: true,
    classes: [PersonalityClass.streamFlower],
  ),
];

// Personality class descriptions and characteristics
const Map<PersonalityClass, Map<String, dynamic>> personalityDescriptions = {
  PersonalityClass.flower: {
    'name': 'Flower',
    'description': 'Personnalité émotionnelle, créative et empathique. Vous êtes guidé par vos sentiments et votre intuition, avec une forte capacité d\'expression artistique.',
    'characteristics': ['Émotionnel', 'Créatif', 'Empathique', 'Intuitif', 'Artistique'],
    'color': 0xFFE91E63, // Pink
  },
  PersonalityClass.jewel: {
    'name': 'Jewel',
    'description': 'Personnalité structurée, analytique et méthodique. Vous excellez dans l\'organisation et la planification, avec une approche logique des problèmes.',
    'characteristics': ['Structuré', 'Analytique', 'Méthodique', 'Logique', 'Organisé'],
    'color': 0xFF2196F3, // Blue
  },
  PersonalityClass.shaker: {
    'name': 'Shaker',
    'description': 'Personnalité dynamique, aventurière et spontanée. Vous aimez l\'action, les défis et n\'hésitez pas à prendre des risques calculés.',
    'characteristics': ['Dynamique', 'Aventurier', 'Spontané', 'Énergique', 'Audacieux'],
    'color': 0xFFFF9800, // Orange
  },
  PersonalityClass.stream: {
    'name': 'Stream',
    'description': 'Personnalité harmonieuse, collaborative et adaptable. Vous privilégiez les relations humaines et l\'harmonie dans vos interactions.',
    'characteristics': ['Harmonieux', 'Collaboratif', 'Adaptable', 'Diplomate', 'Bienveillant'],
    'color': 0xFF4CAF50, // Green
  },
  PersonalityClass.flowerJewel: {
    'name': 'Flower-Jewel',
    'description': 'Profil créatif-analytique. Vous combinez imagination et méthode, créativité et structure pour des réalisations exceptionnelles.',
    'characteristics': ['Créatif-Analytique', 'Méthodique-Artistique', 'Innovant-Structuré'],
    'color': 0xFF9C27B0, // Purple
  },
  PersonalityClass.jewelShaker: {
    'name': 'Jewel-Shaker',
    'description': 'Profil analytique-dynamique. Vous alliez réflexion stratégique et action rapide, efficacité et innovation.',
    'characteristics': ['Analytique-Dynamique', 'Stratégique-Actif', 'Efficace-Innovant'],
    'color': 0xFF3F51B5, // Indigo
  },
  PersonalityClass.shakerStream: {
    'name': 'Shaker-Stream',
    'description': 'Profil dynamique-harmonieux. Vous êtes un leader naturel qui sait motiver et fédérer autour de projets ambitieux.',
    'characteristics': ['Dynamique-Harmonieux', 'Leader-Collaboratif', 'Motivant-Fédérateur'],
    'color': 0xFFFF5722, // Deep Orange
  },
  PersonalityClass.streamFlower: {
    'name': 'Stream-Flower',
    'description': 'Profil harmonieux-créatif. Vous excellez dans la création de liens émotionnels et l\'expression artistique collective.',
    'characteristics': ['Harmonieux-Créatif', 'Empathique-Artistique', 'Collaboratif-Expressif'],
    'color': 0xFF009688, // Teal
  },
};
