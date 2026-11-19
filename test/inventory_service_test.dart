import 'package:flutter_test/flutter_test.dart';
import 'package:project/model/food_item.dart';
import 'package:project/service/inventory_service.dart';

FoodItem food({
  String id = 'milk',
  String name = 'Milk',
  double quantity = 2,
  DateTime? purchaseDate,
  DateTime? expirationDate,
}) {
  final purchase = purchaseDate ?? DateTime(2026, 11, 1);
  return FoodItem(
    id: id,
    name: name,
    category: 'Dairy',
    quantity: quantity,
    unit: 'litre',
    purchaseDate: purchase,
    expirationDate: expirationDate ?? DateTime(2026, 11, 20),
  );
}

void main() {
  group('InventoryService', () {
    test('adds food and returns it in inventory', () {
      final service = InventoryService();
      final milk = food();

      expect(service.addFood(milk), same(milk));
      expect(service.getAllFood(), [same(milk)]);
    });

    test('rejects empty names, non-positive quantities, and duplicate IDs', () {
      final service = InventoryService();
      expect(() => service.addFood(food(name: '  ')), throwsArgumentError);
      expect(() => service.addFood(food(quantity: -1)), throwsArgumentError);
      service.addFood(food());
      expect(() => service.addFood(food()), throwsArgumentError);
    });

    test('rejects expiration before purchase', () {
      final service = InventoryService();
      expect(
        () => service.addFood(
          food(
            purchaseDate: DateTime(2026, 11, 10),
            expirationDate: DateTime(2026, 11, 9),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('search with no match returns an empty list', () {
      final service = InventoryService()..addFood(food());

      expect(service.searchFood('bread'), isEmpty);
    });

    test('includes food expiring today and excludes already expired food', () {
      final service = InventoryService()
        ..addFood(food(id: 'today', expirationDate: DateTime(2026, 11, 16)))
        ..addFood(food(id: 'past', expirationDate: DateTime(2026, 11, 15)));

      expect(
        service.getExpiringFood(onDate: DateTime(2026, 11, 16)).map((item) => item.id),
        ['today'],
      );
      expect(
        food(expirationDate: DateTime(2026, 11, 16))
            .isExpired(onDate: DateTime(2026, 11, 16)),
        isFalse,
      );
    });

    test('searching an empty inventory returns no food', () {
      expect(InventoryService().getAllFood(), isEmpty);
    });
  });
}
