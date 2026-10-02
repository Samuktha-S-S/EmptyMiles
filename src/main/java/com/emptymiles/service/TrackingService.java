package com.emptymiles.service;

import com.emptymiles.dao.BookingDAO;
import com.emptymiles.dao.ShipmentDAO;
import com.emptymiles.dao.VehicleDAO;
import com.emptymiles.dao.VehicleLocationDAO;
import com.emptymiles.dao.impl.BookingDAOImpl;
import com.emptymiles.dao.impl.ShipmentDAOImpl;
import com.emptymiles.dao.impl.VehicleDAOImpl;
import com.emptymiles.dao.impl.VehicleLocationDAOImpl;
import com.emptymiles.dto.TrackingInfo;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.model.Booking;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.VehicleLocation;
import com.emptymiles.util.GeoUtils;
import com.emptymiles.util.ValidationUtil;

/**
 * Live location: the partner's browser sends GPS points here, they are stored in
 * vehicle_locations, and the customer's tracking page reads the latest one back.
 */
public class TrackingService {

    private final VehicleDAO vehicleDAO;
    private final VehicleLocationDAO locationDAO;
    private final BookingDAO bookingDAO;
    private final ShipmentDAO shipmentDAO;

    public TrackingService() {
        this(new VehicleDAOImpl(), new VehicleLocationDAOImpl(), new BookingDAOImpl(), new ShipmentDAOImpl());
    }

    public TrackingService(VehicleDAO vehicleDAO, VehicleLocationDAO locationDAO,
                           BookingDAO bookingDAO, ShipmentDAO shipmentDAO) {
        this.vehicleDAO = vehicleDAO;
        this.locationDAO = locationDAO;
        this.bookingDAO = bookingDAO;
        this.shipmentDAO = shipmentDAO;
    }

    /**
     * Saves the vehicle's position. If a booking id is given and the delivery is active,
     * the point is also stored in the booking's tracking history.
     */
    public void recordLocation(int partnerId, int vehicleId, Integer bookingId, String latitude, String longitude) {
        Vehicle vehicle = vehicleDAO.findById(vehicleId);
        if (vehicle == null || vehicle.getPartnerId() != partnerId) {
            throw new AuthenticationException("This vehicle does not belong to you.");
        }
        double lat = ValidationUtil.requireLatitude(latitude, "Latitude");
        double lon = ValidationUtil.requireLongitude(longitude, "Longitude");
        vehicleDAO.updateLocation(vehicleId, lat, lon);

        Integer trackedBooking = null;
        if (bookingId != null) {
            Booking b = bookingDAO.findById(bookingId);
            if (b != null && b.getVehicleId() == vehicleId && b.getStatus().isActiveDelivery()) {
                trackedBooking = bookingId;
            }
        }
        locationDAO.save(new VehicleLocation(vehicleId, trackedBooking, lat, lon));
    }

    public TrackingInfo getTrackingInfo(int customerId, int bookingId) {
        Booking b = bookingDAO.findById(bookingId);
        if (b == null || b.getCustomerId() != customerId) {
            throw new AuthenticationException("This booking does not belong to you.");
        }
        TrackingInfo info = new TrackingInfo();
        info.setBookingId(bookingId);
        info.setStatus(b.getStatus());

        // Prefer the booking's own history; fall back to the vehicle's last known position
        VehicleLocation latest = locationDAO.findLatestByBookingId(bookingId);
        Vehicle vehicle = vehicleDAO.findById(b.getVehicleId());
        if (latest != null) {
            info.setLatitude(latest.getLatitude());
            info.setLongitude(latest.getLongitude());
            info.setLastUpdated(latest.getRecordedAt());
        } else if (vehicle != null && vehicle.hasLocation()) {
            info.setLatitude(vehicle.getCurrentLatitude());
            info.setLongitude(vehicle.getCurrentLongitude());
        }

        if (info.getLatitude() != null) {
            Shipment s = shipmentDAO.findById(b.getShipmentId());
            info.setDistanceToPickupKm(GeoUtils.round2(GeoUtils.haversineKm(info.getLatitude(), info.getLongitude(),
                    s.getPickupLatitude(), s.getPickupLongitude())));
            info.setDistanceToDestinationKm(GeoUtils.round2(GeoUtils.haversineKm(info.getLatitude(), info.getLongitude(),
                    s.getDestinationLatitude(), s.getDestinationLongitude())));
        }
        return info;
    }
}
