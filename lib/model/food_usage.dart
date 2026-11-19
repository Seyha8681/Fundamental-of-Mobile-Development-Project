import 'food_item.dart';
import 'meal.dart';

class FoodUsage {
  const FoodUsage({
    required this.id,
    required this.foodItem,
    required this.meal,
    required this.quantityUsed,
    required this.usageDate,
    required this.quantityBeforeUsage,
  });

  final String id;
  final FoodItem foodItem;
  final Meal meal;
  final double quantityUsed;
  final DateTime usageDate;
  final double quantityBeforeUsage;

  double calculateUsagePercentage() =>
      quantityBeforeUsage <= 0 ? 0 : quantityUsed / quantityBeforeUsage * 100;

  String get usageInformation =>
      '$quantityUsed ${foodItem.unit} of ${foodItem.name} used for ${meal.name}';
}
