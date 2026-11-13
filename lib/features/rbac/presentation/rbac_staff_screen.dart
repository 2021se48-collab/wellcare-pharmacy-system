import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/pharmacy_role.dart';

class RbacStaffScreen extends StatefulWidget {
  const RbacStaffScreen({super.key});

  @override
  State<RbacStaffScreen> createState() => _RbacStaffScreenState();
}

class _RbacStaffScreenState extends State<RbacStaffScreen> {
  final List<StaffMember> _staff = [
    StaffMember(
      id: 'STF-01',
      fullName: 'Dr. Omar Farooq, Pharm-D',
      licenseNumber: 'PCP-A-19482',
      role: PharmacyRole.chiefPharmacist,
    ),
    StaffMember(
      id: 'STF-02',
      fullName: 'Dr. Ayesha Siddiqui, Pharm-D',
      licenseNumber: 'PCP-A-22109',
      role: PharmacyRole.dispensingPharmacist,
    ),
    StaffMember(
      id: 'STF-03',
      fullName: 'Bilal Ahmad',
      licenseNumber: 'POS-OP-088',
      role: PharmacyRole.posCashier,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Staff & Role-Based Access Control (RBAC)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Enforce DRAP Category-A pharmacist supervision for controlled drugs, batch edits, and discount overrides',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          ..._staff.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.14),
                            child: const Icon(Icons.badge_outlined, color: AppColors.primaryTeal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                Text('Reg / ID: ${member.licenseNumber}  •  ${member.role.badge}'),
                              ],
                            ),
                          ),
                          DropdownButton<PharmacyRole>(
                            value: member.role,
                            onChanged: (newRole) {
                              if (newRole != null) {
                                setState(() => member.role = newRole);
                              }
                            },
                            items: PharmacyRole.values
                                .map((r) => DropdownMenuItem(value: r, child: Text(r.title)))
                                .toList(),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: member.isActive,
                            activeThumbColor: AppColors.primaryTeal,
                            onChanged: (val) => setState(() => member.isActive = val),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _PermissionPill('Controlled Drugs', member.role.canApproveNarcotics),
                          _PermissionPill('Discount Override', member.role.canOverrideDiscount),
                          _PermissionPill('FEFO Batch Edit', member.role.canEditBatches),
                          _PermissionPill('Financial P&L', member.role.canViewFinancials),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionPill extends StatelessWidget {
  final String label;
  final bool granted;

  const _PermissionPill(this.label, this.granted);

  @override
  Widget build(BuildContext context) {
    final color = granted ? AppColors.inStockGreen : AppColors.criticalRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(granted ? Icons.check_circle : Icons.block, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
