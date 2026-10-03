package com.emptymiles.model.enums;

/**
 * Life cycle of a shipment and its booking, in order.
 * CANCELLED is used when a partner rejects a booking request.
 */
public enum DeliveryStatus {
    REQUESTED("Requested", "Requested", "Pending", "pending"),
    SEARCHING("Searching for vehicles", "Searching", "Pending", "pending"),
    MATCHED("Waiting for partner", "Matched", "Matched", "matched"),
    PARTNER_ACCEPTED("Partner accepted", "Partner accepted", "Confirmed", "confirmed"),
    PARTNER_ARRIVING("Partner on the way to pickup", "Partner arriving", "Confirmed", "confirmed"),
    ARRIVED_AT_PICKUP("Partner at pickup", "Arrived at pickup", "Confirmed", "confirmed"),
    PICKED_UP("Picked up", "Picked up", "In Transit", "transit"),
    IN_TRANSIT("In transit", "In transit", "In Transit", "transit"),
    ARRIVED_AT_DESTINATION("Arrived at destination", "Arrived at destination", "In Transit", "transit"),
    DELIVERED("Delivered (OTP verified)", "Delivered", "Delivered", "success"),
    COMPLETED("Completed", "Completed", "Completed", "success"),
    CANCELLED("Cancelled", "Cancelled", "Cancelled", "danger");

    private final String label;
    private final String stepLabel;
    private final String stage;
    private final String tone;

    DeliveryStatus(String label, String stepLabel, String stage, String tone) {
        this.label = label;
        this.stepLabel = stepLabel;
        this.stage = stage;
        this.tone = tone;
    }

    public String getLabel() {
        return label;
    }

    /** Short name for one step of the delivery timeline. */
    public String getStepLabel() {
        return stepLabel;
    }

    /** Customer-facing group shown on badges: Pending, Matched, Confirmed, In Transit, Delivered, Completed, Cancelled. */
    public String getStage() {
        return stage;
    }

    /** Colour family of the badge (CSS class suffix): pending, matched, confirmed, transit, success, danger. */
    public String getTone() {
        return tone;
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
