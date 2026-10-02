package com.emptymiles.dao.impl;

import com.emptymiles.dao.DeliveryOTPDAO;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.model.DeliveryOTP;
import com.emptymiles.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DeliveryOTPDAOImpl implements DeliveryOTPDAO {

    @Override
    public void create(DeliveryOTP otp) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("INSERT INTO delivery_otps (booking_id, otp) VALUES (?, ?)")) {
            ps.setInt(1, otp.getBookingId());
            ps.setString(2, otp.getOtp());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("Could not save OTP", e);
        }
    }

    @Override
    public DeliveryOTP findByBookingId(int bookingId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM delivery_otps WHERE booking_id = ?")) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                DeliveryOTP otp = new DeliveryOTP();
                otp.setId(rs.getInt("id"));
                otp.setBookingId(rs.getInt("booking_id"));
                otp.setOtp(rs.getString("otp"));
                otp.setVerified(rs.getBoolean("verified"));
                otp.setCreatedAt(JdbcHelper.getDateTime(rs, "created_at"));
                otp.setVerifiedAt(JdbcHelper.getDateTime(rs, "verified_at"));
                return otp;
            }
        } catch (SQLException e) {
            throw new DataAccessException("Could not load OTP", e);
        }
    }

    @Override
    public void markVerified(int otpId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE delivery_otps SET verified = TRUE, verified_at = CURRENT_TIMESTAMP WHERE id = ?")) {
            ps.setInt(1, otpId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("Could not update OTP", e);
        }
    }
}
