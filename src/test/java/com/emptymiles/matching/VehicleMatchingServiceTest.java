package com.emptymiles.matching;

import com.emptymiles.dto.MatchResult;
import com.emptymiles.model.Shipment;
import com.emptymiles.model.Vehicle;
import com.emptymiles.model.enums.VehicleStatus;
import com.emptymiles.model.enums.VehicleType;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Tests the ranking logic only (no database is needed). */
class VehicleMatchingServiceTest {

    private final VehicleMatchingService service = new VehicleMatchingService(null);

    // T. Nagar -> Adyar, Chennai
    private Shipment clothes(double weightKg) {
        Shipment s = new Shipment();
        s.setProductName("Clothes");
        s.setWeight(weightKg);
        s.setPickupLatitude(13.0418);
        s.setPickupLongitude(80.2341);
        s.setDestinationLatitude(13.0012);
        s.setDestinationLongitude(80.2565);
        return s;
    }

    private Vehicle bike(int id, double total, double load, double lat, double lon) {
        Vehicle v = new Vehicle();
        v.setId(id);
        v.setVehicleType(VehicleType.BIKE);
        v.setTotalCapacity(total);
        v.setCurrentLoad(load);
        v.setAvailableCapacity(total - load);
        v.setStatus(VehicleStatus.AVAILABLE);
        v.setCurrentLatitude(lat);
        v.setCurrentLongitude(lon);
        return v;
    }

    @Test
    void exampleFromSpecFiveKgFitsInSevenKgFree() {
        // Bike 10 kg total, 3 kg loaded -> 7 kg free -> 5 kg is eligible
        Vehicle v = bike(1, 10, 3, 13.0400, 80.2300);
        assertNotNull(service.evaluate(clothes(5), v));
    }

    @Test
    void tooHeavyIsRejected() {
        Vehicle v = bike(1, 10, 3, 13.0400, 80.2300);
        assertNull(service.evaluate(clothes(8), v));
    }

    @Test
    void offlineVehicleIsRejected() {
        Vehicle v = bike(1, 10, 0, 13.0400, 80.2300);
        v.setStatus(VehicleStatus.OFFLINE);
        assertNull(service.evaluate(clothes(5), v));
    }

    @Test
    void vehicleTooFarFromPickupIsRejected() {
        // Bike in Bengaluru (about 290 km away)
        Vehicle v = bike(1, 10, 0, 12.9716, 77.5946);
        assertNull(service.evaluate(clothes(5), v));
    }

    @Test
    void closerVehicleRanksFirst() {
        Vehicle near = bike(1, 10, 0, 13.0420, 80.2345);
        Vehicle far = bike(2, 10, 0, 13.0850, 80.2101);
        List<MatchResult> ranked = service.rankVehicles(clothes(5), List.of(far, near));
        assertEquals(2, ranked.size());
        assertEquals(1, ranked.get(0).getVehicle().getId());
    }

    @Test
    void vehicleHeadingTheSameWayBeatsVehicleGoingElsewhere() {
        // Both start at the pickup; one is going to Adyar (same as parcel), one to Anna Nagar (opposite)
        Vehicle sameWay = bike(1, 10, 0, 13.0418, 80.2341);
        sameWay.setDestinationLatitude(13.0012);
        sameWay.setDestinationLongitude(80.2565);
        Vehicle otherWay = bike(2, 10, 0, 13.0418, 80.2341);
        otherWay.setDestinationLatitude(13.0850);
        otherWay.setDestinationLongitude(80.2101);

        List<MatchResult> ranked = service.rankVehicles(clothes(5), List.of(otherWay, sameWay));
        assertEquals(1, ranked.get(0).getVehicle().getId());
        assertTrue(ranked.get(0).getDetourKm() < 0.01);
        // Anna Nagar is the opposite direction: detour is too big, so it is dropped
        assertEquals(1, ranked.size());
    }

    @Test
    void scoreIsBetweenZeroAndHundred() {
        MatchResult r = service.evaluate(clothes(5), bike(1, 10, 0, 13.0418, 80.2341));
        assertTrue(r.getMatchScore() >= 0 && r.getMatchScore() <= 100);
    }
}
