-- PostgreSQL/Supabase demo inventory for the active partner accounts.
-- This script is intentionally minimal and idempotent.

BEGIN;

INSERT INTO partner_listings (
    partner_id, type, title, city, country, description, image_url,
    price, active, attributes, location_name, google_maps_url,
    google_rating, google_review_count, amenities,
    tax_and_fees_percentage, available_rooms, created_at, updated_at
)
SELECT
    p.id,
    'hotel',
    'Al-Masa Hotel',
    'Tripoli',
    'Libya',
    'Demo hotel inventory for the Al-Masa Hotel partner.',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=900&auto=format&fit=crop',
    120.00,
    TRUE,
    jsonb_build_object(
        'seed_key', 'al-masa-hotel-demo-v1',
        'name', 'Al-Masa Hotel',
        'location_name', 'Airport Road, Tripoli',
        'google_maps_url', 'https://www.google.com/maps/search/?api=1&query=32.8872%2C13.1913',
        'location_input', '32.8872,13.1913',
        'latitude', 32.8872,
        'longitude', 13.1913,
        'available_rooms', 15,
        'room_types', jsonb_build_array(
            jsonb_build_object('code', 'standard', 'name', 'Standard Room', 'price_per_night', 120.00, 'max_guests', 2, 'rooms_available', 12),
            jsonb_build_object('code', 'deluxe', 'name', 'Deluxe Room', 'price_per_night', 175.00, 'max_guests', 2, 'rooms_available', 8),
            jsonb_build_object('code', 'family-suite', 'name', 'Family Suite', 'price_per_night', 260.00, 'max_guests', 4, 'rooms_available', 4)
        )
    ),
    'Airport Road, Tripoli',
    'https://www.google.com/maps/search/?api=1&query=32.8872%2C13.1913',
    0.0,
    0,
    jsonb_build_array('Gym', 'Wi-Fi', 'Restaurant', 'Spa', 'Pool'),
    12.00,
    15,
    NOW(),
    NOW()
FROM partners p
JOIN users u ON u.partner_id = p.id
WHERE u.email = 'almasahotel@zentrip.ly'
  AND u.role = 'partner'
  AND p.slug = 'al-masa-hotel'
  AND p.service_type = 'hotel'
  AND p.status = 'active'
  AND NOT EXISTS (
      SELECT 1
      FROM partner_listings existing
      WHERE existing.partner_id = p.id
        AND existing.title = 'Al-Masa Hotel'
  );

INSERT INTO partner_listings (
    partner_id, type, title, city, country, description, image_url,
    price, active, attributes, created_at, updated_at
)
SELECT p.id, 'car', 'Toyota Corolla', 'Tripoli', 'Libya',
       'Economy sedan rental in Tripoli.',
       'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=900&auto=format&fit=crop',
       45.00, TRUE,
       jsonb_build_object(
           'seed_key', 'zentrip-car-sedan-v1',
           'brand', 'Toyota',
           'model', 'Corolla',
           'category', 'economy',
           'year', 2024,
           'seats', 5,
           'transmission', 'automatic',
           'fuel_type', 'hybrid',
           'features', jsonb_build_array('Bluetooth', 'Backup camera', 'Low fuel consumption'),
           'rating', 4.6,
           'pickup_location', 'Tripoli',
           'return_location', 'Tripoli',
           'available_vehicles', 6,
           'latitude', 32.8872,
           'longitude', 13.1913,
           'has_ac', TRUE,
           'has_gps', FALSE
       ), NOW(), NOW()
FROM partners p
JOIN users u ON u.partner_id = p.id
WHERE u.email = 'zentripcarrental@zentrip.com'
  AND u.role = 'partner'
  AND p.slug = 'zentrip-car-rental'
  AND p.service_type = 'car'
  AND p.status = 'active'
  AND NOT EXISTS (
      SELECT 1 FROM partner_listings existing
      WHERE existing.partner_id = p.id
        AND existing.title = 'Toyota Corolla'
  );

INSERT INTO partner_listings (
    partner_id, type, title, city, country, description, image_url,
    price, active, attributes, created_at, updated_at
)
SELECT p.id, 'car', 'Hyundai Tucson', 'Tripoli', 'Libya',
       'SUV rental in Tripoli.',
       'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=900&auto=format&fit=crop',
       75.00, TRUE,
       jsonb_build_object(
           'seed_key', 'zentrip-car-suv-v1',
           'brand', 'Hyundai',
           'model', 'Tucson',
           'category', 'suv',
           'year', 2025,
           'seats', 5,
           'transmission', 'automatic',
           'fuel_type', 'gasoline',
           'features', jsonb_build_array('Bluetooth', 'Backup camera', 'Large luggage space'),
           'rating', 4.7,
           'pickup_location', 'Tripoli',
           'return_location', 'Tripoli',
           'available_vehicles', 4,
           'latitude', 32.8872,
           'longitude', 13.1913,
           'has_ac', TRUE,
           'has_gps', TRUE
       ), NOW(), NOW()
FROM partners p
JOIN users u ON u.partner_id = p.id
WHERE u.email = 'zentripcarrental@zentrip.com'
  AND u.role = 'partner'
  AND p.slug = 'zentrip-car-rental'
  AND p.service_type = 'car'
  AND p.status = 'active'
  AND NOT EXISTS (
      SELECT 1 FROM partner_listings existing
      WHERE existing.partner_id = p.id
        AND existing.title = 'Hyundai Tucson'
  );

INSERT INTO partner_listings (
    partner_id, type, title, city, country, description, image_url,
    price, active, attributes, created_at, updated_at
)
SELECT p.id, 'car', 'Mercedes-Benz C-Class', 'Tripoli', 'Libya',
       'Luxury sedan rental in Tripoli.',
       'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=900&auto=format&fit=crop',
       125.00, TRUE,
       jsonb_build_object(
           'seed_key', 'zentrip-car-luxury-v1',
           'brand', 'Mercedes-Benz',
           'model', 'C-Class',
           'category', 'luxury',
           'year', 2025,
           'seats', 5,
           'transmission', 'automatic',
           'fuel_type', 'gasoline',
           'features', jsonb_build_array('Bluetooth', 'Leather interior', 'Navigation'),
           'rating', 4.8,
           'pickup_location', 'Tripoli',
           'return_location', 'Tripoli',
           'available_vehicles', 2,
           'latitude', 32.8872,
           'longitude', 13.1913,
           'has_ac', TRUE,
           'has_gps', TRUE
       ), NOW(), NOW()
FROM partners p
JOIN users u ON u.partner_id = p.id
WHERE u.email = 'zentripcarrental@zentrip.com'
  AND u.role = 'partner'
  AND p.slug = 'zentrip-car-rental'
  AND p.service_type = 'car'
  AND p.status = 'active'
  AND NOT EXISTS (
      SELECT 1 FROM partner_listings existing
      WHERE existing.partner_id = p.id
        AND existing.title = 'Mercedes-Benz C-Class'
  );

COMMIT;

SELECT p.name AS partner_name,
       l.type,
       l.title,
       l.city,
       l.price,
       l.active,
       l.attributes ->> 'seed_key' AS seed_key
FROM partner_listings l
JOIN partners p ON p.id = l.partner_id
WHERE l.partner_id IN (
    SELECT id FROM partners WHERE slug IN ('al-masa-hotel', 'zentrip-car-rental')
)
ORDER BY p.name, l.title;
