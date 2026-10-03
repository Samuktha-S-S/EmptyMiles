package com.emptymiles.controller.partner;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.dto.MatchResult;
import com.emptymiles.matching.VehicleMatchingService;
import com.emptymiles.model.Booking;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.User;
import com.emptymiles.model.enums.DeliveryStatus;
import com.emptymiles.service.BookingService;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.service.VehicleService;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** New booking requests waiting for the partner to accept or reject. */
@WebServlet("/partner/requests")
public class BookingRequestServlet extends BaseServlet {

    private final BookingService bookingService = new BookingService();
    private final ShipmentService shipmentService = new ShipmentService();
    private final VehicleService vehicleService = new VehicleService();
    private final VehicleMatchingService matchingService = new VehicleMatchingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        List<Booking> requests = bookingService.getPartnerBookings(user.getId()).stream()
                .filter(b -> b.getStatus() == DeliveryStatus.MATCHED)
                .toList();
        // Re-run the match for each request so the card can show distance and route fit right now
        // (null when the vehicle no longer fits, e.g. it went offline).
        Map<Integer, MatchResult> matchByBooking = new HashMap<>();
        for (Booking b : requests) {
            Shipment shipment = shipmentService.getOwnedShipment(b.getCustomerId(), b.getShipmentId());
            Vehicle vehicle = vehicleService.getOwnedVehicle(user.getId(), b.getVehicleId());
            matchByBooking.put(b.getId(), matchingService.evaluate(shipment, vehicle));
        }
        req.setAttribute("requests", requests);
        req.setAttribute("matchByBooking", matchByBooking);
        forward(req, resp, AppConstants.VIEW_BOOKING_REQUESTS);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        int bookingId = ValidationUtil.parseId(req.getParameter("bookingId"), "Booking");
        if ("accept".equals(req.getParameter("action"))) {
            bookingService.acceptBooking(user.getId(), bookingId);
            flash(req, "Booking #" + bookingId + " accepted. Head to the pickup point.");
            redirect(req, resp, "/partner/delivery?id=" + bookingId);
        } else {
            bookingService.rejectBooking(user.getId(), bookingId);
            flash(req, "Booking #" + bookingId + " rejected.");
            redirect(req, resp, "/partner/requests");
        }
    }
}
