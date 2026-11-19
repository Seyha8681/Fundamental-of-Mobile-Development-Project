import 'package:flutter_test/flutter_test.dart';
import 'package:project/model/food_item.dart';
import 'package:project/model/meal.dart';
import 'package:project/service/inventory_service.dart';
import 'package:project/service/meal_service.dart';

FoodItem _food() => FoodItem(
      id: 'egg',
      name: 'Egg',
      category: 'Dairy',
      quantity: 3,
      unit: 'piece',
      purchaseDate: DateTime(2026, 11, 1),
      expirationDate: DateTime(2026, 11, 20),
    );

Meal _meal(FoodItem item, {double quantity = 2}) => Meal(
      id: 'omelette',
      name: 'Omelette',
      ingredients: [
        IngredientRequirement(foodItem: item, requiredQuantity: quantity),
      ],
    );

void main() {
  group('MealService', () {
    test('creates a meal with an ingredient', () {
      final service = MealService();
      final meal = _meal(_food());

      expect(service.createMeal(meal), same(meal));
      expect(service.getAllMeals(), [same(meal)]);
    });

    test('rejects meals without ingredients or valid quantities', () {
      final service = MealService();
      expect(
        () => service.createMeal(Meal(id: 'empty', name: 'Empty', ingredients: [])),
        throwsArgumentError,
      );
      expect(
        () => service.createMeal(_meal(_food(), quantity: 0)),
        throwsArgumentError,
      );
    });

    test('checks ingredient quantities against inventory', () {
      final inventory = InventoryService()..addFood(_food());
      final meals = MealService()..createMeal(_meal(_food()));
      final shortInventory = InventoryService()
        ..addFood(
          FoodItem(
            id: 'egg',
            name: 'Egg',
            category: 'Dairy',
            quantity: 1,
            unit: 'piece',
            purchaseDate: DateTime(2026, 11, 1),
            expirationDate: DateTime(2026, 11, 20),
          ),
        );

      expect(meals.checkAvailableIngredients('omelette', inventory), isTrue);
      expect(meals.checkAvailableIngredients('omelette', shortInventory), isFalse);
    });
  });
}
