import '../model/meal.dart';
import 'inventory_service.dart';

class MealService {
  final Map<String, Meal> _mealsById = {};

  Meal createMeal(Meal meal) {
    _validateMeal(meal);
    if (_mealsById.containsKey(meal.id)) {
      throw ArgumentError('Meal ID "${meal.id}" already exists.');
    }
    _mealsById[meal.id] = meal;
    return meal;
  }

  Meal updateMeal(Meal meal) {
    if (!_mealsById.containsKey(meal.id)) {
      throw ArgumentError('Meal ID "${meal.id}" does not exist.');
    }
    _validateMeal(meal);
    _mealsById[meal.id] = meal;
    return meal;
  }

  bool deleteMeal(String id) => _mealsById.remove(id) != null;

  List<Meal> getAllMeals() => List.unmodifiable(_mealsById.values);

  bool checkAvailableIngredients(String mealId, InventoryService inventory) {
    final meal = _mealsById[mealId];
    if (meal == null) {
      throw ArgumentError('Meal ID "$mealId" does not exist.');
    }
    return meal.areAllIngredientsAvailable(inventory.getAvailableQuantities());
  }

  void _validateMeal(Meal meal) {
    if (meal.name.trim().isEmpty) {
      throw ArgumentError('Meal name cannot be empty.');
    }
    if (meal.ingredients.isEmpty) {
      throw ArgumentError('A meal must have at least one ingredient.');
    }
    if (meal.ingredients.any(
      (item) => !item.requiredQuantity.isFinite || item.requiredQuantity <= 0,
    )) {
      throw ArgumentError('Required ingredient quantities must be greater than zero.');
    }
  }
}
