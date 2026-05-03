class ExampleOrder {
  final String seller;
  final String server;
  final String price;
  final String quantity;
  final String status;

  const ExampleOrder({
    required this.seller,
    required this.server,
    required this.price,
    required this.quantity,
    required this.status,
  });

  bool get isOnline => status == 'Online';
}
