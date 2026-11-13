enum PharmacyRole {
  chiefPharmacist(
    title: 'Chief Pharmacist (Admin)',
    badge: 'DRAP Category-A',
    canApproveNarcotics: true,
    canOverrideDiscount: true,
    canEditBatches: true,
    canViewFinancials: true,
  ),
  dispensingPharmacist(
    title: 'Dispensing Pharmacist',
    badge: 'Licensed RPh',
    canApproveNarcotics: true,
    canOverrideDiscount: false,
    canEditBatches: true,
    canViewFinancials: false,
  ),
  posCashier(
    title: 'POS Billing Cashier',
    badge: 'Counter Staff',
    canApproveNarcotics: false,
    canOverrideDiscount: false,
    canEditBatches: false,
    canViewFinancials: false,
  );

  final String title;
  final String badge;
  final bool canApproveNarcotics;
  final bool canOverrideDiscount;
  final bool canEditBatches;
  final bool canViewFinancials;

  const PharmacyRole({
    required this.title,
    required this.badge,
    required this.canApproveNarcotics,
    required this.canOverrideDiscount,
    required this.canEditBatches,
    required this.canViewFinancials,
  });
}

class StaffMember {
  final String id;
  final String fullName;
  final String licenseNumber;
  PharmacyRole role;
  bool isActive;

  StaffMember({
    required this.id,
    required this.fullName,
    required this.licenseNumber,
    required this.role,
    this.isActive = true,
  });
}
