import 'package:intl/intl.dart';

class InventoryFlashes {
  int? id;
  String brand;
  String model;
  String? serialNumber;
  DateTime? purchaseDate;
  double? pricePaid;
  String condition;
  double? averagePrice;
  String? comments;

  InventoryFlashes({
    this.id,
    required this.brand,
    required this.model,
    this.serialNumber,
    this.purchaseDate,
    this.pricePaid,
    required this.condition,
    this.averagePrice,
    this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'purchase_date': purchaseDate != null ? DateFormat('yyyy-MM-dd').format(purchaseDate!) : null,
      'price_paid': pricePaid,
      'condition': condition,
      'average_price': averagePrice,
      'comments': comments,
    };
  }

  static InventoryFlashes fromMap(Map<String, dynamic> map) {
    return InventoryFlashes(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      serialNumber: map['serial_number'],
      purchaseDate: map['purchase_date'] != null ? DateFormat('yyyy-MM-dd').parse(map['purchase_date']) : null,
      pricePaid: map['price_paid'],
      condition: map['condition'],
      averagePrice: map['average_price'],
      comments: map['comments'],
    );
  }
}
