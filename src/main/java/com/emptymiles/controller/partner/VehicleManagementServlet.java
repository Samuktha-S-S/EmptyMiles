package com.emptymiles.controller.partner;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.model.User;
import com.emptymiles.service.VehicleService;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Add vehicles and change their availability, location and route.
 * The form's hidden "action" field says which change to make.
 */
@WebServlet("/partner/vehicles")
public class VehicleManagementServlet extends BaseServlet {

    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("vehicles", vehicleService.getVehiclesForPartner(currentUser(req).getId()));
        forward(req, resp, AppConstants.VIEW_VEHICLE_MANAGEMENT);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                vehicleService.addVehicle(user.getId(),
                        req.getParameter("vehicleType"),
                        req.getParameter("vehicleNumber"),
                        req.getParameter("totalCapacity"),
                        req.getParameter("latitude"),
                        req.getParameter("longitude"));
                flash(req, "Vehicle added. Share its location and set it Available to start receiving bookings.");
            } else {
                int vehicleId = ValidationUtil.parseId(req.getParameter("vehicleId"), "Vehicle");
                switch (action == null ? "" : action) {
                    case "available" -> vehicleService.setAvailability(user.getId(), vehicleId, true);
                    case "offline" -> vehicleService.setAvailability(user.getId(), vehicleId, false);
                    case "location" -> vehicleService.updateLocation(user.getId(), vehicleId,
                            req.getParameter("latitude"), req.getParameter("longitude"));
                    case "route" -> vehicleService.updateRoute(user.getId(), vehicleId,
                            req.getParameter("destination"),
                            req.getParameter("destinationLatitude"),
                            req.getParameter("destinationLongitude"));
                    default -> throw new ValidationException("Unknown action.");
                }
                flash(req, "Vehicle updated.");
            }
            redirect(req, resp, "/partner/vehicles");
        } catch (ValidationException e) {
            req.setAttribute(AppConstants.ATTR_ERROR, e.getMessage());
            doGet(req, resp);
        }
    }
}
