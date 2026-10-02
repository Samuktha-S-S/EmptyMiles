-- Removes all EmptyMiles tables (reverse foreign-key order). Run schema.sql afterwards for a clean start.
-- Run it in pgAdmin's Query Tool on the emptymiles database.

DROP TABLE IF EXISTS delivery_otps;
DROP TABLE IF EXISTS vehicle_locations;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS users;
