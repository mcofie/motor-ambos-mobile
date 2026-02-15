
enum ServiceCategory {
  mechanic('Mechanics', 'Expert repairs & diagnostics'),
  detailer('Detailers', 'Deep cleaning & polishing'),
  carWash('Car Wash', 'Quick & premium washes'),
  roadworthy('Roadworthy', 'Certified inspection centers'),
  insurance('Insurance', 'Coverage & renewals');

  final String label;
  final String description;
  const ServiceCategory(this.label, this.description);
}

class ServiceItem {
  final String name;
  final double price;
  final String? duration;

  const ServiceItem({required this.name, required this.price, this.duration});
}

class ServiceProvider {
  final String id;
  final String name;
  final ServiceCategory category;
  final String address;
  final String phone;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final String openHours;
  final String distance;
  final String about;
  final List<String> galleryImages;
  final List<ServiceItem> services;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.imageUrl,
    this.rating = 4.5,
    this.reviewCount = 50,
    this.isVerified = false,
    this.openHours = '8:00 AM - 5:00 PM',
    this.distance = '2.5 km',
    this.about = 'Providing excellent service for over 5 years. Specialized in all vehicle types.',
    this.galleryImages = const [],
    this.services = const [],
  });
}
