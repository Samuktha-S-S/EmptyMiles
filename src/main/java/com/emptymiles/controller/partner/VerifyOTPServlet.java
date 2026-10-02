package com.emptymiles.controller.partner;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.exception.BookingException;
import com.emptymiles.service.BookingService;
import com.emptymiles.util.ValidationUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** Partner enters the OTP the customer gives them at the destination. */
@WebServlet("/partner/verify-otp")
public class VerifyOTPServlet extends BaseServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int bookingId = ValidationUtil.parseId(req.getParameter("bookingId"), "Booking");
        try {
            bookingService.verifyOtp(currentUser(req).getId(), bookingId, req.getParameter("otp"));
            flash(req, "OTP verified. Package delivered.");
        } catch (BookingException e) {
            flash(req, e.getMessage());
        }
        redirect(req, resp, "/partner/delivery?id=" + bookingId);
    }
}
