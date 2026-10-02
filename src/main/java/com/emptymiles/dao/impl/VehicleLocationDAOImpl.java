package com.emptymiles.dao.impl;

import com.emptymiles.dao.VehicleLocationDAO;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.model.VehicleLocation;
import com.emptymiles.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class VehicleLocationDAOImpl implements VehicleLocationDAO {

    @Override
    public void save(VehicleLocation loc) {
        String sql = "INSERT INTO vehicle_locations (vehicle_id, booking_id, latitude, longitude) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, loc.getVehicleId());
            if (loc.getBookingId() == null) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, loc.getBookingId());
            }
            ps.setDouble(3, loc.getLatitude());
            ps.setDouble(4, loc.getLongitude());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("Could not save location", e);
        }
    }

    @Override
    public VehicleLocation findLatestByBookingId(int bookingId) {
        String sql = "SELECT * FROM vehicle_locations WHERE booking_id = ? ORDER BY recorded_at DESC, id DESC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                VehicleLocation loc = new VehicleLocation();
                loc.setId(rs.getLong("id"));
                loc.setVehicleId(rs.getInt("vehicle_id"));
                loc.setBookingId(rs.getInt("booking_id"));
                loc.setLatitude(rs.getDouble("latitude"));
                loc.setLongitude(rs.getDouble("longitude"));
                loc.setRecordedAt(JdbcHelper.getDateTime(rs, "recorded_at"));
                return loc;
            }
        } catch (SQLException e) {
            throw new DataAccessException("Could not load location", e);
        }
    }
}
