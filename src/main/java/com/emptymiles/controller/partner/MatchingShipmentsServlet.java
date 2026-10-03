package com.emptymiles.controller.partner;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.dto.MatchResult;
import com.emptymiles.dto.ShipmentMatch;
import com.emptymiles.matching.VehicleMatchingService;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.service.VehicleService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Read-only view for partners: shipments still waiting for a vehicle that one of their
 * vehicles fits, scored by the same matching engine customers use. The customer still chooses.
 */
@WebServlet("/partner/matching-shipments")
public class MatchingShipmentsServlet extends BaseServlet {

    private final ShipmentService shipmentService = new ShipmentService();
    private final VehicleService vehicleService = new VehicleService();
    private final VehicleMatchingService matchingService = new VehicleMatchingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Vehicle> vehicles = vehicleService.getVehiclesForPartner(currentUser(req).getId());
        List<ShipmentMatch> matches = new ArrayList<>();
        for (Shipment shipment : shipmentService.getOpenShipments()) {
            for (Vehicle vehicle : vehicles) {
                MatchResult match = matchingService.evaluate(shipment, vehicle);
                if (match != null) {
                    matches.add(new ShipmentMatch(shipment, match));
                }
            }
        }
        matches.sort(Comparator.comparingDouble((ShipmentMatch m) -> m.getMatch().getMatchScore()).reversed());
        req.setAttribute("vehicles", vehicles);
        req.setAttribute("matches", matches);
        forward(req, resp, AppConstants.VIEW_MATCHING_SHIPMENTS);
    }
}
