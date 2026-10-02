package com.emptymiles.dao;

import com.emptymiles.model.Vehicle;

import java.util.List;

/** Database operations on the vehicles table. */
public interface VehicleDAO {

    int create(Vehicle vehicle);

    Vehicle findById(int id);

    List<Vehicle> findByPartnerId(int partnerId);

    /** AVAILABLE vehicles that have shared a location, with partner name/phone filled in. */
    List<Vehicle> findAvailableWithLocation();

    void updateStatus(int vehicleId, String status);

    void updateLocation(int vehicleId, double latitude, double longitude);

    void updateRoute(int vehicleId, String destination, Double latitude, Double longitude);

    /** Saves current_load, available_capacity and status together. */
    void updateLoad(int vehicleId, double currentLoad, double availableCapacity, String status);
}
