package com.emptymiles.matching;

import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.enums.VehicleType;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.GeoUtils;

/**
 * Turns the three part-scores into one match score out of 100:
 *
 *   score = 40 x distanceScore + 35 x routeScore + 25 x capacityScore
 *
 *   distanceScore = 1 - (km to pickup / max pickup radius of the vehicle type)
 *   routeScore    = from RouteCompatibilityChecker
 *   capacityScore = from CapacityValidator
 */
public class MatchScoreCalculator {

    public double distanceScore(double distanceToPickupKm, VehicleType type) {
        return Math.max(0, 1 - distanceToPickupKm / type.getMaxPickupRadiusKm());
    }

    public double calculate(double distanceScore, double routeScore, double capacityScore) {
        double score = AppConstants.WEIGHT_DISTANCE * distanceScore
                + AppConstants.WEIGHT_ROUTE * routeScore
                + AppConstants.WEIGHT_CAPACITY * capacityScore;
        return GeoUtils.round2(score);
    }

    /** Price = base fare + per-km rate x trip length (pickup to drop), by vehicle type. */
    public double estimateCost(Vehicle vehicle, Shipment shipment) {
        double tripKm = GeoUtils.haversineKm(shipment.getPickupLatitude(), shipment.getPickupLongitude(),
                shipment.getDestinationLatitude(), shipment.getDestinationLongitude());
        VehicleType type = vehicle.getVehicleType();
        return Math.round(type.getBaseFare() + type.getPerKmRate() * tripKm);
    }
}
