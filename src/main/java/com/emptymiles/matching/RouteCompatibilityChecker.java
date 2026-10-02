package com.emptymiles.matching;

import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.GeoUtils;

/**
 * Rule 3: does the shipment fit the route the vehicle is already driving?
 *
 * If the vehicle has a destination, compare
 *   direct trip:  vehicle -> its destination
 *   with parcel:  vehicle -> pickup -> drop -> its destination
 * The difference is the detour. A small detour means the parcel rides along "empty miles".
 * A vehicle with no destination can go anywhere, so it gets a neutral score.
 */
public class RouteCompatibilityChecker {

    /** Extra km the vehicle must drive off its own route (0 if it has no route). */
    public double detourKm(Vehicle v, Shipment s) {
        if (!v.hasDestination()) {
            return 0;
        }
        double direct = GeoUtils.haversineKm(v.getCurrentLatitude(), v.getCurrentLongitude(),
                v.getDestinationLatitude(), v.getDestinationLongitude());
        double viaShipment =
                GeoUtils.haversineKm(v.getCurrentLatitude(), v.getCurrentLongitude(),
                        s.getPickupLatitude(), s.getPickupLongitude())
                + GeoUtils.haversineKm(s.getPickupLatitude(), s.getPickupLongitude(),
                        s.getDestinationLatitude(), s.getDestinationLongitude())
                + GeoUtils.haversineKm(s.getDestinationLatitude(), s.getDestinationLongitude(),
                        v.getDestinationLatitude(), v.getDestinationLongitude());
        return Math.max(0, viaShipment - direct);
    }

    /** Largest detour accepted for this vehicle's route. */
    public double allowedDetourKm(Vehicle v) {
        double direct = GeoUtils.haversineKm(v.getCurrentLatitude(), v.getCurrentLongitude(),
                v.getDestinationLatitude(), v.getDestinationLongitude());
        return Math.max(AppConstants.MIN_ALLOWED_DETOUR_KM, direct * AppConstants.MAX_DETOUR_RATIO);
    }

    public boolean isCompatible(Vehicle v, Shipment s) {
        return !v.hasDestination() || detourKm(v, s) <= allowedDetourKm(v);
    }

    /** 0..1, where 1 = no detour at all. */
    public double routeScore(Vehicle v, Shipment s) {
        if (!v.hasDestination()) {
            return AppConstants.NO_ROUTE_SCORE;
        }
        return Math.max(0, 1 - detourKm(v, s) / allowedDetourKm(v));
    }
}
