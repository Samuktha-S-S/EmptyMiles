package com.emptymiles.controller.auth;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.service.AuthService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends BaseServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        forward(req, resp, AppConstants.VIEW_REGISTER);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            authService.register(
                    req.getParameter("name"),
                    req.getParameter("email"),
                    req.getParameter("phone"),
                    req.getParameter("password"),
                    req.getParameter("confirmPassword"),
                    req.getParameter("role"));
            flash(req, "Account created. Please log in.");
            redirect(req, resp, "/login");
        } catch (ValidationException e) {
            req.setAttribute(AppConstants.ATTR_ERROR, e.getMessage());
            forward(req, resp, AppConstants.VIEW_REGISTER);
        }
    }
}
