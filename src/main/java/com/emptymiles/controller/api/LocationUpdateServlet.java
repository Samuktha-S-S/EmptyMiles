package com.emptymiles.controller.api;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.service.TrackingService;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Called by location-sender.js (fetch POST) with vehicleId, bookingId (optional), latitude, longitude.
 * Replies with a small JSON object instead of a page.
 */
@WebServlet("/api/location")
public class LocationUpdateServlet extends BaseServlet {

    private final TrackingService trackingService = new TrackingService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        try {
            int vehicleId = ValidationUtil.parseId(req.getParameter("vehicleId"), "Vehicle");
            String booking = req.getParameter("bookingId");
            Integer bookingId = (booking == null || booking.isBlank()) ? null : ValidationUtil.parseId(booking, "Booking");
            trackingService.recordLocation(currentUser(req).getId(), vehicleId, bookingId,
                    req.getParameter("latitude"), req.getParameter("longitude"));
            resp.getWriter().write("{\"ok\":true}");
        } catch (ValidationException | AuthenticationException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"ok\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
