import '../model/food_item.dart';

class InventoryService {
  final Map<String, FoodItem> _foodById = {};

  FoodItem addFood(FoodItem food) {
    _validateFood(food);
    if (_foodById.containsKey(food.id)) {
      throw ArgumentError('Food ID "${food.id}" already exists.');
    }
    _foodById[food.id] = food;
    return food;
  }

  FoodItem updateFood(FoodItem food) {
    if (!_foodById.containsKey(food.id)) {
      throw ArgumentError('Food ID "${food.id}" does not exist.');
    }
    _validateFood(food);
    _foodById[food.id] = food;
    return food;
  }

  bool deleteFood(String id) => _foodById.remove(id) != null;

  List<FoodItem> getAllFood() => List.unmodifiable(_foodById.values);

  FoodItem? getFoodById(String id) => _foodById[id];

  List<FoodItem> searchFood(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return getAllFood();
    return List.unmodifiable(
      _foodById.values.where(
        (food) => food.name.toLowerCase().contains(normalizedQuery),
      ),
    );
  }

  List<FoodItem> getExpiringFood({
    int withinDays = 7,
    DateTime? onDate,
  }) {
    if (withinDays < 0) {
      throw ArgumentError.value(
        withinDays,
        'withinDays',
        'Cannot be negative.',
      );
    }
    return List.unmodifiable(
      _foodById.values.where(
        (food) => food.isExpiringWithin(withinDays, onDate: onDate),
      ),
    );
  }

  Map<String, double> getAvailableQuantities() => {
        for (final food in _foodById.values) food.id: food.quantity,
      };

  void _validateFood(FoodItem food) {
    if (food.name.trim().isEmpty) {
      throw ArgumentError('Food name cannot be empty.');
    }
    if (!food.quantity.isFinite || food.quantity <= 0) {
      throw ArgumentError.value(
        food.quantity,
        'quantity',
        'Must be greater than zero.',
      );
    }
    if (food.expirationDate.isBefore(food.purchaseDate)) {
      throw ArgumentError('Expiration date cannot be before purchase date.');
    }
  }
}
