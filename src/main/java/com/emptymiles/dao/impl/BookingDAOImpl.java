package com.emptymiles.dao.impl;

import com.emptymiles.dao.BookingDAO;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.model.Booking;
import com.emptymiles.model.enums.DeliveryStatus;
import com.emptymiles.model.enums.VehicleType;
import com.emptymiles.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BookingDAOImpl implements BookingDAO {

    private static final String SELECT_WITH_DETAILS =
            "SELECT b.*, s.product_name, s.weight, s.pickup_address, s.destination_address, "
            + "v.vehicle_number, v.vehicle_type, "
            + "c.name AS customer_name, c.phone AS customer_phone, "
            + "p.name AS partner_name, p.phone AS partner_phone "
            + "FROM bookings b "
            + "JOIN shipments s ON s.id = b.shipment_id "
            + "JOIN vehicles v ON v.id = b.vehicle_id "
            + "JOIN users c ON c.id = b.customer_id "
            + "JOIN users p ON p.id = b.partner_id ";

    @Override
    public int create(Booking b) {
        String sql = "INSERT INTO bookings (shipment_id, customer_id, partner_id, vehicle_id, status, match_score, "
                + "estimated_cost) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, b.getShipmentId());
            ps.setInt(2, b.getCustomerId());
            ps.setInt(3, b.getPartnerId());
            ps.setInt(4, b.getVehicleId());
            ps.setString(5, b.getStatus().name());
            ps.setDouble(6, b.getMatchScore());
            ps.setDouble(7, b.getEstimatedCost());
            ps.executeUpdate();
            return JdbcHelper.generatedId(ps);
        } catch (SQLException e) {
            throw new DataAccessException("Could not save booking", e);
        }
    }

    @Override
    public Booking findById(int id) {
        List<Booking> list = query(SELECT_WITH_DETAILS + "WHERE b.id = ?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public List<Booking> findByCustomerId(int customerId) {
        return query(SELECT_WITH_DETAILS + "WHERE b.customer_id = ? ORDER BY b.id DESC", customerId);
    }

    @Override
    public List<Booking> findByPartnerId(int partnerId) {
        return query(SELECT_WITH_DETAILS + "WHERE b.partner_id = ? ORDER BY b.id DESC", partnerId);
    }

    @Override
    public Booking findLiveByShipmentId(int shipmentId) {
        List<Booking> list = query(SELECT_WITH_DETAILS + "WHERE b.shipment_id = ? AND b.status <> 'CANCELLED'", shipmentId);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public void updateStatus(int bookingId, DeliveryStatus status) {
        update("UPDATE bookings SET status = ? WHERE id = ?", status.name(), bookingId);
    }

    @Override
    public void markPickedUp(int bookingId) {
        update("UPDATE bookings SET pickup_time = CURRENT_TIMESTAMP WHERE id = ?", bookingId);
    }

    @Override
    public void markDelivered(int bookingId) {
        update("UPDATE bookings SET delivery_time = CURRENT_TIMESTAMP WHERE id = ?", bookingId);
    }

    private void update(String sql, Object... params) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("Could not update booking", e);
        }
    }

    private List<Booking> query(String sql, int param) {
        List<Booking> bookings = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookings.add(map(rs));
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException("Could not load bookings", e);
        }
        return bookings;
    }

    private Booking map(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setId(rs.getInt("id"));
        b.setShipmentId(rs.getInt("shipment_id"));
        b.setCustomerId(rs.getInt("customer_id"));
        b.setPartnerId(rs.getInt("partner_id"));
        b.setVehicleId(rs.getInt("vehicle_id"));
        b.setStatus(DeliveryStatus.valueOf(rs.getString("status")));
        b.setMatchScore(rs.getDouble("match_score"));
        b.setEstimatedCost(rs.getDouble("estimated_cost"));
        b.setCreatedAt(JdbcHelper.getDateTime(rs, "created_at"));
        b.setPickupTime(JdbcHelper.getDateTime(rs, "pickup_time"));
        b.setDeliveryTime(JdbcHelper.getDateTime(rs, "delivery_time"));
        b.setProductName(rs.getString("product_name"));
        b.setWeight(rs.getDouble("weight"));
        b.setPickupAddress(rs.getString("pickup_address"));
        b.setDestinationAddress(rs.getString("destination_address"));
        b.setVehicleNumber(rs.getString("vehicle_number"));
        b.setVehicleType(VehicleType.valueOf(rs.getString("vehicle_type")));
        b.setCustomerName(rs.getString("customer_name"));
        b.setCustomerPhone(rs.getString("customer_phone"));
        b.setPartnerName(rs.getString("partner_name"));
        b.setPartnerPhone(rs.getString("partner_phone"));
        return b;
    }
}
