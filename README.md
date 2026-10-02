# EmptyMiles

Smart goods delivery matching. Customers who want to send goods are matched with delivery
partners (Bike, Auto, Truck) that have free capacity, are close to the pickup point and are
already heading in a compatible direction.

**Stack:** Java 25, Maven, Jakarta Servlet 6.1, JSP + JSTL, JDBC, MySQL 8, Apache Tomcat 11.
No frameworks, no paid map APIs.

## Run it in IntelliJ IDEA

1. **MySQL:** open MySQL Workbench (or the `mysql` command line) and run, in order:
   - `database/schema.sql` (creates the `emptymiles` database and tables)
   - `database/seed-data.sql` (demo accounts and vehicles in Chennai)
2. **DB password:** edit `src/main/resources/db.properties` and set `db.password` to your MySQL root password.
3. **Maven:** right-click `pom.xml` > *Maven* > *Reload project* so the dependencies download.
4. **Tomcat 11:** download Tomcat 11 (zip) from tomcat.apache.org and unzip it anywhere.
   In IntelliJ: *Run* > *Edit Configurations* > *+* > *Tomcat Server* > *Local*.
   Point *Application server* at the Tomcat folder. On the *Deployment* tab add the artifact
   `emptymiles:war exploded` and set *Application context* to `/emptymiles`.
   (Tomcat 10.0 or older will not work: they use the old `javax.servlet` package.)
5. Run it and open <http://localhost:8080/emptymiles/>.

`mvn test` runs the unit tests for the Haversine distance and the matching engine (no database needed).

## Demo accounts (password `password123`)

| Email | Role | Vehicle |
|---|---|---|
| customer@emptymiles.com | Customer | |
| ravi@emptymiles.com | Partner | Bike TN09AB1234, near T. Nagar, 7 kg free, heading to Adyar |
| kumar@emptymiles.com | Partner | Auto TN01CD5678, Chennai Central, no fixed route |
| selvam@emptymiles.com | Partner | Truck TN22EF9012, Velachery, heading to Tambaram |

## Demo walkthrough

1. Log in as the customer, click **Send goods**: Clothes, 5 kg, pickup T. Nagar
   (13.0418, 80.2341), destination Adyar (13.0012, 80.2565). Click **Search suitable vehicles**.
2. Ravi's bike ranks first (0.2 km away, already going to Adyar). The truck is left out because
   T. Nagar to Adyar is far off its Velachery to Tambaram route. Click **Select**.
3. In another browser (or a private window) log in as `ravi@emptymiles.com`, open **Requests**, **Accept**.
   The bike's load goes from 3 kg to 8 kg and an OTP is created.
4. The customer now sees the 4-digit OTP on the booking page and can open **Track delivery**.
5. The partner presses the status button step by step (on the way, at pickup, picked up, in transit,
   arrived). The browser shares the partner's GPS location every 15 seconds while the page is open.
6. At *Arrived at destination* the partner types the customer's OTP, then **Complete delivery**.
   The bike's load goes back to 3 kg.

## How it is built

```
JSP pages (WEB-INF/views)  <-  HTML/CSS/JS in webapp/assets
        |
filter        login check, role check, UTF-8
        |
controller    servlets: read the request, call a service, forward to a JSP (or return JSON in controller.api)
        |
service       business rules and the booking workflow
   matching   the matching engine
        |
dao           SQL with JDBC PreparedStatements
        |
MySQL
```

| Package | Responsibility |
|---|---|
| `model`, `model.enums` | One class per table; Role, VehicleType (with fares and pickup radius), VehicleStatus, DeliveryStatus |
| `dto` | `MatchResult` (one ranked vehicle), `TrackingInfo` (live status sent to the tracking page) |
| `dao`, `dao.impl` | Interfaces and JDBC implementations, one per table |
| `service` | `AuthService`, `VehicleService`, `ShipmentService`, `BookingService`, `TrackingService`, `OTPService` |
| `matching` | `VehicleMatchingService` plus its rules: `CapacityValidator`, `AvailabilityValidator`, `RouteCompatibilityChecker`, `MatchScoreCalculator` |
| `controller.*` | Servlets for auth, customer, partner, and the two JSON endpoints used by JavaScript |
| `filter` | `AuthenticationFilter`, `RoleAuthorizationFilter`, `CharacterEncodingFilter` (order set in `web.xml`) |
| `exception` | `ValidationException`, `AuthenticationException`, `BookingException`, `DataAccessException` |
| `util` | `DBConnection`, `GeoUtils` (Haversine), `PasswordUtil` (PBKDF2), `OTPGenerator`, `ValidationUtil`, `AppConstants` |

## Matching engine

For each AVAILABLE vehicle with a known location:

1. **Availability:** status is AVAILABLE.
2. **Capacity:** `weight <= totalCapacity - currentLoad` (5 kg fits a 10 kg bike carrying 3 kg).
3. **Distance:** Haversine distance from the vehicle to the pickup must be within the type's radius
   (Bike 10 km, Auto 15 km, Truck 40 km).
4. **Route:** if the vehicle already has a destination, the detour
   `(vehicle -> pickup -> drop -> its destination) - (vehicle -> its destination)`
   must be at most 50% of its own trip (minimum 3 km). Vehicles with no route are always compatible.

Eligible vehicles get a score out of 100 and are sorted best first:

```
score = 40 x (1 - distanceToPickup / radius)
      + 35 x routeScore      (1 = no detour, 0.5 = no fixed route)
      + 25 x weight / freeCapacity   (prefers filling empty space)
```

Estimated cost = base fare + per-km rate x trip distance (Bike 30 + 8/km, Auto 50 + 12/km, Truck 150 + 25/km).

## Delivery status flow

`REQUESTED` > `SEARCHING` > `MATCHED` (request sent) > `PARTNER_ACCEPTED` > `PARTNER_ARRIVING` >
`ARRIVED_AT_PICKUP` > `PICKED_UP` > `IN_TRANSIT` > `ARRIVED_AT_DESTINATION` > `DELIVERED` (OTP verified) > `COMPLETED`.
A rejected request becomes `CANCELLED` and the shipment returns to `REQUESTED` so the customer can pick another vehicle.

## Location without paid APIs

- The browser's `navigator.geolocation` fills latitude/longitude fields and, during a delivery,
  `location-sender.js` posts the partner's position to `/api/location`, which stores it in `vehicle_locations`.
- `tracking.js` polls `/api/tracking` every 10 seconds and shows the position, distances and an OpenStreetMap link.
- **Look up address** uses the free OpenStreetMap Nominatim search. If there is no internet, type the coordinates.
- Browsers only allow geolocation on `localhost` or HTTPS, so test on `localhost`.
