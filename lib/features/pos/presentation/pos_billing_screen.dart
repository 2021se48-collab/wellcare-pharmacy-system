import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../inventory/domain/medicine_batch.dart';
import '../domain/pos_cart_item.dart';

class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({super.key});

  @override
  State<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends State<PosBillingScreen> {
  String _searchQuery = '';
  double _discountPercent = 0.0;
  final TextEditingController _customerController = TextEditingController(text: 'Walk-in Patient');

  final List<MedicineBatch> _catalog = [
    MedicineBatch(
      id: 'B-101',
      medicineName: 'Augmentin 625mg Tab',
      genericFormula: 'Amoxicillin + Clavulanic Acid',
      batchNumber: 'GSK-8841A',
      expiryDate: DateTime.now().add(const Duration(days: 24)),
      quantityAvailable: 42,
      unitPricePkr: 410.0,
      rackLocation: 'A-04',
    ),
    MedicineBatch(
      id: 'B-102',
      medicineName: 'Augmentin 625mg Tab',
      genericFormula: 'Amoxicillin + Clavulanic Acid',
      batchNumber: 'GSK-9102B',
      expiryDate: DateTime.now().add(const Duration(days: 320)),
      quantityAvailable: 120,
      unitPricePkr: 410.0,
      rackLocation: 'A-04',
    ),
    MedicineBatch(
      id: 'B-103',
      medicineName: 'Panadol Extra 500mg',
      genericFormula: 'Paracetamol + Caffeine',
      batchNumber: 'HLN-4409',
      expiryDate: DateTime.now().add(const Duration(days: 195)),
      quantityAvailable: 10,
      unitPricePkr: 45.0,
      rackLocation: 'B-01',
    ),
    MedicineBatch(
      id: 'B-105',
      medicineName: 'Brufen 400mg Tab',
      genericFormula: 'Ibuprofen',
      batchNumber: 'ABT-3318',
      expiryDate: DateTime.now().add(const Duration(days: 140)),
      quantityAvailable: 65,
      unitPricePkr: 95.0,
      rackLocation: 'B-07',
    ),
    MedicineBatch(
      id: 'B-104',
      medicineName: 'Risek 40mg Caps',
      genericFormula: 'Omeprazole',
      batchNumber: 'GTZ-7720',
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      quantityAvailable: 18,
      unitPricePkr: 365.0,
      rackLocation: 'C-12',
    ),
  ];

  final List<PosCartItem> _cart = [];

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _addToCart(MedicineBatch batch) {
    if (batch.healthStatus == StockHealthStatus.expired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.criticalRed,
          content: Text('BLOCKED: Batch ${batch.batchNumber} (${batch.medicineName}) is EXPIRED.'),
        ),
      );
      return;
    }

    final existingIndex = _cart.indexWhere((item) => item.batch.id == batch.id);
    setState(() {
      if (existingIndex >= 0) {
        if (_cart[existingIndex].quantity < batch.quantityAvailable) {
          _cart[existingIndex].quantity++;
        }
      } else if (batch.quantityAvailable > 0) {
        _cart.add(PosCartItem(batch: batch, quantity: 1));
      }
    });
  }

  void _completeCheckout() {
    if (_cart.isEmpty) return;

    final invoice = PosInvoice(
      invoiceNumber: 'WC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      timestamp: DateTime.now(),
      customerName: _customerController.text.trim().isEmpty ? 'Walk-in Patient' : _customerController.text.trim(),
      items: _cart.map((e) => PosCartItem(batch: e.batch, quantity: e.quantity)).toList(),
      discountPercent: _discountPercent,
    );

    setState(() {
      for (final item in _cart) {
        final idx = _catalog.indexWhere((b) => b.id == item.batch.id);
        if (idx >= 0) {
          final old = _catalog[idx];
          _catalog[idx] = MedicineBatch(
            id: old.id,
            medicineName: old.medicineName,
            genericFormula: old.genericFormula,
            batchNumber: old.batchNumber,
            expiryDate: old.expiryDate,
            quantityAvailable: old.quantityAvailable - item.quantity,
            unitPricePkr: old.unitPricePkr,
            rackLocation: old.rackLocation,
          );
        }
      }
      _cart.clear();
      _discountPercent = 0.0;
    });

    _showThermalReceiptDialog(invoice);
  }

  void _showThermalReceiptDialog(PosInvoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.primaryTeal),
            SizedBox(width: 8),
            Text('80mm Thermal Receipt Preview'),
          ],
        ),
        content: SizedBox(
          width: 340,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7),
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.black87,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'WELLCARE PHARMACY & CLINIC',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Text(
                    'DRAP Licensed Retail Pharmacy\nLahore, Punjab • Tel: 042-3555-0192',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  ),
                  const Divider(color: Colors.black54),
                  Text('Invoice : ${invoice.invoiceNumber}'),
                  Text('Patient : ${invoice.customerName}'),
                  Text('Date    : ${invoice.timestamp.toString().substring(0, 16)}'),
                  const Divider(color: Colors.black54),
                  ...invoice.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${item.batch.medicineName} [${item.batch.batchNumber}] x${item.quantity}'),
                          ),
                          Text('PKR ${item.lineTotal.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.black54),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('PKR ${invoice.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                  if (invoice.discountPercent > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount (${invoice.discountPercent.toStringAsFixed(0)}%):'),
                        Text('- PKR ${invoice.discountAmount.toStringAsFixed(0)}'),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NET PAYABLE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        'PKR ${invoice.grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'FEFO Verified • Thank you for visiting WellCare!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sent ${invoice.invoiceNumber} to thermal printer queue.')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedCatalog = MedicineBatch.sortFefo(_catalog).where((b) {
      return b.medicineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.genericFormula.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.batchNumber.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final liveInvoice = PosInvoice(
      invoiceNumber: 'DRAFT',
      timestamp: DateTime.now(),
      customerName: _customerController.text,
      items: _cart,
      discountPercent: _discountPercent,
    );

    final isWide = MediaQuery.of(context).size.width >= 950;

    final catalogPane = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Scan barcode or search medicine / formula / batch...',
            prefixIcon: const Icon(Icons.qr_code_scanner),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: sortedCatalog.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final batch = sortedCatalog[index];
              final isExpired = batch.healthStatus == StockHealthStatus.expired;
              final isExpiringSoon = batch.healthStatus == StockHealthStatus.expiringSoon;

              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          batch.medicineName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (isExpired)
                        const Chip(
                          label: Text('EXPIRED', style: TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: AppColors.criticalRed,
                          visualDensity: VisualDensity.compact,
                        )
                      else if (isExpiringSoon)
                        const Chip(
                          label: Text('FEFO 1st', style: TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: AppColors.expiringAmber,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'Batch: ${batch.batchNumber} • Stock: ${batch.quantityAvailable} • PKR ${batch.unitPricePkr.toStringAsFixed(0)}',
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: (isExpired || batch.quantityAvailable == 0) ? null : () => _addToCart(batch),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Add'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    final cartPane = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Current Prescription / Cart', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _customerController,
              decoration: InputDecoration(
                labelText: 'Patient / Customer Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Select medicines from the FEFO catalog to begin billing.'))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.batch.medicineName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Batch ${item.batch.batchNumber} • PKR ${item.batch.unitPricePkr.toStringAsFixed(0)} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                    } else {
                                      _cart.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: item.quantity < item.batch.quantityAvailable
                                    ? () => setState(() => item.quantity++)
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              children: [
                const Text('Discount:'),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('0%'),
                  selected: _discountPercent == 0,
                  onSelected: (_) => setState(() => _discountPercent = 0),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('5%'),
                  selected: _discountPercent == 5,
                  onSelected: (_) => setState(() => _discountPercent = 5),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('10%'),
                  selected: _discountPercent == 10,
                  onSelected: (_) => setState(() => _discountPercent = 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(
                  'PKR ${liveInvoice.grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _cart.isEmpty ? null : _completeCheckout,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Complete Sale & Generate Receipt'),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: catalogPane),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: cartPane),
              ],
            )
          : Column(
              children: [
                Expanded(child: catalogPane),
                const SizedBox(height: 12),
                Expanded(child: cartPane),
              ],
            ),
    );
  }
}
