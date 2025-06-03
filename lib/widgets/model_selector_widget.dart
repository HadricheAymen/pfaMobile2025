import 'package:flutter/material.dart';
import 'package:pfa_mobile/services/api_service.dart';
import 'package:pfa_mobile/utils/responsive_utils.dart';

class ModelSelectorWidget extends StatefulWidget {
  final Function(PredictionModel)? onModelChanged;
  final bool showDescription;
  final bool showTechnicalInfo;

  const ModelSelectorWidget({
    Key? key,
    this.onModelChanged,
    this.showDescription = true,
    this.showTechnicalInfo = false,
  }) : super(key: key);

  @override
  State<ModelSelectorWidget> createState() => _ModelSelectorWidgetState();
}

class _ModelSelectorWidgetState extends State<ModelSelectorWidget> {
  PredictionModel _selectedModel = ApiService.currentModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                  Icons.psychology,
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
                  'Modèle d\'analyse',
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
            
            // Model dropdown
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.03,
                  mobileLandscape: 0.025,
                  tabletPortrait: 0.035,
                  tabletLandscape: 0.03,
                ),
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PredictionModel>(
                  value: _selectedModel,
                  isExpanded: true,
                  items: ApiService.availableModels.map((model) {
                    return DropdownMenuItem<PredictionModel>(
                      value: model,
                      child: Row(
                        children: [
                          Icon(
                            _getModelIcon(model),
                            color: const Color(0xFF8A4FFF),
                            size: context.responsiveFontSize(
                              mobilePortrait: 0.04,
                              mobileLandscape: 0.032,
                              tabletPortrait: 0.035,
                              tabletLandscape: 0.03,
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
                            model.displayName,
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                mobilePortrait: 0.04,
                                mobileLandscape: 0.032,
                                tabletPortrait: 0.035,
                                tabletLandscape: 0.03,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (PredictionModel? newModel) {
                    if (newModel != null) {
                      setState(() {
                        _selectedModel = newModel;
                      });
                      
                      // Update the API service
                      ApiService.setModel(newModel);
                      
                      // Notify parent widget
                      if (widget.onModelChanged != null) {
                        widget.onModelChanged!(newModel);
                      }
                      
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Modèle changé vers: ${newModel.displayName}'),
                          backgroundColor: const Color(0xFF8A4FFF),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            
            // Model description
            if (widget.showDescription) ...[
              SizedBox(
                height: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
              ),
              Container(
                width: double.infinity,
                padding: context.responsivePadding(
                  mobilePortrait: 0.03,
                  mobileLandscape: 0.025,
                  tabletPortrait: 0.035,
                  tabletLandscape: 0.03,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A4FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF8A4FFF).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _selectedModel.description,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.035,
                      mobileLandscape: 0.028,
                      tabletPortrait: 0.03,
                      tabletLandscape: 0.025,
                    ),
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
            
            // Technical information
            if (widget.showTechnicalInfo) ...[
              SizedBox(
                height: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
              ),
              ExpansionTile(
                title: Text(
                  'Informations techniques',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.04,
                      mobileLandscape: 0.032,
                      tabletPortrait: 0.035,
                      tabletLandscape: 0.03,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                      context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      ),
                    ),
                    child: Text(
                      _selectedModel.technicalInfo,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          mobilePortrait: 0.035,
                          mobileLandscape: 0.028,
                          tabletPortrait: 0.03,
                          tabletLandscape: 0.025,
                        ),
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
}
