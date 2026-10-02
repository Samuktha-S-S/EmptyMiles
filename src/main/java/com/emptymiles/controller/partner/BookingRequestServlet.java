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

/** New booking requests waiting for the partner to accept or reject. */
@WebServlet("/partner/requests")
public class BookingRequestServlet extends BaseServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Booking> requests = bookingService.getPartnerBookings(currentUser(req).getId()).stream()
                .filter(b -> b.getStatus() == DeliveryStatus.MATCHED)
                .toList();
        req.setAttribute("requests", requests);
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
