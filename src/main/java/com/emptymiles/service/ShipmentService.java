package com.emptymiles.service;

import com.emptymiles.dao.ShipmentDAO;
import com.emptymiles.dao.impl.ShipmentDAOImpl;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.enums.DeliveryStatus;
import com.emptymiles.util.ValidationUtil;

import java.util.List;

/** Creating and reading a customer's shipments. */
public class ShipmentService {

    private final ShipmentDAO shipmentDAO;

    public ShipmentService() {
        this(new ShipmentDAOImpl());
    }

    public ShipmentService(ShipmentDAO shipmentDAO) {
        this.shipmentDAO = shipmentDAO;
    }

    public Shipment createShipment(int customerId,
                                   String pickupAddress, String pickupLat, String pickupLng,
                                   String destinationAddress, String destinationLat, String destinationLng,
                                   String productName, String productType, String quantity, String weight,
                                   String lengthCm, String widthCm, String heightCm, String specialRequirements,
                                   String pickupDate, String pickupTimeSlot, String specialInstructions) {
        Shipment s = new Shipment();
        s.setCustomerId(customerId);
        s.setPickupAddress(ValidationUtil.requireText(pickupAddress, "Pickup address"));
        s.setPickupLatitude(ValidationUtil.requireLatitude(pickupLat, "Pickup latitude"));
        s.setPickupLongitude(ValidationUtil.requireLongitude(pickupLng, "Pickup longitude"));
        s.setDestinationAddress(ValidationUtil.requireText(destinationAddress, "Destination address"));
        s.setDestinationLatitude(ValidationUtil.requireLatitude(destinationLat, "Destination latitude"));
        s.setDestinationLongitude(ValidationUtil.requireLongitude(destinationLng, "Destination longitude"));
        s.setProductName(ValidationUtil.requireText(productName, "Product name"));
        s.setProductType(ValidationUtil.requireText(productType, "Product type"));
        s.setQuantity(ValidationUtil.requirePositiveInt(quantity, "Quantity"));
        s.setWeight(ValidationUtil.requirePositive(weight, "Weight"));
        s.setLengthCm(ValidationUtil.optionalPositive(lengthCm, "Length"));
        s.setWidthCm(ValidationUtil.optionalPositive(widthCm, "Width"));
        s.setHeightCm(ValidationUtil.optionalPositive(heightCm, "Height"));
        s.setSpecialRequirements(ValidationUtil.optionalText(specialRequirements, "Special requirements", 255));
        s.setPickupDate(ValidationUtil.optionalFutureDate(pickupDate, "Pickup date"));
        s.setPickupTimeSlot(ValidationUtil.optionalText(pickupTimeSlot, "Preferred pickup time", 20));
        s.setSpecialInstructions(ValidationUtil.optionalText(specialInstructions, "Special instructions", 500));
        s.setStatus(DeliveryStatus.REQUESTED);
        s.setId(shipmentDAO.create(s));
        return s;
    }

    /** Loads a shipment and checks it belongs to this customer. */
    public Shipment getOwnedShipment(int customerId, int shipmentId) {
        Shipment s = shipmentDAO.findById(shipmentId);
        if (s == null || s.getCustomerId() != customerId) {
            throw new AuthenticationException("This shipment does not belong to you.");
        }
        return s;
    }

    public List<Shipment> getCustomerShipments(int customerId) {
        return shipmentDAO.findByCustomerId(customerId);
    }

    /** Called when the customer searches for vehicles. */
    public void markSearching(Shipment shipment) {
        if (shipment.getStatus() == DeliveryStatus.REQUESTED) {
            shipmentDAO.updateStatus(shipment.getId(), DeliveryStatus.SEARCHING);
            shipment.setStatus(DeliveryStatus.SEARCHING);
        }
    }

    /** Shipments still waiting for a vehicle, from every customer (used by the partner's matching view). */
    public List<Shipment> getOpenShipments() {
        return shipmentDAO.findOpen();
    }

    void updateStatus(int shipmentId, DeliveryStatus status) {
        shipmentDAO.updateStatus(shipmentId, status);
    }
}
