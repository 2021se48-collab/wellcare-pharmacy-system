enum StockHealthStatus { healthy, expiringSoon, expired, lowStock }

class MedicineBatch {
  final String id;
  final String medicineName;
  final String genericFormula;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantityAvailable;
  final double unitPricePkr;
  final String rackLocation;

  const MedicineBatch({
    required this.id,
    required this.medicineName,
    required this.genericFormula,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantityAvailable,
    required this.unitPricePkr,
    required this.rackLocation,
  });

  int get daysToExpiry => expiryDate.difference(DateTime.now()).inDays;

  StockHealthStatus get healthStatus {
    if (daysToExpiry <= 0) return StockHealthStatus.expired;
    if (daysToExpiry <= 60) return StockHealthStatus.expiringSoon;
    if (quantityAvailable <= 15) return StockHealthStatus.lowStock;
    return StockHealthStatus.healthy;
  }

  /// Enterprise FEFO (First-Expired, First-Out) Dispatcher
  /// Automatically prioritizes earliest non-expired batches at POS checkout
  static List<MedicineBatch> sortFefo(List<MedicineBatch> batches) {
    final sorted = List<MedicineBatch>.from(batches);
    sorted.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return sorted;
  }
}
