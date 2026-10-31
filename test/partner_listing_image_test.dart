import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/models/partner_dashboard_model.dart';

void main() {
  test('flight listing payload omits its image while other types retain it',
      () {
    PartnerListing listing({required String type}) => PartnerListing(
          type: type,
          title: 'Listing',
          city: 'Misrata',
          country: 'Libya',
          description: '',
          imageUrl: 'https://example.com/image.jpg',
          price: 100,
          active: true,
        );

    expect(listing(type: 'flight').toJson()['image_url'], isNull);
    expect(
      listing(type: 'hotel').toJson()['image_url'],
      'https://example.com/image.jpg',
    );
  });

  test('partner hotel listing round-trips seeded inventory attributes', () {
    final listing = PartnerListing.fromJson({
      'id': 42,
      'type': 'hotel',
      'title': 'Al-Masa Hotel',
      'city': 'Tripoli',
      'country': 'Libya',
      'description': 'Demo inventory',
      'image_url': 'https://example.com/hotel.jpg',
      'price': '120.00',
      'active': 'true',
      'attributes': {
        'location_input': '32.8872,13.1913',
        'latitude': 32.8872,
        'longitude': 13.1913,
        'room_types': [
          {
            'code': 'standard',
            'price_per_night': 120,
            'rooms_available': 12,
          },
        ],
        'availability_schedule': [
          {'available': true},
        ],
        'gallery_images': ['https://example.com/room.jpg'],
      },
    });

    final payload = listing.toJson();
    final attributes = payload['attributes'] as Map<String, dynamic>;
    expect(listing.active, isTrue);
    expect(payload['image_url'], 'https://example.com/hotel.jpg');
    expect(attributes['latitude'], 32.8872);
    expect(attributes['room_types'], isA<List>());
    expect(attributes['availability_schedule'], isA<List>());
    expect(attributes['gallery_images'], ['https://example.com/room.jpg']);
  });

  test('partner hotel listing maps user-visible mock hotel fields', () {
    final listing = PartnerListing.fromJson({
      'id': 5,
      'type': 'hotel',
      'title': 'Central House Hotel',
      'city': 'Tripoli',
      'country': 'Libya',
      'description':
          'A welcoming stay in Tripoli, with thoughtful amenities and convenient access to local highlights.',
      'image_url': 'https://example.com/central-house.jpg',
      'price': 150,
      'active': true,
      'neighborhood': 'Historic Quarter',
      'google_rating': '4.6',
      'google_review_count': '3560',
      'amenities': ['Breakfast', 'Wi-Fi', 'Air Conditioning'],
      'room_types': [
        {
          'code': 'standard',
          'name': 'Standard Room',
          'price_per_night': 150,
          'max_guests': 2,
          'rooms_available': 10,
        },
      ],
      'availability_schedule': [
        {'available': true},
      ],
      'attributes': {
        'google_rating': null,
        'google_review_count': 0,
      },
    });

    expect(listing.title, 'Central House Hotel');
    expect(listing.price, 150);
    expect(listing.locationName, 'Historic Quarter');
    expect(listing.googleRating, 4.6);
    expect(listing.googleReviewCount, 3560);
    expect(listing.amenities, ['Breakfast', 'Wi-Fi', 'Air Conditioning']);
    expect(listing.attributes['room_types'], isA<List>());
    expect(listing.attributes['availability_schedule'], isA<List>());
  });
}
