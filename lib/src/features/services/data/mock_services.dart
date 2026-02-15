import 'package:motor_ambos/src/features/services/domain/service_provider.dart';

List<ServiceProvider> mockServices = [
  // Mechanics
  ServiceProvider(
    id: 'm1',
    name: 'Auto Precision Gh',
    category: ServiceCategory.mechanic,
    address: 'Sakumono, Tema',
    phone: '+233 24 456 7890',
    imageUrl: 'assets/images/services/mechanic1.jpg',
    rating: 4.8,
    isVerified: true,
    reviewCount: 154,
    distance: '3.2 km',
    about: 'Ghana’s leading auto repair franchise. Computer diagnostics, suspension repairs, full engine overhaul, and electrical fault tracing. We use genuine parts and offer a 6-month warranty on workmanship.',
    services: [
      ServiceItem(name: 'Full Diagnostics', price: 150),
      ServiceItem(name: 'Engine Oil Change', price: 200, duration: '45 mins'),
      ServiceItem(name: 'Brake Pad Replacement', price: 120),
      ServiceItem(name: 'Air Conditioning Re-gas', price: 250),
    ],
  ),
  ServiceProvider(
    id: 'm2',
    name: 'Benz Specialists Accra',
    category: ServiceCategory.mechanic,
    address: 'East Legon, near America House',
    phone: '+233 20 123 4567',
    imageUrl: 'assets/images/services/mechanic2.jpg',
    rating: 4.9,
    reviewCount: 312,
    isVerified: true,
    distance: '6.8 km',
    about: 'Factory-trained Mercedes-Benz technicians. We specialize in A & B Service, transmission flush, suspension (struts/airmatic), and complex electronic troubleshooting.',
    services: [
      ServiceItem(name: 'Service A (Minor)', price: 450, duration: '1h 30m'),
      ServiceItem(name: 'Service B (Major)', price: 850, duration: '3h'),
      ServiceItem(name: 'Suspension Check', price: 100),
    ],
  ),
  
  // Detailers
  ServiceProvider(
    id: 'd1',
    name: 'Pristine Auto Spa',
    category: ServiceCategory.detailer,
    address: 'Airport Residential',
    phone: '+233 55 987 6543',
    imageUrl: 'assets/images/services/detailer1.jpg',
    rating: 4.7,
    reviewCount: 89,
    distance: '1.5 km',
    about: 'Premium detailing for luxury vehicles. Paint correction, ceramic coating, leather restoration, and deep interior steam cleaning.',
    services: [
      ServiceItem(name: 'Full Interior Detail', price: 300, duration: '2h'),
      ServiceItem(name: 'Exterior Wash & Wax', price: 150),
      ServiceItem(name: 'Ceramic Coating (3yr)', price: 1500),
    ],
  ),
  
  // Car Wash
  ServiceProvider(
    id: 'cw1',
    name: 'Sparkle Wash & Go',
    category: ServiceCategory.carWash,
    address: 'Spintex Road',
    phone: '+233 27 555 1111',
    imageUrl: 'assets/images/services/carwash1.jpg',
    rating: 4.2,
    reviewCount: 220,
    distance: '4.0 km',
    about: 'Fast, efficient, and affordable car wash. We use filtered water and high-quality snow foam to prevent swirl marks.',
    services: [
      ServiceItem(name: 'Express Wash', price: 30),
      ServiceItem(name: 'Full Wash', price: 50),
      ServiceItem(name: 'Engine Wash', price: 40),
    ],
  ),
  
  // Roadworthy
  ServiceProvider(
    id: 'rw1',
    name: 'DVLA Approved Center - 37',
    category: ServiceCategory.roadworthy,
    address: '37 Military Hospital Road',
    phone: '+233 30 277 1234',
    imageUrl: 'assets/images/services/dvla.jpg',
    rating: 4.0,
    reviewCount: 56,
    isVerified: true,
    distance: '2.8 km',
    about: 'Certified DVLA vehicle inspection center. Fast-track service available. We inspect lights, brakes, suspension, and emissions.',
    services: [
      ServiceItem(name: 'Roadworthy Renewal', price: 150),
      ServiceItem(name: 'New Vehicle Registration', price: 450),
    ],
  ),
  
  // Insurance
  ServiceProvider(
    id: 'ins1',
    name: 'SIC Insurance',
    category: ServiceCategory.insurance,
    address: 'Ring Road Central, Accra',
    phone: '+233 30 222 1234',
    imageUrl: 'assets/images/logos/sic.png',
    rating: 4.5,
    reviewCount: 1200,
    isVerified: true,
    distance: '5.1 km',
    about: 'Ghana’s leading insurance provider. Get comprehensive or third-party coverage instantly. Claim processing within 48 hours.',
    services: [
      ServiceItem(name: 'Third Party (Saloon)', price: 489),
      ServiceItem(name: 'Comprehensive Quote', price: 0),
    ],
  ),
];
