// Constructor parameters stay public while service dependencies remain private.
// ignore_for_file: prefer_initializing_formals

import '../model/food_usage.dart';
import 'inventory_service.dart';
import 'meal_service.dart';

class FoodUsageService {
  FoodUsageService({
    required InventoryService inventoryService,
    required MealService mealService,
  })  : _inventoryService = inventoryService,
        _mealService = mealService;

  final InventoryService _inventoryService;
  final MealService _mealService;
  final List<FoodUsage> _usageHistory = [];
  int _nextUsageId = 1;

  FoodUsage recordFoodUsage({
    required String foodItemId,
    required String mealId,
    required double quantityUsed,
    DateTime? usageDate,
  }) {
    if (!quantityUsed.isFinite || quantityUsed <= 0) {
      throw ArgumentError.value(
        quantityUsed,
        'quantityUsed',
        'Must be greater than zero.',
      );
    }
    final food = _inventoryService.getFoodById(foodItemId);
    if (food == null) {
      throw ArgumentError('Food ID "$foodItemId" does not exist.');
    }
    final meal = _mealService.getAllMeals().where((item) => item.id == mealId);
    if (meal.isEmpty) {
      throw ArgumentError('Meal ID "$mealId" does not exist.');
    }
    if (!food.hasAvailableQuantity(quantityUsed)) {
      throw StateError('Cannot use more ${food.name} than is available.');
    }

    final quantityBeforeUsage = food.quantity;
    food.reduceQuantity(quantityUsed);
    final usage = FoodUsage(
      id: 'usage-${_nextUsageId++}',
      foodItem: food,
      meal: meal.first,
      quantityUsed: quantityUsed,
      usageDate: usageDate ?? DateTime.now(),
      quantityBeforeUsage: quantityBeforeUsage,
    );
    _usageHistory.add(usage);
    return usage;
  }

  List<FoodUsage> getUsageHistory() => List.unmodifiable(_usageHistory);

  List<FoodUsage> getUsageByMeal(String mealId) => List.unmodifiable(
        _usageHistory.where((usage) => usage.meal.id == mealId),
      );
}
