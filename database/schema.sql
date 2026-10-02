-- EmptyMiles database schema (MySQL 8+)
-- Run this once in MySQL Workbench or: mysql -u root -p < database/schema.sql

CREATE DATABASE IF NOT EXISTS emptymiles CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE emptymiles;

-- Customers and delivery partners
CREATE TABLE IF NOT EXISTS users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(15)  NOT NULL,
    password    VARCHAR(255) NOT NULL,              -- salted PBKDF2 hash, never plain text
    role        ENUM('CUSTOMER', 'PARTNER') NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles owned by delivery partners
CREATE TABLE IF NOT EXISTS vehicles (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    partner_id             INT NOT NULL,
    vehicle_type           ENUM('BIKE', 'AUTO', 'TRUCK') NOT NULL,
    vehicle_number         VARCHAR(20) NOT NULL UNIQUE,
    total_capacity         DECIMAL(10, 2) NOT NULL,          -- kg
    current_load           DECIMAL(10, 2) NOT NULL DEFAULT 0, -- kg
    available_capacity     DECIMAL(10, 2) NOT NULL,          -- total_capacity - current_load
    status                 ENUM('AVAILABLE', 'BUSY', 'OFFLINE') NOT NULL DEFAULT 'OFFLINE',
    current_latitude       DECIMAL(10, 7),
    current_longitude      DECIMAL(10, 7),
    destination            VARCHAR(255),                     -- where the vehicle is heading (optional)
    destination_latitude   DECIMAL(10, 7),
    destination_longitude  DECIMAL(10, 7),
    updated_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_partner FOREIGN KEY (partner_id) REFERENCES users (id),
    INDEX idx_vehicle_status (status)
);

-- Goods a customer wants to send
CREATE TABLE IF NOT EXISTS shipments (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id            INT NOT NULL,
    pickup_address         VARCHAR(255) NOT NULL,
    pickup_latitude        DECIMAL(10, 7) NOT NULL,
    pickup_longitude       DECIMAL(10, 7) NOT NULL,
    destination_address    VARCHAR(255) NOT NULL,
    destination_latitude   DECIMAL(10, 7) NOT NULL,
    destination_longitude  DECIMAL(10, 7) NOT NULL,
    product_name           VARCHAR(100) NOT NULL,
    product_type           VARCHAR(50)  NOT NULL,
    quantity               INT NOT NULL,
    weight                 DECIMAL(10, 2) NOT NULL,          -- total kg
    status                 VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
    created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_shipment_customer FOREIGN KEY (customer_id) REFERENCES users (id)
);

-- A shipment assigned to one partner's vehicle
CREATE TABLE IF NOT EXISTS bookings (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id     INT NOT NULL,
    customer_id     INT NOT NULL,
    partner_id      INT NOT NULL,
    vehicle_id      INT NOT NULL,
    status          VARCHAR(30) NOT NULL,
    match_score     DECIMAL(5, 2) NOT NULL,
    estimated_cost  DECIMAL(10, 2) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pickup_time     TIMESTAMP NULL,
    delivery_time   TIMESTAMP NULL,
    CONSTRAINT fk_booking_shipment FOREIGN KEY (shipment_id) REFERENCES shipments (id),
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES users (id),
    CONSTRAINT fk_booking_partner  FOREIGN KEY (partner_id)  REFERENCES users (id),
    CONSTRAINT fk_booking_vehicle  FOREIGN KEY (vehicle_id)  REFERENCES vehicles (id),
    INDEX idx_booking_status (status)
);

-- GPS points sent by the partner's browser during a delivery
CREATE TABLE IF NOT EXISTS vehicle_locations (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id   INT NOT NULL,
    booking_id   INT NULL,
    latitude     DECIMAL(10, 7) NOT NULL,
    longitude    DECIMAL(10, 7) NOT NULL,
    recorded_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_location_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles (id),
    CONSTRAINT fk_location_booking FOREIGN KEY (booking_id) REFERENCES bookings (id),
    INDEX idx_location_booking (booking_id, recorded_at)
);

-- OTP the customer gives the partner at the destination
CREATE TABLE IF NOT EXISTS delivery_otps (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    booking_id   INT NOT NULL UNIQUE,
    otp          VARCHAR(6) NOT NULL,
    verified     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at  TIMESTAMP NULL,
    CONSTRAINT fk_otp_booking FOREIGN KEY (booking_id) REFERENCES bookings (id)
);
