class Service {
  final String title;
  final String photoUrl;

  Service({required this.title, required this.photoUrl});
}

// Creating some sample objects
List<Service> servicesList = [
  Service(
    title: 'Veterinary Services',
    photoUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fvet-mkononi.co.ke%2Fcategory%2Fvets%2F&psig=AOvVaw0icO85ubL_q9cKG-6Mq2ku&ust=1732259665841000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOCOzqTw7IkDFQAAAAAdAAAAABAE',
  ),
  Service(
    title: 'Milk Collection',
    photoUrl: 'https://example.com/milk_collection.jpg',
  ),
  Service(
    title: 'Financial Services',
    photoUrl: 'https://example.com/financial_services.jpg',
  ),
  Service(
    title: 'Feed Services',
    photoUrl: 'https://example.com/ad_posting.jpg',
  ),
  Service(
    title: 'Withdrawal Service',
    photoUrl: 'https://example.com/withdrawal_service.jpg',
  ),
];
