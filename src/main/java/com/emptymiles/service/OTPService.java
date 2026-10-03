package com.emptymiles.service;

import com.emptymiles.dao.DeliveryOTPDAO;
import com.emptymiles.dao.impl.DeliveryOTPDAOImpl;
import com.emptymiles.exception.BookingException;
import com.emptymiles.model.DeliveryOTP;
import com.emptymiles.util.OTPGenerator;

/**
 * Delivery OTP: created when the partner accepts a booking, shown to the customer,
 * and typed in by the partner at the destination to prove the hand-over.
 */
public class OTPService {

    private final DeliveryOTPDAO otpDAO;

    public OTPService() {
        this(new DeliveryOTPDAOImpl());
    }

    public OTPService(DeliveryOTPDAO otpDAO) {
        this.otpDAO = otpDAO;
    }

    public DeliveryOTP generateForBooking(int bookingId) {
        DeliveryOTP existing = otpDAO.findByBookingId(bookingId);
        if (existing != null) {
            return existing;
        }
        DeliveryOTP otp = new DeliveryOTP(bookingId, OTPGenerator.generate());
        otpDAO.create(otp);
        return otp;
    }

    public DeliveryOTP getForBooking(int bookingId) {
        return otpDAO.findByBookingId(bookingId);
    }

    public void verify(int bookingId, String enteredOtp) {
        DeliveryOTP otp = otpDAO.findByBookingId(bookingId);
        if (otp == null) {
            throw new BookingException("No OTP exists for this booking.");
        }
        if (otp.isVerified()) {
            throw new BookingException("OTP was already verified.");
        }
        if (enteredOtp == null || !otp.getOtp().equals(enteredOtp.trim())) {
            throw new BookingException("Incorrect OTP. Please try again. Ask the customer for the 4-digit code shown on their booking.");
        }
        otpDAO.markVerified(otp.getId());
    }
}
