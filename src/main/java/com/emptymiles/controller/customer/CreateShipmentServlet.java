package com.emptymiles.controller.customer;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.model.Shipment;
import com.emptymiles.service.ShipmentService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/customer/shipment/new")
public class CreateShipmentServlet extends BaseServlet {

    private final ShipmentService shipmentService = new ShipmentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        forward(req, resp, AppConstants.VIEW_CREATE_SHIPMENT);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Shipment shipment = shipmentService.createShipment(
                    currentUser(req).getId(),
                    req.getParameter("pickupAddress"),
                    req.getParameter("pickupLatitude"),
                    req.getParameter("pickupLongitude"),
                    req.getParameter("destinationAddress"),
                    req.getParameter("destinationLatitude"),
                    req.getParameter("destinationLongitude"),
                    req.getParameter("productName"),
                    req.getParameter("productType"),
                    req.getParameter("quantity"),
                    req.getParameter("weight"));
            redirect(req, resp, "/customer/matches?shipmentId=" + shipment.getId());
        } catch (ValidationException e) {
            req.setAttribute(AppConstants.ATTR_ERROR, e.getMessage());
            forward(req, resp, AppConstants.VIEW_CREATE_SHIPMENT);
        }
    }
}
