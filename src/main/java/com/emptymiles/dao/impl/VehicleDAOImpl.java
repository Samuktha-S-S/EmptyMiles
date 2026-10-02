package com.emptymiles.dao.impl;

import com.emptymiles.dao.VehicleDAO;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.enums.VehicleStatus;
import com.emptymiles.model.enums.VehicleType;
import com.emptymiles.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAOImpl implements VehicleDAO {

    private static final String SELECT_WITH_PARTNER =
            "SELECT v.*, u.name AS partner_name, u.phone AS partner_phone "
            + "FROM vehicles v JOIN users u ON u.id = v.partner_id ";

    @Override
    public int create(Vehicle v) {
        String sql = "INSERT INTO vehicles (partner_id, vehicle_type, vehicle_number, total_capacity, current_load, "
                + "available_capacity, status, current_latitude, current_longitude, destination, "
                + "destination_latitude, destination_longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, v.getPartnerId());
            ps.setString(2, v.getVehicleType().name());
            ps.setString(3, v.getVehicleNumber());
            ps.setDouble(4, v.getTotalCapacity());
            ps.setDouble(5, v.getCurrentLoad());
            ps.setDouble(6, v.getAvailableCapacity());
            ps.setString(7, v.getStatus().name());
            JdbcHelper.setNullableDouble(ps, 8, v.getCurrentLatitude());
            JdbcHelper.setNullableDouble(ps, 9, v.getCurrentLongitude());
            ps.setString(10, v.getDestination());
            JdbcHelper.setNullableDouble(ps, 11, v.getDestinationLatitude());
            JdbcHelper.setNullableDouble(ps, 12, v.getDestinationLongitude());
            ps.executeUpdate();
            return JdbcHelper.generatedId(ps);
        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                throw new DataAccessException("A vehicle with this number is already registered.", e);
            }
            throw new DataAccessException("Could not save vehicle", e);
        }
    }

    @Override
    public Vehicle findById(int id) {
        List<Vehicle> list = query(SELECT_WITH_PARTNER + "WHERE v.id = ?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public List<Vehicle> findByPartnerId(int partnerId) {
        return query(SELECT_WITH_PARTNER + "WHERE v.partner_id = ? ORDER BY v.id", partnerId);
    }

    @Override
    public List<Vehicle> findAvailableWithLocation() {
        return query(SELECT_WITH_PARTNER + "WHERE v.status = 'AVAILABLE' "
                + "AND v.current_latitude IS NOT NULL AND v.current_longitude IS NOT NULL");
    }

    @Override
    public void updateStatus(int vehicleId, String status) {
        update("UPDATE vehicles SET status = ? WHERE id = ?", status, vehicleId);
    }

    @Override
    public void updateLocation(int vehicleId, double latitude, double longitude) {
        update("UPDATE vehicles SET current_latitude = ?, current_longitude = ? WHERE id = ?",
                latitude, longitude, vehicleId);
    }

    @Override
    public void updateRoute(int vehicleId, String destination, Double latitude, Double longitude) {
        update("UPDATE vehicles SET destination = ?, destination_latitude = ?, destination_longitude = ? WHERE id = ?",
                destination, latitude, longitude, vehicleId);
    }

    @Override
    public void updateLoad(int vehicleId, double currentLoad, double availableCapacity, String status) {
        update("UPDATE vehicles SET current_load = ?, available_capacity = ?, status = ? WHERE id = ?",
                currentLoad, availableCapacity, status, vehicleId);
    }

    private void update(String sql, Object... params) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("Could not update vehicle", e);
        }
    }

    private List<Vehicle> query(String sql, Object... params) {
        List<Vehicle> vehicles = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    vehicles.add(map(rs));
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException("Could not load vehicles", e);
        }
        return vehicles;
    }

    private Vehicle map(ResultSet rs) throws SQLException {
        Vehicle v = new Vehicle();
        v.setId(rs.getInt("id"));
        v.setPartnerId(rs.getInt("partner_id"));
        v.setVehicleType(VehicleType.valueOf(rs.getString("vehicle_type")));
        v.setVehicleNumber(rs.getString("vehicle_number"));
        v.setTotalCapacity(rs.getDouble("total_capacity"));
        v.setCurrentLoad(rs.getDouble("current_load"));
        v.setAvailableCapacity(rs.getDouble("available_capacity"));
        v.setStatus(VehicleStatus.valueOf(rs.getString("status")));
        v.setCurrentLatitude(JdbcHelper.getNullableDouble(rs, "current_latitude"));
        v.setCurrentLongitude(JdbcHelper.getNullableDouble(rs, "current_longitude"));
        v.setDestination(rs.getString("destination"));
        v.setDestinationLatitude(JdbcHelper.getNullableDouble(rs, "destination_latitude"));
        v.setDestinationLongitude(JdbcHelper.getNullableDouble(rs, "destination_longitude"));
        v.setPartnerName(rs.getString("partner_name"));
        v.setPartnerPhone(rs.getString("partner_phone"));
        return v;
    }
}
