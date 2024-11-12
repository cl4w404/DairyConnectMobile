class Transactions {
  final int id;
  final String transactionId;
  final double liters;
  final bool status;
  final String date;

  Transactions({
    required this.id,
    required this.transactionId,
    required this.liters,
    required this.status,
    required this.date,
  });

  // A factory constructor to create an instance of Transaction from JSON
  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      id: json['id'],
      transactionId: json['transactionId'],
      liters: json['liters'].toDouble(), // convert to double
      status: json['status'],
      date: json['date'],
    );
  }
}