package com.emptymiles.controller.partner;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.User;
import com.emptymiles.service.BookingService;
import com.emptymiles.service.VehicleService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/partner/dashboard")
public class PartnerDashboardServlet extends BaseServlet {

    private final VehicleService vehicleService = new VehicleService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        req.setAttribute("vehicles", vehicleService.getVehiclesForPartner(user.getId()));
        req.setAttribute("bookings", bookingService.getPartnerBookings(user.getId()));
        forward(req, resp, AppConstants.VIEW_PARTNER_DASHBOARD);
    }
}
