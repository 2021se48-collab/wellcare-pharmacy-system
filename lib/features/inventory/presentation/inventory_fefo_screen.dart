import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/medicine_batch.dart';

class InventoryFefoScreen extends StatefulWidget {
  const InventoryFefoScreen({super.key});

  @override
  State<InventoryFefoScreen> createState() => _InventoryFefoScreenState();
}

class _InventoryFefoScreenState extends State<InventoryFefoScreen> {
  String _searchQuery = '';
  StockHealthStatus? _selectedFilter;

  final List<MedicineBatch> _rawBatches = [
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

  @override
  Widget build(BuildContext context) {
    final fefoBatches = MedicineBatch.sortFefo(_rawBatches).where((batch) {
      final matchesSearch = batch.medicineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          batch.genericFormula.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          batch.batchNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == null || batch.healthStatus == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    final expiringCount = _rawBatches.where((b) => b.healthStatus == StockHealthStatus.expiringSoon).length;
    final expiredCount = _rawBatches.where((b) => b.healthStatus == StockHealthStatus.expired).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KpiChip(
                label: 'Total Active Batches',
                value: '${_rawBatches.length}',
                color: AppColors.primaryTeal,
                onTap: () => setState(() => _selectedFilter = null),
              ),
              _KpiChip(
                label: 'Expiring <= 60d (FEFO Priority)',
                value: '$expiringCount',
                color: AppColors.expiringAmber,
                onTap: () => setState(() => _selectedFilter = StockHealthStatus.expiringSoon),
              ),
              _KpiChip(
                label: 'Quarantined / Expired',
                value: '$expiredCount',
                color: AppColors.criticalRed,
                onTap: () => setState(() => _selectedFilter = StockHealthStatus.expired),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search medicine brand, generic formula, or batch #...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: fefoBatches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final batch = fefoBatches[index];
                final badge = _statusBadge(batch.healthStatus);
                final expiryText = batch.daysToExpiry <= 0
                    ? 'EXPIRED (${batch.daysToExpiry.abs()}d ago)'
                    : 'Expires in ${batch.daysToExpiry} days';

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: badge.$2.withValues(alpha: 0.14),
                      child: Icon(Icons.medication_outlined, color: badge.$2),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            batch.medicineName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badge.$2.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge.$1,
                            style: TextStyle(color: badge.$2, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Formula: ${batch.genericFormula}  •  Batch: ${batch.batchNumber}  •  Rack: ${batch.rackLocation}\n'
                        'Qty: ${batch.quantityAvailable} units  •  Price: PKR ${batch.unitPricePkr.toStringAsFixed(0)}  •  $expiryText',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _statusBadge(StockHealthStatus status) {
    return switch (status) {
      StockHealthStatus.healthy => ('FEFO Ready', AppColors.inStockGreen),
      StockHealthStatus.expiringSoon => ('Dispatch First (FEFO)', AppColors.expiringAmber),
      StockHealthStatus.expired => ('Blocked - Expired', AppColors.criticalRed),
      StockHealthStatus.lowStock => ('Low Stock', AppColors.expiringAmber),
    };
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _KpiChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(10),
          color: color.withValues(alpha: 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
