-- EmptyMiles database schema (PostgreSQL)
--
-- In pgAdmin 4:
--   1. Right-click Databases > Create > Database..., name it: emptymiles
--   2. Select the emptymiles database, open Tools > Query Tool
--   3. Open this file (or paste it) and press Execute (F5)

-- Customers and delivery partners
CREATE TABLE IF NOT EXISTS users (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(15)  NOT NULL,
    password    VARCHAR(255) NOT NULL,              -- salted PBKDF2 hash, never plain text
    role        VARCHAR(10)  NOT NULL CHECK (role IN ('CUSTOMER', 'PARTNER')),
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles owned by delivery partners
CREATE TABLE IF NOT EXISTS vehicles (
    id                     SERIAL PRIMARY KEY,
    partner_id             INT NOT NULL REFERENCES users (id),
    vehicle_type           VARCHAR(10) NOT NULL CHECK (vehicle_type IN ('BIKE', 'AUTO', 'TRUCK')),
    vehicle_number         VARCHAR(20) NOT NULL UNIQUE,
    total_capacity         NUMERIC(10, 2) NOT NULL,          -- kg
    current_load           NUMERIC(10, 2) NOT NULL DEFAULT 0, -- kg
    available_capacity     NUMERIC(10, 2) NOT NULL,          -- total_capacity - current_load
    status                 VARCHAR(10) NOT NULL DEFAULT 'OFFLINE' CHECK (status IN ('AVAILABLE', 'BUSY', 'OFFLINE')),
    current_latitude       NUMERIC(10, 7),
    current_longitude      NUMERIC(10, 7),
    destination            VARCHAR(255),                     -- where the vehicle is heading (optional)
    destination_latitude   NUMERIC(10, 7),
    destination_longitude  NUMERIC(10, 7)
);
CREATE INDEX IF NOT EXISTS idx_vehicle_status ON vehicles (status);

-- Goods a customer wants to send
CREATE TABLE IF NOT EXISTS shipments (
    id                     SERIAL PRIMARY KEY,
    customer_id            INT NOT NULL REFERENCES users (id),
    pickup_address         VARCHAR(255) NOT NULL,
    pickup_latitude        NUMERIC(10, 7) NOT NULL,
    pickup_longitude       NUMERIC(10, 7) NOT NULL,
    destination_address    VARCHAR(255) NOT NULL,
    destination_latitude   NUMERIC(10, 7) NOT NULL,
    destination_longitude  NUMERIC(10, 7) NOT NULL,
    product_name           VARCHAR(100) NOT NULL,
    product_type           VARCHAR(50)  NOT NULL,
    quantity               INT NOT NULL,
    weight                 NUMERIC(10, 2) NOT NULL,          -- total kg
    status                 VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
    created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Optional details from the Send Goods steps
    length_cm              NUMERIC(8, 2),
    width_cm               NUMERIC(8, 2),
    height_cm              NUMERIC(8, 2),
    special_requirements   VARCHAR(255),
    pickup_date            DATE,
    pickup_time_slot       VARCHAR(20),
    special_instructions   VARCHAR(500)
);

-- A shipment assigned to one partner's vehicle
CREATE TABLE IF NOT EXISTS bookings (
    id              SERIAL PRIMARY KEY,
    shipment_id     INT NOT NULL REFERENCES shipments (id),
    customer_id     INT NOT NULL REFERENCES users (id),
    partner_id      INT NOT NULL REFERENCES users (id),
    vehicle_id      INT NOT NULL REFERENCES vehicles (id),
    status          VARCHAR(30) NOT NULL,
    match_score     NUMERIC(5, 2) NOT NULL,
    estimated_cost  NUMERIC(10, 2) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pickup_time     TIMESTAMP NULL,
    delivery_time   TIMESTAMP NULL
);
CREATE INDEX IF NOT EXISTS idx_booking_status ON bookings (status);

-- GPS points sent by the partner's browser during a delivery
CREATE TABLE IF NOT EXISTS vehicle_locations (
    id           BIGSERIAL PRIMARY KEY,
    vehicle_id   INT NOT NULL REFERENCES vehicles (id),
    booking_id   INT NULL REFERENCES bookings (id),
    latitude     NUMERIC(10, 7) NOT NULL,
    longitude    NUMERIC(10, 7) NOT NULL,
    recorded_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_location_booking ON vehicle_locations (booking_id, recorded_at);

-- OTP the customer gives the partner at the destination
CREATE TABLE IF NOT EXISTS delivery_otps (
    id           SERIAL PRIMARY KEY,
    booking_id   INT NOT NULL UNIQUE REFERENCES bookings (id),
    otp          VARCHAR(6) NOT NULL,
    verified     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at  TIMESTAMP NULL
);
