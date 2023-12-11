class Guide {
  String codebar;
  bool availableForDelivery;
  bool delivered;

  Guide({required this.codebar, required this.availableForDelivery, required this.delivered});

  // Factory method para crear una instancia de Guide desde un mapa
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      codebar: json['Barcode'],
      availableForDelivery: json['AvailableForDelivery'],
      delivered: json['Delivered'],
    );
  }
}