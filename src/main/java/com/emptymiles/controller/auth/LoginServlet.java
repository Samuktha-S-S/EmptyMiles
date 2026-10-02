package com.emptymiles.controller.auth;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.model.User;
import com.emptymiles.service.AuthService;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends BaseServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        if (user != null) {
            redirect(req, resp, user.isPartner() ? "/partner/dashboard" : "/customer/dashboard");
            return;
        }
        forward(req, resp, AppConstants.VIEW_LOGIN);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = authService.login(req.getParameter("email"), req.getParameter("password"));
            // New session id after login (prevents session fixation)
            HttpSession old = req.getSession(false);
            if (old != null) {
                old.invalidate();
            }
            req.getSession(true).setAttribute(AppConstants.SESSION_USER, user);
            redirect(req, resp, user.isPartner() ? "/partner/dashboard" : "/customer/dashboard");
        } catch (AuthenticationException e) {
            req.setAttribute(AppConstants.ATTR_ERROR, e.getMessage());
            forward(req, resp, AppConstants.VIEW_LOGIN);
        }
    }
}
