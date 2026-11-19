// Constructor parameters stay public while service dependencies remain private.
// ignore_for_file: prefer_initializing_formals

import '../model/food_item.dart';
import '../model/meal.dart';
import '../model/meal_recommendation.dart';
import 'inventory_service.dart';
import 'meal_service.dart';

class RecommendationService {
  RecommendationService({
    required InventoryService inventoryService,
    required MealService mealService,
  })  : _inventoryService = inventoryService,
        _mealService = mealService;

  final InventoryService _inventoryService;
  final MealService _mealService;

  List<MealRecommendation> recommendMeals({
    int expiringWithinDays = 3,
    DateTime? onDate,
  }) {
    if (expiringWithinDays < 0) {
      throw ArgumentError.value(
        expiringWithinDays,
        'expiringWithinDays',
        'Cannot be negative.',
      );
    }
    final foods = _inventoryService.getAllFood();
    final quantities = _inventoryService.getAvailableQuantities();
    final candidates = <_RankedRecommendation>[];

    for (final meal in _mealService.getAllMeals()) {
      final recommendation = _createRecommendation(meal, quantities);
      if (recommendation == null) continue;

      final expiringFood = foods
          .where(
            (food) =>
                food.quantity > 0 &&
                meal.ingredients.any(
                  (ingredient) => ingredient.foodItemId == food.id,
                ) &&
                food.isExpiringWithin(
                  expiringWithinDays,
                  onDate: onDate,
                ),
          )
          .toList()
        ..sort(_compareExpiration);
      candidates.add(
        _RankedRecommendation(
          recommendation,
          expiringFood.isEmpty ? null : expiringFood.first.expirationDate,
        ),
      );
    }

    candidates.sort(_compareRecommendations);
    return List.unmodifiable(
      candidates.map((candidate) => candidate.recommendation),
    );
  }

  List<MealRecommendation> getMealsUsingExpiringFood({
    int withinDays = 7,
    DateTime? onDate,
  }) {
    final expiringIds = _inventoryService
        .getExpiringFood(withinDays: withinDays, onDate: onDate)
        .where((food) => food.quantity > 0)
        .map((food) => food.id)
        .toSet();
    final quantities = _inventoryService.getAvailableQuantities();
    final ranked = <_RankedRecommendation>[];

    for (final meal in _mealService.getAllMeals()) {
      if (!meal.ingredients.any(
        (ingredient) => expiringIds.contains(ingredient.foodItemId),
      )) {
        continue;
      }
      final recommendation = _createRecommendation(meal, quantities);
      if (recommendation == null) continue;
      final earliestExpiration = _inventoryService
          .getExpiringFood(withinDays: withinDays, onDate: onDate)
          .where(
            (food) =>
                expiringIds.contains(food.id) &&
                meal.ingredients.any(
                  (ingredient) => ingredient.foodItemId == food.id,
                ),
          )
          .map((food) => food.expirationDate)
          .reduce((first, second) => first.isBefore(second) ? first : second);
      ranked.add(_RankedRecommendation(recommendation, earliestExpiration));
    }

    ranked.sort(_compareRecommendations);
    return List.unmodifiable(ranked.map((item) => item.recommendation));
  }

  MealRecommendation? _createRecommendation(
    Meal meal,
    Map<String, double> quantities,
  ) {
    final available = <IngredientRequirement>[];
    final missing = <IngredientRequirement>[];
    var hasInventoryRelationship = false;

    for (final ingredient in meal.ingredients) {
      final quantity = quantities[ingredient.foodItemId] ?? 0;
      if (quantity > 0) hasInventoryRelationship = true;
      if (quantity >= ingredient.requiredQuantity) {
        available.add(ingredient);
      } else {
        missing.add(ingredient);
      }
    }
    if (!hasInventoryRelationship) return null;

    final reason = missing.isEmpty
        ? 'All required ingredients are available.'
        : 'Available ingredients match this meal; missing: '
            '${missing.map((item) => item.name).join(', ')}.';
    return MealRecommendation(
      meal: meal,
      availableIngredients: available,
      missingIngredients: missing,
      reason: reason,
    );
  }

  int _compareRecommendations(
    _RankedRecommendation first,
    _RankedRecommendation second,
  ) {
    if (first.expirationDate != null && second.expirationDate != null) {
      final expirationOrder =
          first.expirationDate!.compareTo(second.expirationDate!);
      if (expirationOrder != 0) return expirationOrder;
    } else if (first.expirationDate != null) {
      return -1;
    } else if (second.expirationDate != null) {
      return 1;
    }
    return first.recommendation.missingIngredients.length.compareTo(
      second.recommendation.missingIngredients.length,
    );
  }

  int _compareExpiration(FoodItem first, FoodItem second) =>
      first.expirationDate.compareTo(second.expirationDate);
}

class _RankedRecommendation {
  const _RankedRecommendation(this.recommendation, this.expirationDate);

  final MealRecommendation recommendation;
  final DateTime? expirationDate;
}
