package com.emptymiles.model;

import com.emptymiles.model.enums.VehicleStatus;
import com.emptymiles.model.enums.VehicleType;

/** A partner's vehicle with its capacity, load and live position (table: vehicles). */
public class Vehicle {

    private int id;
    private int partnerId;
    private VehicleType vehicleType;
    private String vehicleNumber;
    private double totalCapacity;      // kg
    private double currentLoad;        // kg
    private double availableCapacity;  // totalCapacity - currentLoad
    private VehicleStatus status;
    private Double currentLatitude;    // null until the partner shares a location
    private Double currentLongitude;
    private String destination;        // where the vehicle is already heading (optional)
    private Double destinationLatitude;
    private Double destinationLongitude;

    // Display only, filled by joins with the users table
    private String partnerName;
    private String partnerPhone;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPartnerId() { return partnerId; }
    public void setPartnerId(int partnerId) { this.partnerId = partnerId; }

    public VehicleType getVehicleType() { return vehicleType; }
    public void setVehicleType(VehicleType vehicleType) { this.vehicleType = vehicleType; }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public double getTotalCapacity() { return totalCapacity; }
    public void setTotalCapacity(double totalCapacity) { this.totalCapacity = totalCapacity; }

    public double getCurrentLoad() { return currentLoad; }
    public void setCurrentLoad(double currentLoad) { this.currentLoad = currentLoad; }

    public double getAvailableCapacity() { return availableCapacity; }
    public void setAvailableCapacity(double availableCapacity) { this.availableCapacity = availableCapacity; }

    public VehicleStatus getStatus() { return status; }
    public void setStatus(VehicleStatus status) { this.status = status; }

    public Double getCurrentLatitude() { return currentLatitude; }
    public void setCurrentLatitude(Double currentLatitude) { this.currentLatitude = currentLatitude; }

    public Double getCurrentLongitude() { return currentLongitude; }
    public void setCurrentLongitude(Double currentLongitude) { this.currentLongitude = currentLongitude; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public Double getDestinationLatitude() { return destinationLatitude; }
    public void setDestinationLatitude(Double destinationLatitude) { this.destinationLatitude = destinationLatitude; }

    public Double getDestinationLongitude() { return destinationLongitude; }
    public void setDestinationLongitude(Double destinationLongitude) { this.destinationLongitude = destinationLongitude; }

    public String getPartnerName() { return partnerName; }
    public void setPartnerName(String partnerName) { this.partnerName = partnerName; }

    public String getPartnerPhone() { return partnerPhone; }
    public void setPartnerPhone(String partnerPhone) { this.partnerPhone = partnerPhone; }

    public boolean hasLocation() {
        return currentLatitude != null && currentLongitude != null;
    }

    public boolean hasDestination() {
        return destinationLatitude != null && destinationLongitude != null;
    }
}
