package com.emptymiles.controller.common;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.model.User;
import com.emptymiles.service.VehicleService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** Read-only account page for both roles. Partners also see their vehicles. */
@WebServlet({"/customer/profile", "/partner/profile"})
public class ProfileServlet extends BaseServlet {

    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        if (user.isPartner()) {
            req.setAttribute("vehicles", vehicleService.getVehiclesForPartner(user.getId()));
        }
        forward(req, resp, AppConstants.VIEW_PROFILE);
    }
}
