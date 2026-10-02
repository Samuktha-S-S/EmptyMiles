package com.emptymiles.dao.impl;

import com.emptymiles.dao.ShipmentDAO;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.enums.DeliveryStatus;
import com.emptymiles.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ShipmentDAOImpl implements ShipmentDAO {

    @Override
    public int create(Shipment s) {
        String sql = "INSERT INTO shipments (customer_id, pickup_address, pickup_latitude, pickup_longitude, "
                + "destination_address, destination_latitude, destination_longitude, product_name, product_type, "
                + "quantity, weight, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, new String[] {"id"})) {
            ps.setInt(1, s.getCustomerId());
            ps.setString(2, s.getPickupAddress());
            ps.setDouble(3, s.getPickupLatitude());
            ps.setDouble(4, s.getPickupLongitude());
            ps.setString(5, s.getDestinationAddress());
            ps.setDouble(6, s.getDestinationLatitude());
            ps.setDouble(7, s.getDestinationLongitude());
            ps.setString(8, s.getProductName());
            ps.setString(9, s.getProductType());
            ps.setInt(10, s.getQuantity());
            ps.setDouble(11, s.getWeight());
            ps.setString(12, s.getStatus().name());
            ps.executeUpdate();
            return JdbcHelper.generatedId(ps);
        } catch (SQLException e) {
            throw new DataAccessException("Could not save shipment", e);
        }
    }

    @Override
    public Shipment findById(int id) {
        List<Shipment> list = query("SELECT * FROM shipments WHERE id = ?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public List<Shipment> findByCustomerId(int customerId) {
        return query("SELECT * FROM shipments WHERE customer_id = ? ORDER BY created_at DESC, id DESC", customerId);
    }

    @Override
    public void updateStatus(int shipmentId, DeliveryStatus status) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("UPDATE shipments SET status = ? WHERE id = ?")) {
            ps.setString(1, status.name());
            ps.setInt(2, shipmentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("Could not update shipment", e);
        }
    }

    private List<Shipment> query(String sql, int param) {
        List<Shipment> shipments = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    shipments.add(map(rs));
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException("Could not load shipments", e);
        }
        return shipments;
    }

    private Shipment map(ResultSet rs) throws SQLException {
        Shipment s = new Shipment();
        s.setId(rs.getInt("id"));
        s.setCustomerId(rs.getInt("customer_id"));
        s.setPickupAddress(rs.getString("pickup_address"));
        s.setPickupLatitude(rs.getDouble("pickup_latitude"));
        s.setPickupLongitude(rs.getDouble("pickup_longitude"));
        s.setDestinationAddress(rs.getString("destination_address"));
        s.setDestinationLatitude(rs.getDouble("destination_latitude"));
        s.setDestinationLongitude(rs.getDouble("destination_longitude"));
        s.setProductName(rs.getString("product_name"));
        s.setProductType(rs.getString("product_type"));
        s.setQuantity(rs.getInt("quantity"));
        s.setWeight(rs.getDouble("weight"));
        s.setStatus(DeliveryStatus.valueOf(rs.getString("status")));
        s.setCreatedAt(JdbcHelper.getDateTime(rs, "created_at"));
        return s;
    }
}
