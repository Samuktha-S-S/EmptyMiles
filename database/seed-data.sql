-- Demo data for EmptyMiles (Chennai locations). Run after schema.sql, in pgAdmin's Query Tool on the emptymiles database.
-- Every demo account uses the password:  password123

INSERT INTO users (name, email, phone, password, role) VALUES
('Priya Customer',  'customer@emptymiles.com', '9876500001', '65536:ceAzFwS7ldIh/GamyZ7ENQ==:YefubfRfGuFQFeZkLwOREw2FOpsY6PjUNiw2H4cySbY=', 'CUSTOMER'),
('Ravi Bike',       'ravi@emptymiles.com',     '9876500002', '65536:ceAzFwS7ldIh/GamyZ7ENQ==:YefubfRfGuFQFeZkLwOREw2FOpsY6PjUNiw2H4cySbY=', 'PARTNER'),
('Kumar Auto',      'kumar@emptymiles.com',    '9876500003', '65536:ceAzFwS7ldIh/GamyZ7ENQ==:YefubfRfGuFQFeZkLwOREw2FOpsY6PjUNiw2H4cySbY=', 'PARTNER'),
('Selvam Truck',    'selvam@emptymiles.com',   '9876500004', '65536:ceAzFwS7ldIh/GamyZ7ENQ==:YefubfRfGuFQFeZkLwOREw2FOpsY6PjUNiw2H4cySbY=', 'PARTNER');

-- Ravi's bike is near T. Nagar, already carrying 3 kg, heading to Adyar
INSERT INTO vehicles (partner_id, vehicle_type, vehicle_number, total_capacity, current_load, available_capacity, status,
                      current_latitude, current_longitude, destination, destination_latitude, destination_longitude)
VALUES ((SELECT id FROM users WHERE email = 'ravi@emptymiles.com'), 'BIKE', 'TN09AB1234', 10, 3, 7, 'AVAILABLE',
        13.0400, 80.2330, 'Adyar, Chennai', 13.0012, 80.2565);

-- Kumar's auto is at Chennai Central with no fixed route
INSERT INTO vehicles (partner_id, vehicle_type, vehicle_number, total_capacity, current_load, available_capacity, status,
                      current_latitude, current_longitude)
VALUES ((SELECT id FROM users WHERE email = 'kumar@emptymiles.com'), 'AUTO', 'TN01CD5678', 300, 0, 300, 'AVAILABLE',
        13.0827, 80.2707);

-- Selvam's truck is in Velachery, heading to Tambaram
INSERT INTO vehicles (partner_id, vehicle_type, vehicle_number, total_capacity, current_load, available_capacity, status,
                      current_latitude, current_longitude, destination, destination_latitude, destination_longitude)
VALUES ((SELECT id FROM users WHERE email = 'selvam@emptymiles.com'), 'TRUCK', 'TN22EF9012', 2000, 500, 1500, 'AVAILABLE',
        12.9815, 80.2180, 'Tambaram, Chennai', 12.9249, 80.1000);

-- Try it: log in as customer@emptymiles.com and send 5 kg of Clothes
--   Pickup      T. Nagar, Chennai   13.0418, 80.2341
--   Destination Adyar, Chennai      13.0012, 80.2565
-- Ravi's bike should be ranked first.
