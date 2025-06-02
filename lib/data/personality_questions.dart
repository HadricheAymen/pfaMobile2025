import '../models/personality_test_models.dart';

// Questions du test psychotechnique - 4 options format
final List<Question> personalityQuestions = [
  // Question 1
  Question(
    id: 1,
    question: "Comment préférez-vous prendre des décisions importantes ?",
    options: [
      "En suivant mes émotions et mon intuition",
      "En analysant tous les détails et données disponibles",
      "En agissant rapidement selon mon instinct",
      "En consultant les autres et en cherchant un consensus"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 2
  Question(
    id: 2,
    question: "Dans un projet d'équipe, quel rôle vous correspond le mieux ?",
    options: [
      "Apporter des idées créatives et originales",
      "Organiser et planifier les étapes du projet",
      "Motiver l'équipe et prendre des initiatives",
      "Faciliter la communication et maintenir l'harmonie"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 3
  Question(
    id: 3,
    question: "Qu'est-ce qui vous motive le plus dans votre travail ?",
    options: [
      "L'expression de ma créativité et de mes valeurs",
      "La résolution de problèmes complexes et l'efficacité",
      "Les défis stimulants et les nouvelles expériences",
      "Les relations humaines et l'aide aux autres"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 4
  Question(
    id: 4,
    question: "Comment gérez-vous le stress et la pression ?",
    options: [
      "Je me retire pour réfléchir et me ressourcer émotionnellement",
      "J'analyse la situation et établis un plan méthodique",
      "Je passe à l'action immédiatement pour résoudre le problème",
      "Je cherche du soutien auprès de mes proches"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 5
  Question(
    id: 5,
    question: "Quel environnement de travail vous convient le mieux ?",
    options: [
      "Un espace créatif et inspirant avec beaucoup de liberté",
      "Un bureau organisé avec des processus clairs et définis",
      "Un environnement dynamique avec des défis constants",
      "Un lieu collaboratif favorisant les échanges et l'entraide"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 6
  Question(
    id: 6,
    question: "Comment abordez-vous un nouveau projet ?",
    options: [
      "Je laisse libre cours à ma créativité et mon inspiration",
      "Je commence par une analyse détaillée et un plan structuré",
      "Je me lance rapidement pour tester et ajuster en cours de route",
      "Je consulte mon équipe pour définir ensemble les objectifs"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 7
  Question(
    id: 7,
    question:
        "Qu'est-ce qui vous préoccupe le plus dans une situation difficile ?",
    options: [
      "L'impact émotionnel sur moi et les autres",
      "Trouver la solution la plus logique et efficace",
      "Agir rapidement pour résoudre le problème",
      "Maintenir l'harmonie et éviter les conflits"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 8
  Question(
    id: 8,
    question: "Comment préférez-vous apprendre de nouvelles compétences ?",
    options: [
      "Par l'expérimentation créative et l'exploration personnelle",
      "Grâce à des formations structurées et des méthodes éprouvées",
      "En me lançant directement dans la pratique",
      "En échangeant avec d'autres et en apprenant ensemble"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 9
  Question(
    id: 9,
    question: "Face à un conflit, quelle est votre première réaction ?",
    options: [
      "Je cherche à comprendre les émotions de chacun",
      "J'analyse les faits pour trouver une solution objective",
      "Je prends des mesures immédiates pour résoudre le problème",
      "Je facilite le dialogue pour restaurer l'harmonie"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 10
  Question(
    id: 10,
    question:
        "Qu'est-ce qui vous donne le plus de satisfaction dans vos réalisations ?",
    options: [
      "L'originalité et l'authenticité de mon travail",
      "La précision et la qualité technique du résultat",
      "L'impact et les résultats concrets obtenus",
      "La contribution positive aux autres et à l'équipe"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 11
  Question(
    id: 11,
    question: "Comment organisez-vous votre temps libre ?",
    options: [
      "Je privilégie les activités créatives et inspirantes",
      "Je planifie des activités structurées et enrichissantes",
      "Je recherche des expériences nouvelles et stimulantes",
      "Je passe du temps avec mes proches et ma communauté"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 12
  Question(
    id: 12,
    question:
        "Quelle approche adoptez-vous pour résoudre un problème complexe ?",
    options: [
      "Je fais confiance à mon intuition et ma créativité",
      "Je décompose le problème en étapes logiques",
      "J'expérimente différentes solutions rapidement",
      "Je consulte et implique les autres dans la réflexion"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 13
  Question(
    id: 13,
    question: "Dans une réunion, quel rôle adoptez-vous naturellement ?",
    options: [
      "Je propose des idées innovantes et des perspectives nouvelles",
      "Je structure les discussions et synthétise les informations",
      "Je pousse à l'action et aux décisions concrètes",
      "Je veille à ce que chacun puisse s'exprimer"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 14
  Question(
    id: 14,
    question: "Comment réagissez-vous face à un changement imprévu ?",
    options: [
      "Je m'adapte en suivant mes émotions et mon ressenti",
      "J'évalue méthodiquement les implications du changement",
      "Je saisis les opportunités que le changement peut offrir",
      "Je cherche à rassurer et accompagner les autres"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 15
  Question(
    id: 15,
    question:
        "Qu'est-ce qui vous motive le plus dans vos relations professionnelles ?",
    options: [
      "L'authenticité et la connexion émotionnelle",
      "La compétence et l'expertise partagée",
      "L'efficacité et l'atteinte d'objectifs communs",
      "La collaboration et l'entraide mutuelle"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),

  // Question 16
  Question(
    id: 16,
    question: "Comment définiriez-vous votre style de communication ?",
    options: [
      "Expressif et inspirant, je partage mes émotions et visions",
      "Précis et factuel, je privilégie la clarté et la logique",
      "Direct et orienté résultats, je vais à l'essentiel",
      "Empathique et inclusif, j'écoute et je facilite les échanges"
    ],
    optionMapping: {
      0: PersonalityClass.flower,
      1: PersonalityClass.jewel,
      2: PersonalityClass.shaker,
      3: PersonalityClass.stream,
    },
  ),
];

// Personality class descriptions and characteristics
const Map<PersonalityClass, Map<String, dynamic>> personalityDescriptions = {
  PersonalityClass.flower: {
    'name': 'Flower',
    'description':
        'Personnalité émotionnelle, créative et empathique. Vous êtes guidé par vos sentiments et votre intuition, avec une forte capacité d\'expression artistique.',
    'characteristics': [
      'Émotionnel',
      'Créatif',
      'Empathique',
      'Intuitif',
      'Artistique'
    ],
    'color': 0xFFE91E63, // Pink
  },
  PersonalityClass.jewel: {
    'name': 'Jewel',
    'description':
        'Personnalité structurée, analytique et méthodique. Vous excellez dans l\'organisation et la planification, avec une approche logique des problèmes.',
    'characteristics': [
      'Structuré',
      'Analytique',
      'Méthodique',
      'Logique',
      'Organisé'
    ],
    'color': 0xFF2196F3, // Blue
  },
  PersonalityClass.shaker: {
    'name': 'Shaker',
    'description':
        'Personnalité dynamique, aventurière et spontanée. Vous aimez l\'action, les défis et n\'hésitez pas à prendre des risques calculés.',
    'characteristics': [
      'Dynamique',
      'Aventurier',
      'Spontané',
      'Énergique',
      'Audacieux'
    ],
    'color': 0xFFFF9800, // Orange
  },
  PersonalityClass.stream: {
    'name': 'Stream',
    'description':
        'Personnalité harmonieuse, collaborative et adaptable. Vous privilégiez les relations humaines et l\'harmonie dans vos interactions.',
    'characteristics': [
      'Harmonieux',
      'Collaboratif',
      'Adaptable',
      'Diplomate',
      'Bienveillant'
    ],
    'color': 0xFF4CAF50, // Green
  },
  PersonalityClass.flowerJewel: {
    'name': 'Flower-Jewel',
    'description':
        'Profil créatif-analytique. Vous combinez imagination et méthode, créativité et structure pour des réalisations exceptionnelles.',
    'characteristics': [
      'Créatif-Analytique',
      'Méthodique-Artistique',
      'Innovant-Structuré'
    ],
    'color': 0xFF9C27B0, // Purple
  },
  PersonalityClass.jewelShaker: {
    'name': 'Jewel-Shaker',
    'description':
        'Profil analytique-dynamique. Vous alliez réflexion stratégique et action rapide, efficacité et innovation.',
    'characteristics': [
      'Analytique-Dynamique',
      'Stratégique-Actif',
      'Efficace-Innovant'
    ],
    'color': 0xFF3F51B5, // Indigo
  },
  PersonalityClass.shakerStream: {
    'name': 'Shaker-Stream',
    'description':
        'Profil dynamique-harmonieux. Vous êtes un leader naturel qui sait motiver et fédérer autour de projets ambitieux.',
    'characteristics': [
      'Dynamique-Harmonieux',
      'Leader-Collaboratif',
      'Motivant-Fédérateur'
    ],
    'color': 0xFFFF5722, // Deep Orange
  },
  PersonalityClass.streamFlower: {
    'name': 'Stream-Flower',
    'description':
        'Profil harmonieux-créatif. Vous excellez dans la création de liens émotionnels et l\'expression artistique collective.',
    'characteristics': [
      'Harmonieux-Créatif',
      'Empathique-Artistique',
      'Collaboratif-Expressif'
    ],
    'color': 0xFF009688, // Teal
  },
};
