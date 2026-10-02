package com.emptymiles.dao;

import com.emptymiles.model.Shipment;
import com.emptymiles.model.enums.DeliveryStatus;

import java.util.List;

/** Database operations on the shipments table. */
public interface ShipmentDAO {

    int create(Shipment shipment);

    Shipment findById(int id);

    List<Shipment> findByCustomerId(int customerId);

    void updateStatus(int shipmentId, DeliveryStatus status);
}
