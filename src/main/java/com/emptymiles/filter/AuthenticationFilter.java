package com.emptymiles.filter;

import com.emptymiles.util.AppConstants;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Blocks /customer/*, /partner/* and /api/* for visitors who are not logged in. */
public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        boolean loggedIn = session != null && session.getAttribute(AppConstants.SESSION_USER) != null;

        if (loggedIn) {
            // Logged-in pages must not be shown again from the browser cache after logout
            resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            chain.doFilter(request, response);
        } else if (req.getServletPath().startsWith("/api/")) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}
