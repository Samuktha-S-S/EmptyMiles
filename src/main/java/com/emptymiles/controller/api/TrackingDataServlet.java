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

/** Polled by tracking.js: GET /api/tracking?bookingId=5 returns the latest status and position as JSON. */
@WebServlet("/api/tracking")
public class TrackingDataServlet extends BaseServlet {

    private final TrackingService trackingService = new TrackingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setHeader("Cache-Control", "no-store");
        try {
            int bookingId = ValidationUtil.parseId(req.getParameter("bookingId"), "Booking");
            resp.getWriter().write(trackingService.getTrackingInfo(currentUser(req).getId(), bookingId).toJson());
        } catch (ValidationException | AuthenticationException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
