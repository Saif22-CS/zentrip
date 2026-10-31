-- Add the canonical hotel fields to existing shared partner listings.
-- This migration targets PostgreSQL/Supabase, not MySQL.
ALTER TABLE partner_listings
    ADD COLUMN IF NOT EXISTS location_name VARCHAR(512) NULL,
    ADD COLUMN IF NOT EXISTS google_maps_url VARCHAR(2048) NULL,
    ADD COLUMN IF NOT EXISTS place_id VARCHAR(255) NULL,
    ADD COLUMN IF NOT EXISTS google_rating DECIMAL(2,1) NOT NULL DEFAULT 0.0,
    ADD COLUMN IF NOT EXISTS google_review_count INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS amenities JSONB NULL,
    ADD COLUMN IF NOT EXISTS tax_and_fees_percentage DECIMAL(5,2) NOT NULL DEFAULT 12.00,
    ADD COLUMN IF NOT EXISTS available_rooms INTEGER NOT NULL DEFAULT 0;

UPDATE partner_listings
SET google_rating = COALESCE(
        NULLIF(google_rating, 0.0),
        NULLIF(attributes ->> 'google_rating', '')::DECIMAL(2,1),
        0.0
    ),
    google_review_count = COALESCE(
        NULLIF(google_review_count, 0),
        NULLIF(attributes ->> 'google_review_count', '')::INTEGER,
        0
    ),
    location_name = COALESCE(
        location_name,
        NULLIF(attributes ->> 'location_name', ''),
        NULLIF(attributes ->> 'address', ''),
        NULLIF(attributes ->> 'neighborhood', ''),
        city
    ),
    google_maps_url = COALESCE(
        google_maps_url,
        NULLIF(attributes ->> 'google_maps_url', ''),
        NULLIF(attributes ->> 'location_input', '')
    ),
    place_id = COALESCE(
        place_id,
        NULLIF(attributes ->> 'place_id', ''),
        NULLIF(attributes ->> 'google_place_id', '')
    ),
    amenities = COALESCE(
        amenities,
        COALESCE(attributes -> 'amenities', '[]'::jsonb),
        '[]'::jsonb
    ),
    tax_and_fees_percentage = CASE
        WHEN tax_and_fees_percentage = 12.00
             AND attributes ? 'tax_and_fees_percentage'
        THEN (attributes ->> 'tax_and_fees_percentage')::DECIMAL(5,2)
        ELSE tax_and_fees_percentage
    END,
    available_rooms = CASE
        WHEN attributes ? 'available_rooms'
        THEN COALESCE((attributes ->> 'available_rooms')::INTEGER, 0)
        WHEN jsonb_typeof(attributes -> 'room_types') = 'array'
             AND jsonb_array_length(COALESCE(attributes -> 'room_types', '[]'::jsonb)) > 0
        THEN COALESCE((
            SELECT SUM((value ->> 'rooms_available')::INTEGER)
            FROM jsonb_array_elements(COALESCE(attributes -> 'room_types', '[]'::jsonb)) AS value
        ), 0)
        ELSE available_rooms
    END
WHERE type = 'hotel';
