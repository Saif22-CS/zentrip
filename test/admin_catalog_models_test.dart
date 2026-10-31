import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/models/attraction_model.dart';
import 'package:zentrip/models/travel_package_model.dart';

void main() {
  test('monument model maps admin fields onto the customer attraction schema',
      () {
    final monument = AttractionModel.fromJson({
      'id': 'monument-1',
      'title': 'Leptis Magna',
      'location': 'Khoms, Libya',
      'category_tag': 'Historical',
      'category': 'landmark',
      'rating': '4.9',
      'review_count': 3120,
      'description': 'A Roman city',
      'working_hours': '8:00 AM - 5:00 PM',
      'best_time_to_visit': 'Oct - Apr',
      'entry_fee': '5',
      'tags': ['Theatre', 'Market'],
      'image_url': 'https://example.com/leptis.jpg',
    });

    expect(monument.title, 'Leptis Magna');
    expect(monument.location, 'Khoms, Libya');
    expect(monument.categoryLabel, 'Historical');
    expect(monument.workingHours, '8:00 AM - 5:00 PM');
    expect(monument.entryFee, 5);
    expect(monument.toJson()['tags'], ['Theatre', 'Market']);
  });

  test('offer total is flight plus hotel rate multiplied by nights', () {
    final offer = TravelPackage.fromJson({
      'id': 'istanbul-dream',
      'title': 'Istanbul Dream',
      'location': 'Istanbul',
      'country': 'Turkey',
      'description': 'Explore the city',
      'image_url': '',
      'price_per_person': 1290,
      'flight_price_per_person': 420,
      'hotel_price_per_night': 95,
      'duration_nights': 7,
      'rating': 4.8,
      'review_count': 2340,
      'is_featured': 1,
      'badge': 'Featured Offer',
      'highlights': ['Grand Bazaar', 'Hagia Sophia'],
    });

    expect(offer.totalPricePerPerson, 1085);
    expect(offer.durationNights, 7);
    expect(offer.isFeatured, isTrue);
    expect(offer.badge, 'Featured Offer');
    expect(offer.toJson()['highlights'], ['Grand Bazaar', 'Hagia Sophia']);
  });
}
