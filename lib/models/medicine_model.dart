class MedicineModel {
  final String id;
  final String name;
  final String genericName;
  final String category;
  final String manufacturer;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final int minStock;
  final DateTime expiryDate;
  final String prescription;

  MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.manufacturer,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    required this.minStock,
    required this.expiryDate,
    required this.prescription,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'genericName': genericName,
    'category': category,
    'manufacturer': manufacturer,
    'purchasePrice': purchasePrice,
    'sellingPrice': sellingPrice,
    'quantity': quantity,
    'minStock': minStock,
    'expiryDate': expiryDate.toIso8601String(),
    'prescription': prescription,
  };

  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
    id: json['id'],
    name: json['name'],
    genericName: json['genericName'],
    category: json['category'],
    manufacturer: json['manufacturer'],
    purchasePrice: json['purchasePrice'].toDouble(),
    sellingPrice: json['sellingPrice'].toDouble(),
    quantity: json['quantity'],
    minStock: json['minStock'],
    expiryDate: DateTime.parse(json['expiryDate']),
    prescription: json['prescription'],
  );

  bool get isLowStock => quantity <= minStock;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  double get profit => sellingPrice - purchasePrice;
}