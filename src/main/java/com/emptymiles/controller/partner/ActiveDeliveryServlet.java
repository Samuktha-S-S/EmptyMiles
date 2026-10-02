package com.emptymiles.controller.partner;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.Booking;
import com.emptymiles.model.User;
import com.emptymiles.model.enums.DeliveryStatus;
import com.emptymiles.service.BookingService;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Without an id: list of the partner's active deliveries.
 * With ?id=: one delivery, with buttons to move the status forward and share location.
 */
@WebServlet("/partner/delivery")
public class ActiveDeliveryServlet extends BaseServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        String id = req.getParameter("id");
        if (id == null || id.isBlank()) {
            List<Booking> active = bookingService.getPartnerBookings(user.getId()).stream()
                    .filter(b -> b.getStatus().isActiveDelivery())
                    .toList();
            req.setAttribute("activeBookings", active);
        } else {
            Booking booking = bookingService.getBookingForPartner(user.getId(), ValidationUtil.parseId(id, "Booking"));
            req.setAttribute("booking", booking);
            req.setAttribute("nextStatus", booking.getStatus().next());
            req.setAttribute("statuses", DeliveryStatus.values());
            req.setAttribute("locationIntervalSeconds", AppConstants.LOCATION_UPDATE_SECONDS);
        }
        forward(req, resp, AppConstants.VIEW_ACTIVE_DELIVERY);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        int bookingId = ValidationUtil.parseId(req.getParameter("bookingId"), "Booking");
        if ("complete".equals(req.getParameter("action"))) {
            bookingService.completeDelivery(user.getId(), bookingId);
            req.setAttribute(AppConstants.ATTR_MESSAGE, "Delivery #" + bookingId + " completed. The vehicle's load has been released.");
            req.setAttribute("backUrl", "/partner/dashboard");
            forward(req, resp, AppConstants.VIEW_SUCCESS);
            return;
        }
        DeliveryStatus next = bookingService.advanceStatus(user.getId(), bookingId);
        flash(req, "Status updated: " + next.getLabel());
        redirect(req, resp, "/partner/delivery?id=" + bookingId);
    }
}
