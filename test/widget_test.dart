import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zentrip/features/home/presentation/screens/packages_list_screen.dart';
import 'package:zentrip/features/profile/logic/profile_controller.dart';
import 'package:zentrip/features/trips/logic/trips_controller.dart';
import 'package:zentrip/l10n/app_localizations.dart';
import 'package:zentrip/core/constants/app_colors.dart';
import 'package:zentrip/models/booking_model.dart';
import 'package:zentrip/features/favorites/logic/favorites_controller.dart';
import 'package:zentrip/models/flight_model.dart';
import 'package:zentrip/models/hotel_model.dart';
import 'package:zentrip/models/map_search_result.dart';
import 'package:zentrip/models/mock_data_service.dart';
import 'package:zentrip/models/payment_session.dart';
import 'package:zentrip/models/trip_model.dart';
import 'package:zentrip/models/travel_package_model.dart';
import 'package:zentrip/models/travel_preferences.dart';
import 'package:zentrip/models/transfer_model.dart';
import 'package:zentrip/global_widgets/payment_checkout_screen.dart';
import 'package:zentrip/global_widgets/confirm_dialog.dart';

void main() {
  testWidgets('mock payment loader stays centered while payment completes',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(
      const PaymentCheckoutScreen(
        session: PaymentSession(
          sessionId: 'payment-test',
          checkoutUrl: 'mock://checkout',
        ),
      ),
    ));
    await tester.tap(find.text('Simulate Successful Payment'));
    await tester.pump();

    final spinner = find.byType(CircularProgressIndicator);
    expect(spinner, findsOneWidget);
    expect(
      tester.getCenter(spinner).dx,
      closeTo(tester.view.physicalSize.width / 2, 0.5),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('trip cancellation confirmation labels stay on one line',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showAppConfirmDialog(
            context,
            title: 'Cancel trip?',
            message: 'Confirm cancellation.',
            confirmLabel: 'Cancel Trip',
            isDanger: true,
          ),
          child: const Text('Open dialog'),
        ),
      ),
    ));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    final confirmLabel = tester.widget<Text>(find.text('Cancel Trip'));
    expect(confirmLabel.maxLines, 1);
    expect(confirmLabel.softWrap, isFalse);
    expect(
        find.ancestor(
          of: find.text('Cancel Trip'),
          matching: find.byType(FittedBox),
        ),
        findsOneWidget);
  });

  group('TransferModel.fromJson', () {
    test('accepts integer ids returned by Laravel', () {
      final model = TransferModel.fromJson({
        'id': 9,
        'vehicle_type': 'sedan',
        'vehicle_name': 'Executive',
        'max_passengers': 4,
        'max_luggage': 2,
        'price': '35.00',
        'pickup_location': 'Cairo Airport',
        'dropoff_location': 'City Center Hotel',
        'pickup_time': '2026-09-17T15:00:00.000Z',
        'duration_minutes': 25,
        'status': 'confirmed',
        'provider_name': 'Zentrip Executive',
        'included_services': ['Wi-Fi', 'Water'],
      });

      expect(model.id, '9');
      expect(model.providerName, 'Zentrip Executive');
      expect(model.price, 35.0);
      expect(model.status, 'confirmed');
    });

    test('falls back cleanly when optional fields are missing', () {
      final model = TransferModel.fromJson({
        'id': '12',
        'vehicle_type': 'minivan',
        'vehicle_name': 'Family',
        'pickup_location': 'Airport',
        'dropoff_location': 'Hotel',
        'pickup_time': '2026-09-20T10:00:00.000Z',
      });

      expect(model.id, '12');
      expect(model.maxPassengers, 1);
      expect(model.maxLuggage, 0);
      expect(model.providerName, 'Zentrip Transfers');
      expect(model.includedServices, isEmpty);
    });
  });

  test('taxi catalog includes varied vehicles and passenger capacities', () {
    final taxis = MockDataService.transfers();

    expect(taxis.length, greaterThan(3));
    expect(taxis.map((taxi) => taxi.id).toSet(), hasLength(taxis.length));
    expect(
        taxis.map((taxi) => taxi.vehicleType).toSet(),
        containsAll([
          'economy',
          'comfort',
          'suv',
          'electric',
          'premium_van',
          'large_suv',
        ]));
    expect(taxis.every((taxi) => taxi.maxPassengers > 0), isTrue);
    expect(taxis.every((taxi) => taxi.priceUSD > 0), isTrue);
    expect(taxis.where((taxi) => taxi.maxPassengers >= 6), isNotEmpty);
  });

  group('FavoritePlace.fromMapSearchResult', () {
    test('preserves provider ID and map details', () {
      const result = MapSearchResult(
        title: 'Cafe Example',
        address: 'Downtown',
        category: 'cafe',
        placeId: 'provider-place-1',
        thumbnail: 'https://example.com/cafe.jpg',
        latitude: 25.2,
        longitude: 55.27,
      );

      final favorite = FavoritePlace.fromMapSearchResult(result);

      expect(favorite.id, 'provider-place-1');
      expect(favorite.title, 'Cafe Example');
      expect(favorite.subtitle, 'Downtown');
      expect(favorite.type, 'cafe');
      expect(favorite.imageUrl, 'https://example.com/cafe.jpg');
      expect(favorite.latitude, 25.2);
      expect(favorite.longitude, 55.27);
    });

    test('creates a stable ID when the provider ID is missing', () {
      const result = MapSearchResult(
        title: 'Cafe Example',
        address: 'Downtown',
        category: 'cafe',
      );

      final favorite = FavoritePlace.fromMapSearchResult(result);

      expect(favorite.id, 'cafe:cafe example:downtown');
    });

    test('persists a saved place and removes it after reload', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = FavoritesController.instance;
      await controller.load();
      const result = MapSearchResult(
        title: 'Cafe Example',
        address: 'Downtown',
        category: 'cafe',
        placeId: 'provider-place-2',
        latitude: 25.2,
        longitude: 55.27,
      );
      final favorite = FavoritePlace.fromMapSearchResult(result);

      await controller.toggle(favorite);
      await controller.load();
      expect(controller.isFavorite(favorite.id), isTrue);

      await controller.remove(favorite.id);
      await controller.load();
      expect(controller.isFavorite(favorite.id), isFalse);
    });
  });

  group('TravelPreferences', () {
    test('serializes values using the Java API field names', () {
      const preferences = TravelPreferences(
        budgetLevel: 'budget',
        travelPace: 'relaxed',
        tripDurationDays: 5,
        travelers: 2,
        interests: ['food', 'beaches'],
        preferredDestination: 'Bali',
      );

      final restored = TravelPreferences.fromJson(preferences.toJson());

      expect(restored.budgetLevel, 'budget');
      expect(restored.travelPace, 'relaxed');
      expect(restored.tripDurationDays, 5);
      expect(restored.travelers, 2);
      expect(restored.interests, ['food', 'beaches']);
      expect(restored.preferredDestination, 'Bali');
    });
  });

  group('TripModel flight schedule', () {
    test('round-trips departure and arrival as UTC API timestamps', () {
      final trip = TripModel(
        id: 1,
        originCode: 'JFK',
        originCity: 'New York',
        destinationCode: 'LHR',
        destinationCity: 'London',
        departureDate: DateTime.utc(2026, 11, 10, 10),
        arrivalDate: DateTime.utc(2026, 11, 10, 17),
        flightNumber: 'ZT100',
        isDirect: true,
        status: 'cancelled',
        refundStatus: 'pending_airline_review',
        refundMethod: 'original_payment_method',
        passengerCount: 3,
      );

      final restored = TripModel.fromJson(trip.toJson());

      expect(restored.departureDate, DateTime.utc(2026, 11, 10, 10));
      expect(restored.arrivalDate, DateTime.utc(2026, 11, 10, 17));
      expect(restored.status, 'cancelled');
      expect(restored.refundStatus, 'pending_airline_review');
      expect(restored.refundMethod, 'original_payment_method');
      expect(restored.passengerCount, 3);
    });
  });

  test(
      'profile trip count includes flights only and excludes cancelled flights',
      () {
    final flights = [
      TripModel(
        id: 1,
        originCode: 'MJI',
        originCity: 'Tripoli',
        destinationCode: 'CAI',
        destinationCity: 'Cairo',
        departureDate: DateTime.utc(2026, 10, 17, 7),
        flightNumber: 'ZT100',
        isDirect: true,
      ),
      TripModel(
        id: 2,
        originCode: 'MJI',
        originCity: 'Tripoli',
        destinationCode: 'TUN',
        destinationCity: 'Tunis',
        departureDate: DateTime.utc(2026, 10, 18, 7),
        flightNumber: 'ZT200',
        isDirect: true,
        status: 'cancelled',
      ),
      TripModel(
        id: 3,
        originCode: 'MJI',
        originCity: 'Tripoli',
        destinationCode: 'BEN',
        destinationCity: 'Benghazi',
        departureDate: DateTime.utc(2026, 10, 19, 7),
        flightNumber: 'ZT300',
        isDirect: true,
        status: 'completed',
      ),
    ];

    expect(ProfileController.countNonCancelledFlights(flights), 2);
  });

  group('TravelPackage offers API contract', () {
    test('reads airport code, image, featured status, and highlights', () {
      final package = TravelPackage.fromJson({
        'id': 'istanbul-dream',
        'title': 'Istanbul Dream',
        'location': 'Istanbul',
        'country': 'Turkey',
        'destination_code': 'IST',
        'description': 'Historic city break',
        'image_url': 'https://example.com/istanbul.jpg',
        'price_per_person': 1290,
        'flight_price_per_person': 420,
        'hotel_price_per_night': 95,
        'duration_nights': 7,
        'rating': 4.8,
        'review_count': 2340,
        'highlights': ['Blue Mosque', 'Hagia Sophia'],
        'is_featured': true,
        'category': 'cultural',
      });

      expect(package.destinationCode, 'IST');
      expect(package.imageUrl, 'https://example.com/istanbul.jpg');
      expect(package.isFeatured, isTrue);
      expect(package.highlights, ['Blue Mosque', 'Hagia Sophia']);
    });
  });

  group('Home listing data', () {
    testWidgets('New Ideas lists the complete supplied package collection',
        (tester) async {
      final packages = [
        _package('idea-1', 'Idea One'),
        _package('idea-2', 'Idea Two'),
        _package('idea-3', 'Idea Three'),
      ];
      await tester.pumpWidget(_localizedApp(
        PackagesListScreen(
          args: PackagesListArgs(
            kind: PackagesListKind.ideas,
            packages: packages,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      for (final package in packages) {
        expect(find.text(package.title), findsOneWidget);
      }
    });

    testWidgets(
        'Deals shows featured offers, falling back to all if none are featured',
        (tester) async {
      await tester.pumpWidget(_localizedApp(
        PackagesListScreen(
          key: const ValueKey('featured-deals'),
          args: PackagesListArgs(
            kind: PackagesListKind.deals,
            packages: [
              _package('featured', 'Featured Deal', isFeatured: true),
              _package('regular', 'Regular Idea'),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Featured Deal'), findsOneWidget);
      expect(find.text('Regular Idea'), findsNothing);

      await tester.pumpWidget(_localizedApp(
        PackagesListScreen(
          key: const ValueKey('all-deals-fallback'),
          args: PackagesListArgs(
            kind: PackagesListKind.deals,
            packages: [
              _package('idea-1', 'Idea One'),
              _package('idea-2', 'Idea Two'),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Idea One'), findsOneWidget);
      expect(find.text('Idea Two'), findsOneWidget);
    });
  });

  group('Travel demo catalogs', () {
    test('hotel search returns a larger catalog with a photo per hotel', () {
      final hotels = MockDataService.hotels(city: 'Tripoli');

      expect(hotels.length, greaterThanOrEqualTo(10));
      expect(hotels.map((hotel) => hotel.id).toSet(), hasLength(hotels.length));
      expect(hotels.every((hotel) => hotel.city == 'Tripoli'), isTrue);
      expect(
        hotels.every((hotel) => hotel.imageUrl?.startsWith('https://') == true),
        isTrue,
      );
    });

    test('hotel responses without a photo receive a hotel image fallback', () {
      final hotel = HotelModel.fromJson({
        'id': 'hotel-no-image',
        'name': 'Example Hotel',
        'city': 'Tripoli',
      });

      expect(hotel.imageUrl, startsWith('https://'));
    });

    test('monuments span categories and provide image URLs', () {
      final monuments = MockDataService.attractions()
          .where((attraction) => const {
                'historical',
                'natural',
                'cultural',
                'architecture',
              }.contains(attraction.category))
          .toList();

      expect(monuments.length, greaterThanOrEqualTo(20));
      expect(monuments.map((attraction) => attraction.category).toSet(),
          containsAll({'historical', 'natural', 'cultural', 'architecture'}));
      expect(
        monuments.every((attraction) =>
            attraction.imageUrl?.startsWith('https://') == true),
        isTrue,
      );
    });

    test('cars cover rental categories with complete display metadata', () {
      final cars = MockDataService.cars();

      expect(cars.length, greaterThanOrEqualTo(20));
      expect(
        cars.map((car) => car.category).toSet(),
        containsAll({'economy', 'suv', 'luxury', 'electric'}),
      );
      expect(
        cars.every((car) =>
            car.pricePerDay > 0 &&
            car.seats > 0 &&
            car.rating >= 0 &&
            car.rating <= 5 &&
            car.transmission.isNotEmpty &&
            car.fuelType.isNotEmpty &&
            car.imageUrl?.startsWith('https://') == true),
        isTrue,
      );
    });

    test('cars without a specified city do not default to Dubai', () {
      final cars = MockDataService.cars();

      expect(cars, isNotEmpty);
      expect(
        cars.every((car) => car.pickupLocation == 'Pickup location'),
        isTrue,
      );
    });
  });

  group('BookingModel schedule', () {
    test('round-trips booking start and end dates', () {
      final booking = BookingModel(
        id: 'hotel-1',
        type: BookingType.hotel,
        title: 'City Hotel',
        subtitle: 'Cairo',
        date: DateTime.utc(2026, 11, 10),
        endDate: DateTime.utc(2026, 11, 14),
      );

      final restored = BookingModel.fromJson(booking.toJson());

      expect(restored.date, DateTime.utc(2026, 11, 10));
      expect(restored.endDate, DateTime.utc(2026, 11, 14));
    });
  });

  group('Libyan flight search demo data', () {
    test('offers route-correct flights between Tripoli and Misrata', () {
      final flights = MockDataService.flights(
        origin: 'MJI',
        destination: 'MRA',
        departureDate: DateTime(2026, 11, 10),
      );

      expect(AirportOption.byCode('MJI')?.city, 'Tripoli');
      expect(AirportOption.byCode('MRA')?.city, 'Misrata');
      expect(flights, isNotEmpty);
      expect(flights.every((flight) => flight.originCode == 'MJI'), isTrue);
      expect(
          flights.every((flight) => flight.destinationCode == 'MRA'), isTrue);
      expect(flights.every((flight) => flight.originCity == 'Tripoli'), isTrue);
      expect(flights.every((flight) => flight.destinationCity == 'Misrata'),
          isTrue);
      expect(flights.first.departureTime.year, 2026);
      expect(flights.first.departureTime.month, 11);
      expect(flights.first.departureTime.day, 10);
      expect(
          flights.any((flight) => flight.airline == 'Libyan Airlines'), isTrue);
    });
  });

  group('My Trips status grouping', () {
    test('attraction and package bookings appear in the tours category', () {
      expect(
        TripsController.kindForBooking(BookingType.attraction),
        TripKind.tour,
      );
      expect(
        TripsController.kindForBooking(BookingType.package),
        TripKind.tour,
      );
      expect(
        TripsController.kindForBooking(BookingType.car),
        TripKind.car,
      );
    });

    test('reviews are available only for completed trips', () {
      TripItem itemWithStatus(TripTab status) => TripItem(
            kind: TripKind.hotel,
            title: 'Example Hotel',
            subtitle: 'Tripoli',
            start: DateTime(2026, 10, 1),
            end: DateTime(2026, 10, 3),
            status: status,
          );

      expect(itemWithStatus(TripTab.completed).canReview, isTrue);
      expect(itemWithStatus(TripTab.upcoming).canReview, isFalse);
      expect(itemWithStatus(TripTab.active).canReview, isFalse);
      expect(itemWithStatus(TripTab.cancelled).canReview, isFalse);
    });

    test('derives upcoming, active, completed, and cancelled states', () {
      final now = DateTime.utc(2026, 10, 9, 12);

      expect(
        TripsController.resolveStatus(
          'upcoming',
          now.add(const Duration(days: 1)),
          now.add(const Duration(days: 2)),
          now,
        ),
        TripTab.upcoming,
      );
      expect(
        TripsController.resolveStatus(
          'upcoming',
          now.subtract(const Duration(hours: 1)),
          now.add(const Duration(hours: 1)),
          now,
        ),
        TripTab.active,
      );
      expect(
        TripsController.resolveStatus(
          'upcoming',
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 1)),
          now,
        ),
        TripTab.completed,
      );
      expect(
        TripsController.resolveStatus(
          'cancelled',
          now.add(const Duration(days: 1)),
          now.add(const Duration(days: 2)),
          now,
        ),
        TripTab.cancelled,
      );
    });
  });
}

TravelPackage _package(
  String id,
  String title, {
  bool isFeatured = false,
}) =>
    TravelPackage(
      id: id,
      title: title,
      location: 'Tripoli',
      country: 'Libya',
      description: 'Demo travel package',
      imageUrl: 'https://example.com/$id.jpg',
      pricePerPerson: 100,
      flightPricePerPerson: 40,
      hotelPricePerNight: 20,
      durationNights: 3,
      rating: 4.5,
      reviewCount: 12,
      gradient: AppColors.destinationGradients.first,
      icon: Icons.location_city,
      highlights: const [],
      isFeatured: isFeatured,
      category: 'city',
    );

Widget _localizedApp(Widget home) => MaterialApp(
      home: home,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
