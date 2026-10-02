-- Removes all EmptyMiles tables (reverse foreign-key order). Run schema.sql afterwards for a clean start.
USE emptymiles;

DROP TABLE IF EXISTS delivery_otps;
DROP TABLE IF EXISTS vehicle_locations;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS users;
