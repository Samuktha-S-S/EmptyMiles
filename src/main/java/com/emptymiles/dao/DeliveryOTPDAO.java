package com.emptymiles.dao;

import com.emptymiles.model.DeliveryOTP;

/** Database operations on the delivery_otps table. */
public interface DeliveryOTPDAO {

    void create(DeliveryOTP otp);

    DeliveryOTP findByBookingId(int bookingId);

    void markVerified(int otpId);
}
