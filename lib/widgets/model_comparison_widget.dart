import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pfa_mobile/services/api_service.dart';
import 'package:pfa_mobile/utils/responsive_utils.dart';

class ModelComparisonWidget extends StatefulWidget {
  final File leftIrisImage;
  final File rightIrisImage;

  const ModelComparisonWidget({
    Key? key,
    required this.leftIrisImage,
    required this.rightIrisImage,
  }) : super(key: key);

  @override
  State<ModelComparisonWidget> createState() => _ModelComparisonWidgetState();
}

class _ModelComparisonWidgetState extends State<ModelComparisonWidget> {
  bool _isComparing = false;
  Map<PredictionModel, Map<String, dynamic>?> _results = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: context.responsivePadding(
          mobilePortrait: 0.04,
          mobileLandscape: 0.035,
          tabletPortrait: 0.045,
          tabletLandscape: 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: const Color(0xFF8A4FFF),
                  size: context.responsiveFontSize(
                    mobilePortrait: 0.05,
                    mobileLandscape: 0.04,
                    tabletPortrait: 0.045,
                    tabletLandscape: 0.038,
                  ),
                ),
                SizedBox(
                  width: context.responsiveSpacing(
                    mobilePortrait: 0.02,
                    mobileLandscape: 0.015,
                    tabletPortrait: 0.025,
                    tabletLandscape: 0.018,
                  ),
                ),
                Text(
                  'Comparaison des modèles',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.045,
                      mobileLandscape: 0.035,
                      tabletPortrait: 0.04,
                      tabletLandscape: 0.033,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: context.responsiveSpacing(
                mobilePortrait: 0.02,
                mobileLandscape: 0.015,
                tabletPortrait: 0.025,
                tabletLandscape: 0.018,
              ),
            ),
            
            // Compare button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isComparing ? null : _compareModels,
                icon: _isComparing
                    ? SizedBox(
                        width: context.responsiveFontSize(
                          mobilePortrait: 0.04,
                          mobileLandscape: 0.032,
                          tabletPortrait: 0.035,
                          tabletLandscape: 0.03,
                        ),
                        height: context.responsiveFontSize(
                          mobilePortrait: 0.04,
                          mobileLandscape: 0.032,
                          tabletPortrait: 0.035,
                          tabletLandscape: 0.03,
                        ),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.compare),
                label: Text(
                  _isComparing ? 'Comparaison en cours...' : 'Comparer les modèles',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.04,
                      mobileLandscape: 0.032,
                      tabletPortrait: 0.035,
                      tabletLandscape: 0.03,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A4FFF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsiveSpacing(
                      mobilePortrait: 0.018,
                      mobileLandscape: 0.015,
                      tabletPortrait: 0.02,
                      tabletLandscape: 0.016,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            // Results display
            if (_results.isNotEmpty) ...[
              SizedBox(
                height: context.responsiveSpacing(
                  mobilePortrait: 0.025,
                  mobileLandscape: 0.02,
                  tabletPortrait: 0.03,
                  tabletLandscape: 0.025,
                ),
              ),
              Text(
                'Résultats de comparaison',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    mobilePortrait: 0.04,
                    mobileLandscape: 0.032,
                    tabletPortrait: 0.035,
                    tabletLandscape: 0.03,
                  ),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(
                height: context.responsiveSpacing(
                  mobilePortrait: 0.015,
                  mobileLandscape: 0.01,
                  tabletPortrait: 0.018,
                  tabletLandscape: 0.012,
                ),
              ),
              
              // Results for each model
              ..._results.entries.map((entry) => _buildModelResult(entry.key, entry.value)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModelResult(PredictionModel model, Map<String, dynamic>? result) {
    final bool hasError = result?.containsKey('error') ?? false;
    final String prediction = result?['primary_class'] ?? result?['prediction'] ?? 'N/A';
    
    return Container(
      margin: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          mobilePortrait: 0.015,
          mobileLandscape: 0.01,
          tabletPortrait: 0.018,
          tabletLandscape: 0.012,
        ),
      ),
      padding: context.responsivePadding(
        mobilePortrait: 0.03,
        mobileLandscape: 0.025,
        tabletPortrait: 0.035,
        tabletLandscape: 0.03,
      ),
      decoration: BoxDecoration(
        color: hasError 
            ? Colors.red[50] 
            : const Color(0xFF8A4FFF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError 
              ? Colors.red[300]! 
              : const Color(0xFF8A4FFF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getModelIcon(model),
                color: hasError ? Colors.red[700] : const Color(0xFF8A4FFF),
                size: context.responsiveFontSize(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.032,
                  tabletPortrait: 0.035,
                  tabletLandscape: 0.03,
                ),
              ),
              SizedBox(
                width: context.responsiveSpacing(
                  mobilePortrait: 0.015,
                  mobileLandscape: 0.01,
                  tabletPortrait: 0.018,
                  tabletLandscape: 0.012,
                ),
              ),
              Text(
                model.displayName,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    mobilePortrait: 0.04,
                    mobileLandscape: 0.032,
                    tabletPortrait: 0.035,
                    tabletLandscape: 0.03,
                  ),
                  fontWeight: FontWeight.w600,
                  color: hasError ? Colors.red[700] : const Color(0xFF8A4FFF),
                ),
              ),
            ],
          ),
          SizedBox(
            height: context.responsiveSpacing(
              mobilePortrait: 0.01,
              mobileLandscape: 0.008,
              tabletPortrait: 0.012,
              tabletLandscape: 0.01,
            ),
          ),
          Text(
            hasError 
                ? 'Erreur: ${result!['error']}'
                : 'Prédiction: $prediction',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.035,
                mobileLandscape: 0.028,
                tabletPortrait: 0.03,
                tabletLandscape: 0.025,
              ),
              color: hasError ? Colors.red[600] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModelIcon(PredictionModel model) {
    switch (model) {
      case PredictionModel.efficient:
        return Icons.speed;
      case PredictionModel.mobilenet:
        return Icons.phone_android;
    }
  }

  Future<void> _compareModels() async {
    setState(() {
      _isComparing = true;
      _results.clear();
    });

    try {
      // Test each model
      for (final model in ApiService.availableModels) {
        try {
          final result = await ApiService.predictIrisWithBothImagesUsingModel(
            widget.leftIrisImage,
            widget.rightIrisImage,
            model,
          );
          _results[model] = result;
        } catch (e) {
          _results[model] = {'error': 'Exception: $e'};
        }
        
        // Update UI after each result
        if (mounted) {
          setState(() {});
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isComparing = false;
        });
      }
    }
  }
}
