import 'package:flutter_test/flutter_test.dart';
import 'package:wellcare_pharmacy/features/inventory/domain/medicine_batch.dart';
import 'package:wellcare_pharmacy/features/pos/domain/pos_cart_item.dart';

void main() {
  group('FEFO Inventory Dispatch Engine', () {
    test('sortFefo orders batches by earliest expiration date first', () {
      final lateBatch = MedicineBatch(
        id: 'B-2',
        medicineName: 'Augmentin 625mg',
        genericFormula: 'Amoxicillin + Clavulanic Acid',
        batchNumber: 'BATCH-LATE',
        expiryDate: DateTime.now().add(const Duration(days: 300)),
        quantityAvailable: 100,
        unitPricePkr: 410.0,
        rackLocation: 'A-01',
      );

      final earlyBatch = MedicineBatch(
        id: 'B-1',
        medicineName: 'Augmentin 625mg',
        genericFormula: 'Amoxicillin + Clavulanic Acid',
        batchNumber: 'BATCH-EARLY',
        expiryDate: DateTime.now().add(const Duration(days: 20)),
        quantityAvailable: 30,
        unitPricePkr: 410.0,
        rackLocation: 'A-01',
      );

      final sorted = MedicineBatch.sortFefo([lateBatch, earlyBatch]);

      expect(sorted.first.batchNumber, 'BATCH-EARLY');
      expect(sorted.first.healthStatus, StockHealthStatus.expiringSoon);
      expect(sorted.last.batchNumber, 'BATCH-LATE');
      expect(sorted.last.healthStatus, StockHealthStatus.healthy);
    });

    test('identifies expired batches for checkout quarantine', () {
      final expiredBatch = MedicineBatch(
        id: 'B-EXP',
        medicineName: 'Risek 40mg',
        genericFormula: 'Omeprazole',
        batchNumber: 'BATCH-EXP',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        quantityAvailable: 15,
        unitPricePkr: 365.0,
        rackLocation: 'C-04',
      );

      expect(expiredBatch.healthStatus, StockHealthStatus.expired);
    });
  });

  group('POS Invoice Calculation Engine', () {
    test('computes subtotal, percentage discount, and net payable accurately', () {
      final batch = MedicineBatch(
        id: 'B-10',
        medicineName: 'Panadol Extra',
        genericFormula: 'Paracetamol + Caffeine',
        batchNumber: 'HLN-01',
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        quantityAvailable: 50,
        unitPricePkr: 100.0,
        rackLocation: 'B-02',
      );

      final invoice = PosInvoice(
        invoiceNumber: 'WC-1001',
        timestamp: DateTime.now(),
        customerName: 'Test Patient',
        items: [PosCartItem(batch: batch, quantity: 3)],
        discountPercent: 10.0,
      );

      expect(invoice.subtotal, 300.0);
      expect(invoice.discountAmount, 30.0);
      expect(invoice.grandTotal, 270.0);
    });
  });
}