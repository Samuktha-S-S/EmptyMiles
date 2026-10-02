package com.emptymiles.util;

import java.security.SecureRandom;

/** Generates the 4-digit delivery OTP. */
public final class OTPGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    private OTPGenerator() {
    }

    public static String generate() {
        return String.format("%04d", RANDOM.nextInt(10000));
    }
}
