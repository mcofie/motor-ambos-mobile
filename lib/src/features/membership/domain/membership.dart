class Membership {
  final String id;
  final String tier; // e.g. Basic, Plus, Premium
  final DateTime expiry;
  final DateTime memberSince;
  final int callsUsedThisYear;
  final int includedCallsPerYear;
  final double estimatedSavings;
  final int freeTowRadiusKm;
  final bool prioritySupport;

  const Membership({
    required this.id,
    required this.tier,
    required this.expiry,
    required this.memberSince,
    required this.callsUsedThisYear,
    required this.includedCallsPerYear,
    required this.estimatedSavings,
    required this.freeTowRadiusKm,
    required this.prioritySupport,
  });
}