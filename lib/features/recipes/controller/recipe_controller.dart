import 'package:flutter/foundation.dart';
import '../../../core/models/recipe_model.dart';

/// Controller for the Recipe screen.
class RecipeController extends ChangeNotifier {
  List<RecipeModel> _recipes = const [
    RecipeModel(
      id: 'R001',
      name: 'Standard PVC 6mm',
      tubeSize: '6mm',
      material: 'Silicone (Liveo™ Pharma 50)',
      targetTemperature: 165,
      sealTimeMs: 3500,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R002',
      name: 'Standard PVC 8mm',
      tubeSize: '8mm',
      material: 'Silicone (Pumpsil®)',
      targetTemperature: 170,
      sealTimeMs: 4000,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R003',
      name: 'TPE 10mm',
      tubeSize: '10mm',
      material: 'TPE (AdvantaFlex®)',
      targetTemperature: 155,
      sealTimeMs: 4500,
      isLocked: true,
    ),
    RecipeModel(
      id: 'R004',
      name: 'Tube 1/8" × 1/4"',
      tubeSize: '1/8" × 1/4"',
      material: 'Silicone (STHT-C®)',
      targetTemperature: 160,
      sealTimeMs: 3000,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R005',
      name: 'Tube 1/4" × 3/8"',
      tubeSize: '1/4" × 3/8"',
      material: 'TPE (C-Flex®)',
      targetTemperature: 160,
      sealTimeMs: 3000,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R006',
      name: 'Tube 1/4" × 7/16"',
      tubeSize: '1/4" × 7/16"',
      material: 'TPE (Tuflux® TPE)',
      targetTemperature: 160,
      sealTimeMs: 3000,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R007',
      name: 'Tube 3/8" × 5/8"',
      tubeSize: '3/8" × 5/8"',
      material: 'Silicone (Liveo™ Pharma 50)',
      targetTemperature: 160,
      sealTimeMs: 3000,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R008',
      name: 'Tube 1/2" × 3/4"',
      tubeSize: '1/2" × 3/4"',
      material: 'Silicone (Pumpsil®)',
      targetTemperature: 160,
      sealTimeMs: 3000,
      isLocked: false,
    ),
    RecipeModel(
      id: 'R009',
      name: 'Tube 3/4" × 1"',
      tubeSize: '3/4" × 1"',
      material: 'Silicone (STHT-C®)',
      targetTemperature: 160,
      sealTimeMs: 3000,
      isLocked: false,
    ),
  ];

  List<RecipeModel> get recipes => _recipes;

  RecipeModel? _selected;
  RecipeModel? get selected => _selected;

  RecipeController() {
    _selected = _recipes.first;
  }

  void select(RecipeModel recipe) {
    _selected = recipe;
    notifyListeners();
  }
}
