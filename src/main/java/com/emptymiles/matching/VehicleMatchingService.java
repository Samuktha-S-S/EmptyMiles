package com.emptymiles.matching;

import com.emptymiles.dao.VehicleDAO;
import com.emptymiles.dao.impl.VehicleDAOImpl;
import com.emptymiles.dto.MatchResult;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.util.GeoUtils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * The matching engine. For a shipment it:
 *   1. loads the AVAILABLE vehicles,
 *   2. drops any that fail a rule (availability, capacity, pickup distance, route),
 *   3. scores the rest with MatchScoreCalculator,
 *   4. returns them ranked, best first.
 */
public class VehicleMatchingService {

    private final VehicleDAO vehicleDAO;
    private final CapacityValidator capacityValidator = new CapacityValidator();
    private final AvailabilityValidator availabilityValidator = new AvailabilityValidator();
    private final RouteCompatibilityChecker routeChecker = new RouteCompatibilityChecker();
    private final MatchScoreCalculator scoreCalculator = new MatchScoreCalculator();

    public VehicleMatchingService() {
        this(new VehicleDAOImpl());
    }

    public VehicleMatchingService(VehicleDAO vehicleDAO) {
        this.vehicleDAO = vehicleDAO;
    }

    /** Ranked matches for a shipment, using the vehicles currently in the database. */
    public List<MatchResult> findMatches(Shipment shipment) {
        return rankVehicles(shipment, vehicleDAO.findAvailableWithLocation());
    }

    /** Pure ranking logic (no database), so it can be unit tested. */
    public List<MatchResult> rankVehicles(Shipment shipment, List<Vehicle> vehicles) {
        List<MatchResult> results = new ArrayList<>();
        for (Vehicle vehicle : vehicles) {
            MatchResult result = evaluate(shipment, vehicle);
            if (result != null) {
                results.add(result);
            }
        }
        results.sort(Comparator.comparingDouble(MatchResult::getMatchScore).reversed()
                .thenComparingDouble(MatchResult::getDistanceToPickupKm));
        return results;
    }

    /** Scores one vehicle, or returns null if it is not eligible for this shipment. */
    public MatchResult evaluate(Shipment shipment, Vehicle vehicle) {
        if (!availabilityValidator.isAvailable(vehicle)) {
            return null;
        }
        if (!capacityValidator.hasCapacity(vehicle, shipment)) {
            return null;
        }
        double toPickupKm = GeoUtils.haversineKm(vehicle.getCurrentLatitude(), vehicle.getCurrentLongitude(),
                shipment.getPickupLatitude(), shipment.getPickupLongitude());
        if (toPickupKm > vehicle.getVehicleType().getMaxPickupRadiusKm()) {
            return null;
        }
        if (!routeChecker.isCompatible(vehicle, shipment)) {
            return null;
        }

        double score = scoreCalculator.calculate(
                scoreCalculator.distanceScore(toPickupKm, vehicle.getVehicleType()),
                routeChecker.routeScore(vehicle, shipment),
                capacityValidator.capacityScore(vehicle, shipment));
        double tripKm = GeoUtils.haversineKm(shipment.getPickupLatitude(), shipment.getPickupLongitude(),
                shipment.getDestinationLatitude(), shipment.getDestinationLongitude());
        double detour = routeChecker.detourKm(vehicle, shipment);

        return new MatchResult(vehicle,
                GeoUtils.round2(toPickupKm),
                GeoUtils.round2(tripKm),
                GeoUtils.round2(detour),
                vehicle.hasDestination(),
                score,
                scoreCalculator.estimateCost(vehicle, shipment));
    }
}
