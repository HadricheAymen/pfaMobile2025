import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PersonalityClassService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch personality class description from Firestore
  static Future<Map<String, dynamic>?> getPersonalityClassDescription(String className) async {
    try {
      debugPrint('🔍 Fetching personality class description for: $className');
      
      // Normalize class name to match Firestore document IDs
      final normalizedClassName = _normalizeClassName(className);
      
      // Try to get from personality_families collection first
      final familyDoc = await _firestore
          .collection('personality_families')
          .doc(normalizedClassName)
          .get();
      
      if (familyDoc.exists) {
        debugPrint('✅ Found personality class in families collection');
        return familyDoc.data();
      }
      
      // If not found in families, try personality_descriptions collection
      final descDoc = await _firestore
          .collection('personality_descriptions')
          .doc(normalizedClassName)
          .get();
      
      if (descDoc.exists) {
        debugPrint('✅ Found personality class in descriptions collection');
        return descDoc.data();
      }
      
      // If still not found, try to find by name field
      final querySnapshot = await _firestore
          .collection('personality_families')
          .where('name', isEqualTo: className)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('✅ Found personality class by name query');
        return querySnapshot.docs.first.data();
      }
      
      debugPrint('❌ Personality class not found: $className');
      return null;
      
    } catch (e) {
      debugPrint('❌ Error fetching personality class description: $e');
      return null;
    }
  }

  /// Get all available personality classes
  static Future<List<Map<String, dynamic>>> getAllPersonalityClasses() async {
    try {
      debugPrint('🔍 Fetching all personality classes...');
      
      final querySnapshot = await _firestore
          .collection('personality_families')
          .get();
      
      final classes = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
      
      debugPrint('✅ Found ${classes.length} personality classes');
      return classes;
      
    } catch (e) {
      debugPrint('❌ Error fetching all personality classes: $e');
      return [];
    }
  }

  /// Initialize personality families in Firestore if they don't exist
  static Future<bool> initializePersonalityFamilies() async {
    try {
      debugPrint('🔄 Initializing personality families...');
      
      // Check if families already exist
      final existingFamilies = await _firestore
          .collection('personality_families')
          .limit(1)
          .get();
      
      if (existingFamilies.docs.isNotEmpty) {
        debugPrint('✅ Personality families already exist');
        return true;
      }
      
      // Define personality families
      final families = [
        {
          'id': 'flower',
          'name': 'Flower',
          'description': 'Personnalité émotionnelle, créative et empathique. Vous êtes guidé par vos sentiments et votre intuition, avec une forte capacité d\'expression artistique.',
          'characteristics': ['Émotionnel', 'Créatif', 'Empathique', 'Intuitif', 'Artistique'],
          'color': 0xFFE91E63,
          'icon': '🌸',
        },
        {
          'id': 'jewel',
          'name': 'Jewel',
          'description': 'Personnalité structurée, analytique et méthodique. Vous excellez dans l\'organisation et la planification, avec une approche logique des problèmes.',
          'characteristics': ['Structuré', 'Analytique', 'Méthodique', 'Logique', 'Organisé'],
          'color': 0xFF2196F3,
          'icon': '💎',
        },
        {
          'id': 'shaker',
          'name': 'Shaker',
          'description': 'Personnalité dynamique, aventurière et spontanée. Vous aimez l\'action, les défis et n\'hésitez pas à prendre des risques calculés.',
          'characteristics': ['Dynamique', 'Aventurier', 'Spontané', 'Énergique', 'Audacieux'],
          'color': 0xFFFF9800,
          'icon': '⚡',
        },
        {
          'id': 'stream',
          'name': 'Stream',
          'description': 'Personnalité harmonieuse, collaborative et adaptable. Vous privilégiez les relations humaines et l\'harmonie dans vos interactions.',
          'characteristics': ['Harmonieux', 'Collaboratif', 'Adaptable', 'Diplomate', 'Bienveillant'],
          'color': 0xFF4CAF50,
          'icon': '🌊',
        },
        {
          'id': 'flower-jewel',
          'name': 'Flower-Jewel',
          'description': 'Profil créatif-analytique. Vous combinez imagination et méthode, créativité et structure pour des réalisations exceptionnelles.',
          'characteristics': ['Créatif-Analytique', 'Méthodique-Artistique', 'Innovant-Structuré'],
          'color': 0xFF9C27B0,
          'icon': '🌺💎',
        },
        {
          'id': 'jewel-shaker',
          'name': 'Jewel-Shaker',
          'description': 'Profil analytique-dynamique. Vous alliez réflexion stratégique et action rapide, efficacité et innovation.',
          'characteristics': ['Analytique-Dynamique', 'Stratégique-Actif', 'Efficace-Innovant'],
          'color': 0xFF3F51B5,
          'icon': '💎⚡',
        },
        {
          'id': 'shaker-stream',
          'name': 'Shaker-Stream',
          'description': 'Profil dynamique-harmonieux. Vous êtes un leader naturel qui sait motiver et fédérer autour de projets ambitieux.',
          'characteristics': ['Dynamique-Harmonieux', 'Leader-Collaboratif', 'Motivant-Fédérateur'],
          'color': 0xFFFF5722,
          'icon': '⚡🌊',
        },
        {
          'id': 'stream-flower',
          'name': 'Stream-Flower',
          'description': 'Profil harmonieux-créatif. Vous excellez dans la création de liens émotionnels et l\'expression artistique collective.',
          'characteristics': ['Harmonieux-Créatif', 'Empathique-Artistique', 'Collaboratif-Expressif'],
          'color': 0xFF009688,
          'icon': '🌊🌸',
        },
      ];
      
      // Save each family to Firestore
      for (final family in families) {
        await _firestore
            .collection('personality_families')
            .doc(family['id'] as String)
            .set(family);
      }
      
      debugPrint('✅ Personality families initialized successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error initializing personality families: $e');
      return false;
    }
  }

  /// Normalize class name for consistent lookup
  static String _normalizeClassName(String className) {
    return className
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll('_', '-');
  }

  /// Get personality class by various name formats
  static Future<Map<String, dynamic>?> findPersonalityClass(String className) async {
    try {
      // Try different name formats
      final variations = [
        className,
        className.toLowerCase(),
        _normalizeClassName(className),
        className.replaceAll('-', ' '),
        className.replaceAll('_', ' '),
      ];
      
      for (final variation in variations) {
        final result = await getPersonalityClassDescription(variation);
        if (result != null) {
          return result;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error finding personality class: $e');
      return null;
    }
  }

  /// Create a fallback personality description if not found in Firestore
  static Map<String, dynamic> createFallbackDescription(String className) {
    return {
      'id': _normalizeClassName(className),
      'name': className,
      'description': 'Votre iris révèle une personnalité de type $className. Cette analyse est basée sur les caractéristiques uniques de votre iris.',
      'characteristics': ['Unique', 'Authentique', 'Personnel'],
      'color': 0xFF607D8B, // Blue Grey
      'icon': '👁️',
      'source': 'fallback',
    };
  }
}
