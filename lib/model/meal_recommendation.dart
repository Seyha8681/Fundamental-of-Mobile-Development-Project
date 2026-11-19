import 'meal.dart';

class MealRecommendation {
  MealRecommendation({
    required this.meal,
    required List<IngredientRequirement> availableIngredients,
    required List<IngredientRequirement> missingIngredients,
    required this.reason,
  })  : availableIngredients = List.unmodifiable(availableIngredients),
        missingIngredients = List.unmodifiable(missingIngredients);

  final Meal meal;
  final List<IngredientRequirement> availableIngredients;
  final List<IngredientRequirement> missingIngredients;
  final String reason;

  bool get canBePrepared => missingIngredients.isEmpty;
}
