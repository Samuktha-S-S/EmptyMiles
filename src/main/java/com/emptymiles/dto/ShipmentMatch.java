package com.emptymiles.dto;

import com.emptymiles.model.Shipment;

/** An open shipment and how well one of the partner's vehicles fits it. */
public class ShipmentMatch {

    private final Shipment shipment;
    private final MatchResult match;

    public ShipmentMatch(Shipment shipment, MatchResult match) {
        this.shipment = shipment;
        this.match = match;
    }

    public Shipment getShipment() { return shipment; }
    public MatchResult getMatch() { return match; }
}
