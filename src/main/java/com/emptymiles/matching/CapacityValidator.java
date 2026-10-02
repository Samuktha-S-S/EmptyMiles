package com.emptymiles.matching;

import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;

/**
 * Rule 1: the vehicle must have room for the shipment.
 * Example: bike 10 kg total, 3 kg loaded -> 7 kg free -> a 5 kg parcel fits.
 */
public class CapacityValidator {

    public double availableCapacity(Vehicle vehicle) {
        return vehicle.getTotalCapacity() - vehicle.getCurrentLoad();
    }

    public boolean hasCapacity(Vehicle vehicle, Shipment shipment) {
        return shipment.getWeight() <= availableCapacity(vehicle);
    }

    /**
     * 0..1, higher when the shipment fills more of the free space.
     * This prefers using up "empty miles" instead of sending a big empty truck for a small parcel.
     */
    public double capacityScore(Vehicle vehicle, Shipment shipment) {
        double free = availableCapacity(vehicle);
        return free <= 0 ? 0 : Math.min(1.0, shipment.getWeight() / free);
    }
}
