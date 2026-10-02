package com.emptymiles.dto;

import com.emptymiles.model.enums.DeliveryStatus;

import java.time.LocalDateTime;

/** Live state of a booking, returned as JSON to tracking.js. */
public class TrackingInfo {

    private int bookingId;
    private DeliveryStatus status;
    private Double latitude;              // latest vehicle position, null if none yet
    private Double longitude;
    private LocalDateTime lastUpdated;
    private Double distanceToPickupKm;
    private Double distanceToDestinationKm;

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public DeliveryStatus getStatus() { return status; }
    public void setStatus(DeliveryStatus status) { this.status = status; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }

    public Double getDistanceToPickupKm() { return distanceToPickupKm; }
    public void setDistanceToPickupKm(Double distanceToPickupKm) { this.distanceToPickupKm = distanceToPickupKm; }

    public Double getDistanceToDestinationKm() { return distanceToDestinationKm; }
    public void setDistanceToDestinationKm(Double distanceToDestinationKm) { this.distanceToDestinationKm = distanceToDestinationKm; }

    /** Small hand-written JSON so no JSON library is needed. */
    public String toJson() {
        return "{"
                + "\"bookingId\":" + bookingId
                + ",\"status\":\"" + status.name() + "\""
                + ",\"statusLabel\":\"" + status.getLabel() + "\""
                + ",\"latitude\":" + latitude
                + ",\"longitude\":" + longitude
                + ",\"lastUpdated\":" + (lastUpdated == null ? "null" : "\"" + lastUpdated.withNano(0).toString().replace('T', ' ') + "\"")
                + ",\"distanceToPickupKm\":" + distanceToPickupKm
                + ",\"distanceToDestinationKm\":" + distanceToDestinationKm
                + "}";
    }
}
