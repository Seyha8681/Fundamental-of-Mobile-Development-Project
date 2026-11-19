// Constructor parameters stay public while the mutable fields remain private.
// ignore_for_file: prefer_initializing_formals

class FoodItem {
  FoodItem({
    required this.id,
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required DateTime purchaseDate,
    required DateTime expirationDate,
  })  : _name = name,
        _category = category,
        _quantity = quantity,
        _unit = unit,
        _purchaseDate = purchaseDate,
        _expirationDate = expirationDate;

  final String id;
  String _name;
  String _category;
  double _quantity;
  String _unit;
  DateTime _purchaseDate;
  DateTime _expirationDate;

  String get name => _name;
  String get category => _category;
  double get quantity => _quantity;
  String get unit => _unit;
  DateTime get purchaseDate => _purchaseDate;
  DateTime get expirationDate => _expirationDate;

  void updateInformation({
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expirationDate,
  }) {
    final nextPurchaseDate = purchaseDate ?? _purchaseDate;
    final nextExpirationDate = expirationDate ?? _expirationDate;
    final nextQuantity = quantity ?? _quantity;

    if (!nextQuantity.isFinite || nextQuantity < 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Cannot be negative.');
    }
    if (nextExpirationDate.isBefore(nextPurchaseDate)) {
      throw ArgumentError('Expiration date cannot be before purchase date.');
    }

    _name = name ?? _name;
    _category = category ?? _category;
    _quantity = nextQuantity;
    _unit = unit ?? _unit;
    _purchaseDate = nextPurchaseDate;
    _expirationDate = nextExpirationDate;
  }

  bool isExpired({DateTime? onDate}) {
    final today = _dateOnly(onDate ?? DateTime.now());
    return _dateOnly(expirationDate).isBefore(today);
  }

  bool isExpiringWithin(int days, {DateTime? onDate}) {
    if (days < 0) {
      throw ArgumentError.value(days, 'days', 'Cannot be negative.');
    }
    final today = _dateOnly(onDate ?? DateTime.now());
    final expiry = _dateOnly(expirationDate);
    return !expiry.isBefore(today) &&
        !expiry.isAfter(today.add(Duration(days: days)));
  }

  bool hasAvailableQuantity(double requiredQuantity) =>
      requiredQuantity.isFinite &&
      requiredQuantity > 0 &&
      _quantity >= requiredQuantity;

  void reduceQuantity(double amount) {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be greater than zero.');
    }
    if (amount > _quantity) {
      throw StateError('Cannot use more $name than is available.');
    }
    _quantity -= amount;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
