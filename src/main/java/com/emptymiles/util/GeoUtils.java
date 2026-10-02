package com.emptymiles.util;

/** Distance calculations on latitude/longitude without any paid map API. */
public final class GeoUtils {

    private static final double EARTH_RADIUS_KM = 6371.0;

    private GeoUtils() {
    }

    /**
     * Haversine formula: straight-line ("as the crow flies") distance in km
     * between two points on the Earth's surface.
     */
    public static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_KM * c;
    }

    public static boolean isValidLatitude(double lat) {
        return lat >= -90 && lat <= 90;
    }

    public static boolean isValidLongitude(double lon) {
        return lon >= -180 && lon <= 180;
    }

    /** Rounds to 2 decimal places for display. */
    public static double round2(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}
