package com.emptymiles.model;

import java.time.LocalDateTime;

/** OTP the customer shares with the partner to confirm delivery (table: delivery_otps). */
public class DeliveryOTP {

    private int id;
    private int bookingId;
    private String otp;
    private boolean verified;
    private LocalDateTime createdAt;
    private LocalDateTime verifiedAt;

    public DeliveryOTP() {
    }

    public DeliveryOTP(int bookingId, String otp) {
        this.bookingId = bookingId;
        this.otp = otp;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getVerifiedAt() { return verifiedAt; }
    public void setVerifiedAt(LocalDateTime verifiedAt) { this.verifiedAt = verifiedAt; }
}
