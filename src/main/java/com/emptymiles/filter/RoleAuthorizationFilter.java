package com.emptymiles.filter;

import com.emptymiles.model.User;
import com.emptymiles.model.enums.Role;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Customers may only use customer URLs, partners only partner URLs.
 * Runs after AuthenticationFilter, so the user is always present here.
 */
public class RoleAuthorizationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        User user = (User) req.getSession().getAttribute(AppConstants.SESSION_USER);
        String path = req.getServletPath();

        Role required = null;
        if (path.startsWith("/customer/") || path.equals("/api/tracking")) {
            required = Role.CUSTOMER;
        } else if (path.startsWith("/partner/") || path.equals("/api/location")) {
            required = Role.PARTNER;
        }

        if (required != null && user.getRole() != required) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "This page is not available for your account type.");
            return;
        }
        chain.doFilter(request, response);
    }
}
