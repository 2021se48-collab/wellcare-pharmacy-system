import '../../inventory/domain/medicine_batch.dart';

class PosCartItem {
  final MedicineBatch batch;
  int quantity;

  PosCartItem({
    required this.batch,
    this.quantity = 1,
  });

  double get lineTotal => batch.unitPricePkr * quantity;
}

class PosInvoice {
  final String invoiceNumber;
  final DateTime timestamp;
  final String customerName;
  final List<PosCartItem> items;
  final double discountPercent;
  final double taxPercent;

  const PosInvoice({
    required this.invoiceNumber,
    required this.timestamp,
    required this.customerName,
    required this.items,
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get grandTotal => taxableAmount + taxAmount;
}
