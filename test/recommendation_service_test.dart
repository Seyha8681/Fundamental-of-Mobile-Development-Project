import 'package:flutter_test/flutter_test.dart';
import 'package:project/model/food_item.dart';
import 'package:project/model/meal.dart';
import 'package:project/service/inventory_service.dart';
import 'package:project/service/meal_service.dart';
import 'package:project/service/recommendation_service.dart';

FoodItem _food(String id, {int expiresInDays = 10, double quantity = 2}) =>
    FoodItem(
      id: id,
      name: id,
      category: 'Pantry',
      quantity: quantity,
      unit: 'piece',
      purchaseDate: DateTime(2026, 11, 1),
      expirationDate: DateTime(2026, 11, 16).add(Duration(days: expiresInDays)),
    );

Meal _meal(String id, List<IngredientRequirement> ingredients) =>
    Meal(id: id, name: id, ingredients: ingredients);

void main() {
  test('recommends a meal using inventory and reports missing ingredients', () {
    final tomato = _food('tomato');
    final onion = _food('onion');
    final inventory = InventoryService()..addFood(tomato);
    final meals = MealService()
      ..createMeal(
        _meal('soup', [
          IngredientRequirement(foodItem: tomato, requiredQuantity: 1),
          IngredientRequirement(foodItem: onion, requiredQuantity: 1),
        ]),
      );
    final service = RecommendationService(
      inventoryService: inventory,
      mealService: meals,
    );

    final result = service.recommendMeals(onDate: DateTime(2026, 11, 16));

    expect(result, hasLength(1));
    expect(result.single.canBePrepared, isFalse);
    expect(result.single.availableIngredients.map((item) => item.name), ['tomato']);
    expect(result.single.missingIngredients.map((item) => item.name), ['onion']);
    expect(result.single.reason, contains('onion'));
  });

  test('prioritizes meals that use soon-expiring food', () {
    final expiring = _food('expiring', expiresInDays: 1);
    final later = _food('later', expiresInDays: 20);
    final inventory = InventoryService()
      ..addFood(expiring)
      ..addFood(later);
    final meals = MealService()
      ..createMeal(
        _meal('later-meal', [
          IngredientRequirement(foodItem: later, requiredQuantity: 1),
        ]),
      )
      ..createMeal(
        _meal('expiring-meal', [
          IngredientRequirement(foodItem: expiring, requiredQuantity: 1),
        ]),
      );
    final service = RecommendationService(
      inventoryService: inventory,
      mealService: meals,
    );

    expect(
      service.recommendMeals(onDate: DateTime(2026, 11, 16)).first.meal.id,
      'expiring-meal',
    );
    expect(
      service
          .getMealsUsingExpiringFood(onDate: DateTime(2026, 11, 16))
          .map((item) => item.meal.id),
      ['expiring-meal'],
    );
  });

  test('returns no suggestions when inventory has no matching ingredient', () {
    final unrelated = _food('unrelated');
    final needed = _food('needed');
    final inventory = InventoryService()..addFood(unrelated);
    final meals = MealService()
      ..createMeal(
        _meal('meal', [
          IngredientRequirement(foodItem: needed, requiredQuantity: 1),
        ]),
      );
    final service = RecommendationService(
      inventoryService: inventory,
      mealService: meals,
    );

    expect(service.recommendMeals(onDate: DateTime(2026, 11, 16)), isEmpty);
  });
}
