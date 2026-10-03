package com.emptymiles.controller;

import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.exception.BookingException;
import com.emptymiles.exception.DataAccessException;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.model.User;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Parent of all servlets: common helpers plus one place that turns our
 * exceptions into the error page, so each servlet stays short.
 */
public abstract class BaseServlet extends HttpServlet {

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            super.service(req, resp);
        } catch (ValidationException | BookingException | AuthenticationException e) {
            showError(req, resp, e.getMessage());
        } catch (DataAccessException e) {
            log("Database error", e);
            showError(req, resp, e.getMessage());
        }
    }

    protected User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute(AppConstants.SESSION_USER);
    }

    protected void forward(HttpServletRequest req, HttpServletResponse resp, String view)
            throws ServletException, IOException {
        req.getRequestDispatcher(view).forward(req, resp);
    }

    /** Redirect inside the app, e.g. redirect(req, resp, "/customer/dashboard"). */
    protected void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }

    /** One-time message shown at the top of the next page (header.jsp displays and removes it). */
    protected void flash(HttpServletRequest req, String message) {
        req.getSession().setAttribute("flash", message);
    }

    /** Like flash(), but shown as an error. */
    protected void flashError(HttpServletRequest req, String message) {
        req.getSession().setAttribute("flashError", message);
    }

    protected void showError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute(AppConstants.ATTR_ERROR, message);
        forward(req, resp, AppConstants.VIEW_ERROR);
    }
}
