package com.emptymiles.dao;

import com.emptymiles.model.Booking;
import com.emptymiles.model.enums.DeliveryStatus;

import java.util.List;

/** Database operations on the bookings table. Reads also fill the display fields via joins. */
public interface BookingDAO {

    int create(Booking booking);

    Booking findById(int id);

    List<Booking> findByCustomerId(int customerId);

    List<Booking> findByPartnerId(int partnerId);

    /** The booking of a shipment that is not CANCELLED, or null. */
    Booking findLiveByShipmentId(int shipmentId);

    void updateStatus(int bookingId, DeliveryStatus status);

    void markPickedUp(int bookingId);

    void markDelivered(int bookingId);
}
