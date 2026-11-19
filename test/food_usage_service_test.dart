import 'package:flutter_test/flutter_test.dart';
import 'package:project/model/food_item.dart';
import 'package:project/model/meal.dart';
import 'package:project/service/food_usage_service.dart';
import 'package:project/service/inventory_service.dart';
import 'package:project/service/meal_service.dart';

void main() {
  late InventoryService inventory;
  late MealService meals;
  late FoodUsageService usage;

  setUp(() {
    inventory = InventoryService()
      ..addFood(
        FoodItem(
          id: 'tomato',
          name: 'Tomato',
          category: 'Vegetable',
          quantity: 2,
          unit: 'piece',
          purchaseDate: DateTime(2026, 11, 1),
          expirationDate: DateTime(2026, 11, 20),
        ),
      );
    meals = MealService()
      ..createMeal(
        Meal(
          id: 'soup',
          name: 'Soup',
          ingredients: [
            IngredientRequirement(
              foodItem: inventory.getFoodById('tomato')!,
              requiredQuantity: 1,
            ),
          ],
        ),
      );
    usage = FoodUsageService(inventoryService: inventory, mealService: meals);
  });

  test('records use, reduces inventory, and reports usage information', () {
    final record = usage.recordFoodUsage(
      foodItemId: 'tomato',
      mealId: 'soup',
      quantityUsed: 1,
      usageDate: DateTime(2026, 11, 16),
    );

    expect(inventory.getFoodById('tomato')!.quantity, 1);
    expect(record.usageInformation, contains('Tomato'));
    expect(record.calculateUsagePercentage(), 50);
    expect(usage.getUsageByMeal('soup'), [same(record)]);
  });

  test('inventory can become exactly zero after use', () {
    usage.recordFoodUsage(
      foodItemId: 'tomato',
      mealId: 'soup',
      quantityUsed: 2,
    );

    expect(inventory.getFoodById('tomato')!.quantity, 0);
  });

  test('rejects excessive quantity and unknown food or meal IDs', () {
    expect(
      () => usage.recordFoodUsage(
        foodItemId: 'tomato',
        mealId: 'soup',
        quantityUsed: 3,
      ),
      throwsStateError,
    );
    expect(
      () => usage.recordFoodUsage(
        foodItemId: 'unknown',
        mealId: 'soup',
        quantityUsed: 1,
      ),
      throwsArgumentError,
    );
    expect(
      () => usage.recordFoodUsage(
        foodItemId: 'tomato',
        mealId: 'unknown',
        quantityUsed: 1,
      ),
      throwsArgumentError,
    );
  });

  test('rejects non-positive usage without changing inventory', () {
    expect(
      () => usage.recordFoodUsage(
        foodItemId: 'tomato',
        mealId: 'soup',
        quantityUsed: 0,
      ),
      throwsArgumentError,
    );
    expect(inventory.getFoodById('tomato')!.quantity, 2);
  });
}
