package com.emptymiles.service;

import com.emptymiles.dao.BookingDAO;
import com.emptymiles.dao.impl.BookingDAOImpl;
import com.emptymiles.dto.MatchResult;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.exception.BookingException;
import com.emptymiles.matching.VehicleMatchingService;
import com.emptymiles.model.Booking;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.enums.DeliveryStatus;

import java.util.List;

/**
 * The booking workflow:
 *
 *   customer selects a vehicle      -> MATCHED            (request sent to partner)
 *   partner accepts                 -> PARTNER_ACCEPTED   (weight reserved on vehicle, OTP created)
 *   partner presses "next step"     -> PARTNER_ARRIVING -> ARRIVED_AT_PICKUP -> PICKED_UP
 *                                      -> IN_TRANSIT -> ARRIVED_AT_DESTINATION
 *   partner enters customer's OTP   -> DELIVERED
 *   partner completes               -> COMPLETED          (weight released from vehicle)
 *   partner rejects a request       -> CANCELLED          (customer can choose another vehicle)
 *
 * The shipment always carries the same status as its booking.
 */
public class BookingService {

    private final BookingDAO bookingDAO;
    private final ShipmentService shipmentService;
    private final VehicleService vehicleService;
    private final OTPService otpService;
    private final VehicleMatchingService matchingService;

    public BookingService() {
        this(new BookingDAOImpl(), new ShipmentService(), new VehicleService(), new OTPService(),
                new VehicleMatchingService());
    }

    public BookingService(BookingDAO bookingDAO, ShipmentService shipmentService, VehicleService vehicleService,
                          OTPService otpService, VehicleMatchingService matchingService) {
        this.bookingDAO = bookingDAO;
        this.shipmentService = shipmentService;
        this.vehicleService = vehicleService;
        this.otpService = otpService;
        this.matchingService = matchingService;
    }

    // ---------- customer actions ----------

    public Booking createBooking(int customerId, int shipmentId, int vehicleId) {
        Shipment shipment = shipmentService.getOwnedShipment(customerId, shipmentId);
        if (!shipment.isOpenForBooking() || bookingDAO.findLiveByShipmentId(shipmentId) != null) {
            throw new BookingException("This shipment already has a booking.");
        }
        Vehicle vehicle = vehicleService.findById(vehicleId);
        if (vehicle == null) {
            throw new BookingException("Vehicle not found.");
        }
        // Re-check the match: the vehicle may have filled up since the list was shown
        MatchResult match = matchingService.evaluate(shipment, vehicle);
        if (match == null) {
            throw new BookingException("This vehicle is no longer suitable. Please search again.");
        }

        Booking booking = new Booking();
        booking.setShipmentId(shipmentId);
        booking.setCustomerId(customerId);
        booking.setPartnerId(vehicle.getPartnerId());
        booking.setVehicleId(vehicleId);
        booking.setStatus(DeliveryStatus.MATCHED);
        booking.setMatchScore(match.getMatchScore());
        booking.setEstimatedCost(match.getEstimatedCost());
        booking.setId(bookingDAO.create(booking));
        shipmentService.updateStatus(shipmentId, DeliveryStatus.MATCHED);
        return booking;
    }

    public Booking getBookingForCustomer(int customerId, int bookingId) {
        Booking b = bookingDAO.findById(bookingId);
        if (b == null || b.getCustomerId() != customerId) {
            throw new AuthenticationException("This booking does not belong to you.");
        }
        return b;
    }

    public List<Booking> getCustomerBookings(int customerId) {
        return bookingDAO.findByCustomerId(customerId);
    }

    // ---------- partner actions ----------

    public Booking getBookingForPartner(int partnerId, int bookingId) {
        Booking b = bookingDAO.findById(bookingId);
        if (b == null || b.getPartnerId() != partnerId) {
            throw new AuthenticationException("This booking does not belong to you.");
        }
        return b;
    }

    public List<Booking> getPartnerBookings(int partnerId) {
        return bookingDAO.findByPartnerId(partnerId);
    }

    public void acceptBooking(int partnerId, int bookingId) {
        Booking b = getBookingForPartner(partnerId, bookingId);
        requireStatus(b, DeliveryStatus.MATCHED);
        Vehicle vehicle = vehicleService.findById(b.getVehicleId());
        if (b.getWeight() > vehicle.getAvailableCapacity()) {
            throw new BookingException("Not enough free capacity on " + vehicle.getVehicleNumber() + " to accept this.");
        }
        vehicleService.changeLoad(vehicle.getId(), b.getWeight());
        otpService.generateForBooking(bookingId);
        setStatus(b, DeliveryStatus.PARTNER_ACCEPTED);
    }

    public void rejectBooking(int partnerId, int bookingId) {
        Booking b = getBookingForPartner(partnerId, bookingId);
        requireStatus(b, DeliveryStatus.MATCHED);
        bookingDAO.updateStatus(bookingId, DeliveryStatus.CANCELLED);
        // Shipment goes back so the customer can pick another vehicle
        shipmentService.updateStatus(b.getShipmentId(), DeliveryStatus.REQUESTED);
    }

    /** Moves the booking one step along the route (PARTNER_ACCEPTED ... ARRIVED_AT_DESTINATION). */
    public DeliveryStatus advanceStatus(int partnerId, int bookingId) {
        Booking b = getBookingForPartner(partnerId, bookingId);
        DeliveryStatus next = b.getStatus().next();
        if (b.getStatus().ordinal() < DeliveryStatus.PARTNER_ACCEPTED.ordinal()
                || next == null || next.ordinal() > DeliveryStatus.ARRIVED_AT_DESTINATION.ordinal()) {
            throw new BookingException("Status cannot be moved forward from " + b.getStatus().getLabel() + ".");
        }
        if (next == DeliveryStatus.PICKED_UP) {
            bookingDAO.markPickedUp(bookingId);
        }
        setStatus(b, next);
        return next;
    }

    public void verifyOtp(int partnerId, int bookingId, String otp) {
        Booking b = getBookingForPartner(partnerId, bookingId);
        requireStatus(b, DeliveryStatus.ARRIVED_AT_DESTINATION);
        otpService.verify(bookingId, otp);
        bookingDAO.markDelivered(bookingId);
        setStatus(b, DeliveryStatus.DELIVERED);
    }

    public void completeDelivery(int partnerId, int bookingId) {
        Booking b = getBookingForPartner(partnerId, bookingId);
        requireStatus(b, DeliveryStatus.DELIVERED);
        vehicleService.changeLoad(b.getVehicleId(), -b.getWeight());
        setStatus(b, DeliveryStatus.COMPLETED);
    }

    private void requireStatus(Booking b, DeliveryStatus expected) {
        if (b.getStatus() != expected) {
            throw new BookingException("Booking #" + b.getId() + " is " + b.getStatus().getLabel()
                    + ", expected " + expected.getLabel() + ".");
        }
    }

    private void setStatus(Booking b, DeliveryStatus status) {
        bookingDAO.updateStatus(b.getId(), status);
        shipmentService.updateStatus(b.getShipmentId(), status);
        b.setStatus(status);
    }
}
