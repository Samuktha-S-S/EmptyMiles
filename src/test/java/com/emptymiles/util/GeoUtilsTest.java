package com.emptymiles.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class GeoUtilsTest {

    @Test
    void samePointIsZeroKm() {
        assertEquals(0.0, GeoUtils.haversineKm(13.0827, 80.2707, 13.0827, 80.2707), 1e-9);
    }

    @Test
    void chennaiToBengaluruIsAbout290Km() {
        double km = GeoUtils.haversineKm(13.0827, 80.2707, 12.9716, 77.5946);
        assertEquals(290, km, 5);
    }

    @Test
    void oneDegreeOfLatitudeIsAbout111Km() {
        assertEquals(111.2, GeoUtils.haversineKm(0, 0, 1, 0), 0.1);
    }
}
