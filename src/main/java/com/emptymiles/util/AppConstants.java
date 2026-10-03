package com.emptymiles.util;

/** Names and numbers used in several places. */
public final class AppConstants {

    private AppConstants() {
    }

    // Session / request attribute names
    public static final String SESSION_USER = "user";
    public static final String ATTR_ERROR = "error";
    public static final String ATTR_MESSAGE = "message";

    // JSP locations (all under WEB-INF so they can only be reached through servlets)
    public static final String VIEWS = "/WEB-INF/views/";
    public static final String VIEW_LOGIN = VIEWS + "auth/login.jsp";
    public static final String VIEW_REGISTER = VIEWS + "auth/register.jsp";
    public static final String VIEW_CUSTOMER_DASHBOARD = VIEWS + "customer/customer-dashboard.jsp";
    public static final String VIEW_CREATE_SHIPMENT = VIEWS + "customer/create-shipment.jsp";
    public static final String VIEW_MATCHED_VEHICLES = VIEWS + "customer/matched-vehicles.jsp";
    public static final String VIEW_BOOKING_DETAILS = VIEWS + "customer/booking-details.jsp";
    public static final String VIEW_TRACKING = VIEWS + "customer/tracking.jsp";
    public static final String VIEW_PARTNER_DASHBOARD = VIEWS + "partner/partner-dashboard.jsp";
    public static final String VIEW_VEHICLE_MANAGEMENT = VIEWS + "partner/vehicle-management.jsp";
    public static final String VIEW_BOOKING_REQUESTS = VIEWS + "partner/booking-requests.jsp";
    public static final String VIEW_ACTIVE_DELIVERY = VIEWS + "partner/active-delivery.jsp";
    public static final String VIEW_CUSTOMER_SHIPMENTS = VIEWS + "customer/shipments.jsp";
    public static final String VIEW_MATCHING_SHIPMENTS = VIEWS + "partner/matching-shipments.jsp";
    public static final String VIEW_LOCATION = VIEWS + "partner/location.jsp";
    public static final String VIEW_PROFILE = VIEWS + "common/profile.jsp";
    public static final String VIEW_HELP = VIEWS + "common/help.jsp";
    public static final String VIEW_ERROR = VIEWS + "common/error.jsp";
    public static final String VIEW_SUCCESS = VIEWS + "common/success.jsp";

    // Match score weights (total 100)
    public static final double WEIGHT_DISTANCE = 40;
    public static final double WEIGHT_ROUTE = 35;
    public static final double WEIGHT_CAPACITY = 25;

    // Route compatibility: extra km a vehicle may drive off its own route
    public static final double MIN_ALLOWED_DETOUR_KM = 3;
    public static final double MAX_DETOUR_RATIO = 0.5;   // up to 50% of its own trip length
    public static final double NO_ROUTE_SCORE = 0.5;     // vehicle has no fixed destination

    // Browser sends the partner's position every N seconds during a delivery
    public static final int LOCATION_UPDATE_SECONDS = 15;
}
