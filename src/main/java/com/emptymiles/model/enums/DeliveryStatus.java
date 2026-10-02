package com.emptymiles.model.enums;

/**
 * Life cycle of a shipment and its booking, in order.
 * CANCELLED is used when a partner rejects a booking request.
 */
public enum DeliveryStatus {
    REQUESTED("Requested"),
    SEARCHING("Searching for vehicles"),
    MATCHED("Waiting for partner"),
    PARTNER_ACCEPTED("Partner accepted"),
    PARTNER_ARRIVING("Partner on the way to pickup"),
    ARRIVED_AT_PICKUP("Partner at pickup"),
    PICKED_UP("Picked up"),
    IN_TRANSIT("In transit"),
    ARRIVED_AT_DESTINATION("Arrived at destination"),
    DELIVERED("Delivered (OTP verified)"),
    COMPLETED("Completed"),
    CANCELLED("Cancelled");

    private final String label;

    DeliveryStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** The status that follows this one in a normal delivery, or null at the end. */
    public DeliveryStatus next() {
        if (this == COMPLETED || this == CANCELLED) {
            return null;
        }
        return values()[ordinal() + 1];
    }

    /** True while the booking is between acceptance and completion. */
    public boolean isActiveDelivery() {
        return ordinal() >= PARTNER_ACCEPTED.ordinal() && ordinal() <= DELIVERED.ordinal();
    }

    /** True when the booking can no longer change. */
    public boolean isFinished() {
        return this == COMPLETED || this == CANCELLED;
    }
}
