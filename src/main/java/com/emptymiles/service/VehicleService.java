package com.emptymiles.service;

import com.emptymiles.dao.VehicleDAO;
import com.emptymiles.dao.impl.VehicleDAOImpl;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.enums.VehicleStatus;
import com.emptymiles.model.enums.VehicleType;
import com.emptymiles.util.ValidationUtil;

import java.sql.SQLException;
import java.util.List;

/** Vehicle registration, availability, location, route and load for delivery partners. */
public class VehicleService {

    private final VehicleDAO vehicleDAO;

    public VehicleService() {
        this(new VehicleDAOImpl());
    }

    public VehicleService(VehicleDAO vehicleDAO) {
        this.vehicleDAO = vehicleDAO;
    }

    public Vehicle addVehicle(int partnerId, String type, String number, String totalCapacity,
                              String latitude, String longitude) {
        Vehicle v = new Vehicle();
        v.setPartnerId(partnerId);
        try {
            v.setVehicleType(VehicleType.valueOf(ValidationUtil.requireText(type, "Vehicle type")));
        } catch (IllegalArgumentException e) {
            throw new ValidationException("Choose Bike, Auto or Truck.");
        }
        v.setVehicleNumber(ValidationUtil.requireVehicleNumber(number));
        v.setTotalCapacity(ValidationUtil.requirePositive(totalCapacity, "Total capacity"));
        v.setCurrentLoad(0);
        v.setAvailableCapacity(v.getTotalCapacity());
        v.setStatus(VehicleStatus.OFFLINE);
        Double lat = ValidationUtil.optionalDouble(latitude, "Latitude");
        Double lon = ValidationUtil.optionalDouble(longitude, "Longitude");
        if (lat != null && lon != null) {
            v.setCurrentLatitude(lat);
            v.setCurrentLongitude(lon);
        }
        try {
            v.setId(vehicleDAO.create(v));
        } catch (DataAccessException e) {
            // SQLState 23xxx = integrity constraint violation (here: duplicate vehicle_number)
            if (e.getCause() instanceof SQLException sql && sql.getSQLState() != null && sql.getSQLState().startsWith("23")) {
                throw new ValidationException("A vehicle with number " + v.getVehicleNumber() + " is already registered.");
            }
            throw e;
        }
        return v;
    }

    public List<Vehicle> getVehiclesForPartner(int partnerId) {
        return vehicleDAO.findByPartnerId(partnerId);
    }

    /** Loads a vehicle and checks it belongs to this partner. */
    public Vehicle getOwnedVehicle(int partnerId, int vehicleId) {
        Vehicle v = vehicleDAO.findById(vehicleId);
        if (v == null || v.getPartnerId() != partnerId) {
            throw new AuthenticationException("This vehicle does not belong to you.");
        }
        return v;
    }

    /** Partner switches a vehicle between AVAILABLE and OFFLINE. */
    public void setAvailability(int partnerId, int vehicleId, boolean available) {
        Vehicle v = getOwnedVehicle(partnerId, vehicleId);
        if (available && !v.hasLocation()) {
            throw new ValidationException("Share the vehicle's current location before going available.");
        }
        VehicleStatus status;
        if (!available) {
            status = VehicleStatus.OFFLINE;
        } else {
            status = v.getAvailableCapacity() > 0 ? VehicleStatus.AVAILABLE : VehicleStatus.BUSY;
        }
        vehicleDAO.updateStatus(vehicleId, status.name());
    }

    public void updateLocation(int partnerId, int vehicleId, String latitude, String longitude) {
        getOwnedVehicle(partnerId, vehicleId);
        double lat = ValidationUtil.requireLatitude(latitude, "Latitude");
        double lon = ValidationUtil.requireLongitude(longitude, "Longitude");
        vehicleDAO.updateLocation(vehicleId, lat, lon);
    }

    /** Where the vehicle is already going. Leave all fields empty to clear the route. */
    public void updateRoute(int partnerId, int vehicleId, String destination, String latitude, String longitude) {
        getOwnedVehicle(partnerId, vehicleId);
        if (destination == null || destination.isBlank()) {
            vehicleDAO.updateRoute(vehicleId, null, null, null);
            return;
        }
        double lat = ValidationUtil.requireLatitude(latitude, "Destination latitude");
        double lon = ValidationUtil.requireLongitude(longitude, "Destination longitude");
        vehicleDAO.updateRoute(vehicleId, destination.trim(), lat, lon);
    }

    /**
     * Adds (positive) or removes (negative) weight from a vehicle and keeps
     * availableCapacity = totalCapacity - currentLoad. A full vehicle becomes BUSY.
     */
    void changeLoad(int vehicleId, double deltaKg) {
        Vehicle v = vehicleDAO.findById(vehicleId);
        double load = Math.max(0, v.getCurrentLoad() + deltaKg);
        double available = Math.max(0, v.getTotalCapacity() - load);
        VehicleStatus status = v.getStatus();
        if (status != VehicleStatus.OFFLINE) {
            status = available > 0 ? VehicleStatus.AVAILABLE : VehicleStatus.BUSY;
        }
        vehicleDAO.updateLoad(vehicleId, load, available, status.name());
    }

    Vehicle findById(int vehicleId) {
        return vehicleDAO.findById(vehicleId);
    }
}
