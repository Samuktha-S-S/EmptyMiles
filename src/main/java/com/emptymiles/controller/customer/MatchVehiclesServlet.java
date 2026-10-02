package com.emptymiles.controller.customer;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.matching.VehicleMatchingService;
import com.emptymiles.model.Shipment;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** Runs the matching engine for a shipment and shows the ranked vehicles. */
@WebServlet("/customer/matches")
public class MatchVehiclesServlet extends BaseServlet {

    private final ShipmentService shipmentService = new ShipmentService();
    private final VehicleMatchingService matchingService = new VehicleMatchingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int shipmentId = ValidationUtil.parseId(req.getParameter("shipmentId"), "Shipment");
        Shipment shipment = shipmentService.getOwnedShipment(currentUser(req).getId(), shipmentId);
        if (!shipment.isOpenForBooking()) {
            flash(req, "Shipment #" + shipmentId + " already has a booking.");
            redirect(req, resp, "/customer/dashboard");
            return;
        }
        shipmentService.markSearching(shipment);
        req.setAttribute("shipment", shipment);
        req.setAttribute("matches", matchingService.findMatches(shipment));
        forward(req, resp, AppConstants.VIEW_MATCHED_VEHICLES);
    }
}
