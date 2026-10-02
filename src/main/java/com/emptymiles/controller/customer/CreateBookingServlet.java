package com.emptymiles.controller.customer;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.Booking;
import com.emptymiles.service.BookingService;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** Customer picks a vehicle from the matched list. */
@WebServlet("/customer/book")
public class CreateBookingServlet extends BaseServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int shipmentId = ValidationUtil.parseId(req.getParameter("shipmentId"), "Shipment");
        int vehicleId = ValidationUtil.parseId(req.getParameter("vehicleId"), "Vehicle");
        Booking booking = bookingService.createBooking(currentUser(req).getId(), shipmentId, vehicleId);
        flash(req, "Booking request sent to the partner. You'll see the OTP here once they accept.");
        redirect(req, resp, "/customer/booking?id=" + booking.getId());
    }
}
