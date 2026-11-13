import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topMedicines = [
      ('Augmentin 625mg Tab', '142 strips', 'PKR 58,220', 0.88),
      ('Risek 40mg Caps', '98 boxes', 'PKR 35,770', 0.64),
      ('Panadol Extra 500mg', '310 strips', 'PKR 13,950', 0.45),
      ('Brufen 400mg Tab', '115 strips', 'PKR 10,925', 0.36),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Executive Pharmacy Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time revenue, gross margin, and FEFO expiry-loss prevention metrics',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: const [
              _MetricCard(
                title: 'Today Net Sales',
                value: 'PKR 118,865',
                delta: '+14.2% vs yesterday',
                icon: Icons.payments_outlined,
                color: AppColors.primaryTeal,
              ),
              _MetricCard(
                title: 'Gross Profit Margin',
                value: '24.8%',
                delta: 'PKR 29,478 net margin',
                icon: Icons.trending_up,
                color: AppColors.inStockGreen,
              ),
              _MetricCard(
                title: 'FEFO Expiry Loss Saved',
                value: 'PKR 42,600',
                delta: '19 near-expiry batches dispatched first',
                icon: Icons.verified_outlined,
                color: AppColors.expiringAmber,
              ),
              _MetricCard(
                title: 'Prescriptions Filled',
                value: '84',
                delta: 'Avg basket: PKR 1,415',
                icon: Icons.receipt_long_outlined,
                color: Color(0xFF3B82F6),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Dispensed Formulations (This Week)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  ...topMedicines.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${item.$2}  •  ${item.$3}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: item.$4,
                              minHeight: 8,
                              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.14),
                    child: Icon(icon, size: 18, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 4),
              Text(delta, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
