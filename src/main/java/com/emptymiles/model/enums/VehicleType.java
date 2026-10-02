package com.emptymiles.model.enums;

/**
 * Supported vehicles. Each type has its own pricing and the maximum distance
 * it will travel empty to reach a pickup point.
 */
public enum VehicleType {
    BIKE(30, 8, 10),
    AUTO(50, 12, 15),
    TRUCK(150, 25, 40);

    private final double baseFare;
    private final double perKmRate;
    private final double maxPickupRadiusKm;

    VehicleType(double baseFare, double perKmRate, double maxPickupRadiusKm) {
        this.baseFare = baseFare;
        this.perKmRate = perKmRate;
        this.maxPickupRadiusKm = maxPickupRadiusKm;
    }

    public double getBaseFare() {
        return baseFare;
    }

    public double getPerKmRate() {
        return perKmRate;
    }

    public double getMaxPickupRadiusKm() {
        return maxPickupRadiusKm;
    }
}
