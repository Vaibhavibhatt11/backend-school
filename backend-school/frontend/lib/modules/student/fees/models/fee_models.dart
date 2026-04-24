/// An upcoming fee that the user can pay.
class UpcomingFee {
  const UpcomingFee({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.description,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String? description;
}

/// A paid fee with receipt available for download.
class PaidFee {
  const PaidFee({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidDate,
    this.receiptId,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime paidDate;
  final String? receiptId;
}
