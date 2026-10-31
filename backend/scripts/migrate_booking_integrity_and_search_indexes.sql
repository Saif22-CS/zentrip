CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS partner_listings_city_trgm_index
    ON partner_listings USING GIN (city gin_trgm_ops);
CREATE INDEX IF NOT EXISTS partner_listings_title_trgm_index
    ON partner_listings USING GIN (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS partner_listings_attributes_gin_index
    ON partner_listings USING GIN (attributes);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'bookings_user_id_foreign'
          AND conrelid = 'bookings'::regclass
    ) THEN
        ALTER TABLE bookings
            ADD CONSTRAINT bookings_user_id_foreign
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'bookings_partner_listing_id_foreign'
          AND conrelid = 'bookings'::regclass
    ) THEN
        ALTER TABLE bookings
            ADD CONSTRAINT bookings_partner_listing_id_foreign
            FOREIGN KEY (partner_listing_id)
            REFERENCES partner_listings(id) ON DELETE RESTRICT;
    END IF;
END;
$$;