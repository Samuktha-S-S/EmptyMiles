package com.emptymiles.matching;

import com.emptymiles.model.Vehicle;
import com.emptymiles.model.enums.VehicleStatus;

/** Rule 4: the partner has marked the vehicle AVAILABLE and it has shared a location. */
public class AvailabilityValidator {

    public boolean isAvailable(Vehicle vehicle) {
        return vehicle.getStatus() == VehicleStatus.AVAILABLE && vehicle.hasLocation();
    }
}
