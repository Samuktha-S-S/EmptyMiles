package com.emptymiles.controller.customer;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.Booking;
import com.emptymiles.model.User;
import com.emptymiles.model.enums.DeliveryStatus;
import com.emptymiles.service.BookingService;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The customer's dashboard plus three list pages built from the same data:
 *   /customer/shipments      every shipment
 *   /customer/find-vehicles  shipments still waiting for a vehicle
 *   /customer/track          bookings that can be tracked
 */
@WebServlet({"/customer/dashboard", "/customer/shipments", "/customer/find-vehicles", "/customer/track"})
public class CustomerDashboardServlet extends BaseServlet {

    private final ShipmentService shipmentService = new ShipmentService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        List<Booking> bookings = bookingService.getCustomerBookings(user.getId());
        req.setAttribute("shipments", shipmentService.getCustomerShipments(user.getId()));
        req.setAttribute("bookings", bookings);
        req.setAttribute("bookingByShipment", liveBookingByShipment(bookings));

        String path = req.getServletPath();
        if (path.equals("/customer/dashboard")) {
            forward(req, resp, AppConstants.VIEW_CUSTOMER_DASHBOARD);
            return;
        }
        req.setAttribute("mode", switch (path) {
            case "/customer/find-vehicles" -> "open";
            case "/customer/track" -> "track";
            default -> "all";
        });
        forward(req, resp, AppConstants.VIEW_CUSTOMER_SHIPMENTS);
    }

    /** Shipment id -> its newest booking that was not cancelled, so each row can link to it. */
    private Map<Integer, Booking> liveBookingByShipment(List<Booking> bookings) {
        Map<Integer, Booking> map = new HashMap<>();
        for (Booking b : bookings) {   // newest first
            if (b.getStatus() != DeliveryStatus.CANCELLED) {
                map.putIfAbsent(b.getShipmentId(), b);
            }
        }
        return map;
    }
}
