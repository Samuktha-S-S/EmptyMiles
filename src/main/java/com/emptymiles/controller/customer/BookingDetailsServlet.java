package com.emptymiles.controller.customer;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.Booking;
import com.emptymiles.model.User;
import com.emptymiles.service.BookingService;
import com.emptymiles.service.OTPService;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.util.AppConstants;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/customer/booking")
public class BookingDetailsServlet extends BaseServlet {

    private final BookingService bookingService = new BookingService();
    private final ShipmentService shipmentService = new ShipmentService();
    private final OTPService otpService = new OTPService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        int bookingId = ValidationUtil.parseId(req.getParameter("id"), "Booking");
        Booking booking = bookingService.getBookingForCustomer(user.getId(), bookingId);
        req.setAttribute("booking", booking);
        req.setAttribute("shipment", shipmentService.getOwnedShipment(user.getId(), booking.getShipmentId()));
        req.setAttribute("otp", otpService.getForBooking(bookingId));
        forward(req, resp, AppConstants.VIEW_BOOKING_DETAILS);
    }
}
