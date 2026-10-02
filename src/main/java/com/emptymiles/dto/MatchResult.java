package com.emptymiles.dto;

import com.emptymiles.model.Vehicle;

/** One ranked vehicle shown on matched-vehicles.jsp. */
public class MatchResult {

    private final Vehicle vehicle;
    private final double distanceToPickupKm;
    private final double tripDistanceKm;
    private final double detourKm;          // extra km off the vehicle's own route (0 if it has none)
    private final boolean onRoute;          // vehicle already heads towards the destination
    private final double matchScore;        // 0 - 100
    private final double estimatedCost;

    public MatchResult(Vehicle vehicle, double distanceToPickupKm, double tripDistanceKm, double detourKm,
                       boolean onRoute, double matchScore, double estimatedCost) {
        this.vehicle = vehicle;
        this.distanceToPickupKm = distanceToPickupKm;
        this.tripDistanceKm = tripDistanceKm;
        this.detourKm = detourKm;
        this.onRoute = onRoute;
        this.matchScore = matchScore;
        this.estimatedCost = estimatedCost;
    }

    public Vehicle getVehicle() { return vehicle; }
    public double getDistanceToPickupKm() { return distanceToPickupKm; }
    public double getTripDistanceKm() { return tripDistanceKm; }
    public double getDetourKm() { return detourKm; }
    public boolean isOnRoute() { return onRoute; }
    public double getMatchScore() { return matchScore; }
    public double getEstimatedCost() { return estimatedCost; }
}
