// Constructor parameters stay public while the mutable fields remain private.
// ignore_for_file: prefer_initializing_formals

import 'food_item.dart';

class IngredientRequirement {
  const IngredientRequirement({
    required this.foodItem,
    required this.requiredQuantity,
  });

  final FoodItem foodItem;
  final double requiredQuantity;

  String get foodItemId => foodItem.id;
  String get name => foodItem.name;
}

class Meal {
  Meal({
    required this.id,
    required String name,
    required List<IngredientRequirement> ingredients,
    String? preparationInstructions,
  })  : _name = name,
        _ingredients = List.of(ingredients),
        _preparationInstructions = preparationInstructions;

  final String id;
  String _name;
  final List<IngredientRequirement> _ingredients;
  String? _preparationInstructions;

  String get name => _name;
  String? get preparationInstructions => _preparationInstructions;
  List<IngredientRequirement> get ingredients =>
      List.unmodifiable(_ingredients);

  void updateInformation({
    String? name,
    List<IngredientRequirement>? ingredients,
    String? preparationInstructions,
  }) {
    _name = name ?? _name;
    if (ingredients != null) {
      _ingredients
        ..clear()
        ..addAll(ingredients);
    }
    if (preparationInstructions != null) {
      _preparationInstructions = preparationInstructions;
    }
  }

  void addIngredient(IngredientRequirement ingredient) {
    _ingredients.add(ingredient);
  }

  bool removeIngredient(String foodItemId) {
    final previousLength = _ingredients.length;
    _ingredients.removeWhere((item) => item.foodItemId == foodItemId);
    return _ingredients.length < previousLength;
  }

  bool areAllIngredientsAvailable(Map<String, double> availableQuantities) =>
      _ingredients.every(
        (ingredient) =>
            (availableQuantities[ingredient.foodItemId] ?? 0) >=
            ingredient.requiredQuantity,
      );
}
