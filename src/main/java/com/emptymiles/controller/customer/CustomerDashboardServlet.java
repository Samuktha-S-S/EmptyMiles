package com.emptymiles.controller.customer;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.User;
import com.emptymiles.service.BookingService;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/customer/dashboard")
public class CustomerDashboardServlet extends BaseServlet {

    private final ShipmentService shipmentService = new ShipmentService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        req.setAttribute("shipments", shipmentService.getCustomerShipments(user.getId()));
        req.setAttribute("bookings", bookingService.getCustomerBookings(user.getId()));
        forward(req, resp, AppConstants.VIEW_CUSTOMER_DASHBOARD);
    }
}
