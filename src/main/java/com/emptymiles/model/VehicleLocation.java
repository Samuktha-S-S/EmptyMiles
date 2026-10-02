package com.emptymiles.model;

import java.time.LocalDateTime;

/** One GPS point sent by a partner's browser (table: vehicle_locations). */
public class VehicleLocation {

    private long id;
    private int vehicleId;
    private Integer bookingId;   // null when the vehicle is not on a delivery
    private double latitude;
    private double longitude;
    private LocalDateTime recordedAt;

    public VehicleLocation() {
    }

    public VehicleLocation(int vehicleId, Integer bookingId, double latitude, double longitude) {
        this.vehicleId = vehicleId;
        this.bookingId = bookingId;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public LocalDateTime getRecordedAt() { return recordedAt; }
    public void setRecordedAt(LocalDateTime recordedAt) { this.recordedAt = recordedAt; }
}
