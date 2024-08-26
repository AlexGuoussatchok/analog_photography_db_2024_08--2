class InventoryChemicals {
  int? id;
  String chemical;
  String? type;
  double? pricePaid;
  String condition;
  double? averagePrice;
  String? comments;

  InventoryChemicals({
    this.id,
    required this.chemical,
    this.type,
    this.pricePaid,
    required this.condition,
    this.averagePrice,
    this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chemical': chemical,
      'type': type,
      'price_paid': pricePaid,
      'condition': condition,
      'average_price': averagePrice,
      'comments': comments,
    };
  }

  static InventoryChemicals fromMap(Map<String, dynamic> map) {
    return InventoryChemicals(
      id: map['id'],
      chemical: map['chemical'],
      type: map['type'],
      pricePaid: map['price_paid'],
      condition: map['condition'],
      averagePrice: map['average_price'],
      comments: map['comments'],
    );
  }
}
