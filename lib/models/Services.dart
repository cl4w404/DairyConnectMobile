class Services {
  final String title;
  final String photoUrl;

  Services({required this.title, required this.photoUrl});
}

// Creating some sample objects
List<Services> servicesList = [
  Services(
    title: 'Veterinary Services',
    photoUrl: 'https://example.com/veterinary.jpg',
  ),
  Services(
    title: 'Milk Collection',
    photoUrl: 'https://example.com/milk_collection.jpg',
  ),
  Services(
    title: 'Financial Services',
    photoUrl: 'https://example.com/financial_services.jpg',
  ),
  Services(
    title: 'Ad Posting',
    photoUrl: 'https://example.com/ad_posting.jpg',
  ),
  Services(
    title: 'Withdrawal Service',
    photoUrl: 'https://example.com/withdrawal_service.jpg',
  ),
];
