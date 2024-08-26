import 'package:intl/intl.dart';

class InventoryFilms {
  int? id;
  String brand;
  String name;
  String type;
  String sizeType;
  String? iso;
  String? framesNumber;
  String? expirationDate;
  String? isExpired;
  int? quantity;
  double? averagePrice;
  String? comments;

  InventoryFilms({
    this.id,
    required this.brand,
    required this.name,
    required this.type,
    required this.sizeType,
    this.iso,
    this.framesNumber,
    this.expirationDate,
    this.isExpired,
    this.quantity,
    this.averagePrice,
    this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'type': type,
      'size_type': sizeType,
      'ISO': iso,
      'frames_number': framesNumber,
      'expiration_date': expirationDate,
      'is_expired': isExpired,
      'quantity': quantity,
      'average_price': averagePrice,
      'comments': comments,
    };
  }

  static InventoryFilms fromMap(Map<String, dynamic> map) {
    return InventoryFilms(
      id: map['id'],
      brand: map['brand'],
      name: map['name'],
      type: map['type'],
      sizeType: map['size_type'],
      iso: map['ISO'],
      framesNumber: map['frames_number'],
      expirationDate: map['expiration_date'],
      isExpired: map['is_expired'],
      quantity: map['quantity'],
      averagePrice: map['average_price'],
      comments: map['comments'],
    );
  }
}
