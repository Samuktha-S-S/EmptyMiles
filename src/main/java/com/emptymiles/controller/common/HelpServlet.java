package com.emptymiles.controller.common;

import com.emptymiles.controller.BaseServlet;
import com.emptymiles.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** How EmptyMiles works: matching, delivery steps and OTP. Open to everyone. */
@WebServlet("/help")
public class HelpServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        forward(req, resp, AppConstants.VIEW_HELP);
    }
}
