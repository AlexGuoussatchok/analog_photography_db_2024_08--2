import 'package:intl/intl.dart';

class InventoryCamera {
  int? id;
  String brand;
  String model;
  String? serialNumber;
  DateTime? purchaseDate;
  double? pricePaid;
  String? condition;
  DateTime? filmLoadDate;
  String? filmLoaded;
  double? averagePrice;
  String? comments;

  InventoryCamera({
    this.id,
    required this.brand,
    required this.model,
    this.serialNumber,
    this.purchaseDate,
    this.pricePaid,
    this.condition,
    this.filmLoadDate,
    this.filmLoaded,
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
      'film_load_date': filmLoadDate != null ? DateFormat('yyyy-MM-dd').format(filmLoadDate!) : null,
      'film_loaded': filmLoaded,
      'average_price': averagePrice,
      'comments': comments,
    };
  }

  static InventoryCamera fromMap(Map<String, dynamic> map) {
    return InventoryCamera(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      serialNumber: map['serial_number'],
      purchaseDate: map['purchase_date'] != null ? DateFormat('yyyy-MM-dd').parse(map['purchase_date']) : null,
      pricePaid: map['price_paid'],
      condition: map['condition'],
      filmLoadDate: map['film_load_date'] != null ? DateFormat('yyyy-MM-dd').parse(map['film_load_date']) : null,
      filmLoaded: map['film_loaded'],
      averagePrice: map['average_price'],
      comments: map['comments'],
    );
  }
}
