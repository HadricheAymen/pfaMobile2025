import 'package:flutter/material.dart';

class AccueilScreenStyles {
  static const primaryColor = Color(0xFF8A4FFF);
  static const secondaryColor = Color(0xFF6E3FCC);
  
  static const gradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
       Color(0xFFF5F7FA),
       Color(0xFFE4E8F0),
    ],
  );

  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 15),
      ),
    ],
  );

  static const titleStyle = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  static final descriptionStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey[600],
    height: 1.5,
  );

  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  );
}