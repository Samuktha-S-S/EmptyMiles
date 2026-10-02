package com.emptymiles.dao;

import com.emptymiles.model.VehicleLocation;

/** Database operations on the vehicle_locations table. */
public interface VehicleLocationDAO {

    void save(VehicleLocation location);

    /** Latest point recorded for a booking, or null. */
    VehicleLocation findLatestByBookingId(int bookingId);
}
