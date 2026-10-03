package com.emptymiles.util;

import com.emptymiles.exception.ValidationException;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

/** Input checks shared by the services. Each method throws ValidationException with a readable message. */
public final class ValidationUtil {

    private static final Pattern EMAIL = Pattern.compile("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$");
    private static final Pattern PHONE = Pattern.compile("^[0-9]{10}$");
    private static final Pattern VEHICLE_NUMBER = Pattern.compile("^[A-Z0-9 -]{4,20}$");

    private ValidationUtil() {
    }

    public static String requireText(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new ValidationException(field + " is required.");
        }
        return value.trim();
    }

    public static String requireEmail(String value) {
        String email = requireText(value, "Email").toLowerCase();
        if (!EMAIL.matcher(email).matches()) {
            throw new ValidationException("Enter a valid email address.");
        }
        return email;
    }

    public static String requirePhone(String value) {
        String phone = requireText(value, "Phone");
        if (!PHONE.matcher(phone).matches()) {
            throw new ValidationException("Phone must be 10 digits.");
        }
        return phone;
    }

    public static String requireVehicleNumber(String value) {
        String number = requireText(value, "Vehicle number").toUpperCase();
        if (!VEHICLE_NUMBER.matcher(number).matches()) {
            throw new ValidationException("Vehicle number should look like TN01AB1234.");
        }
        return number;
    }

    public static double requirePositive(String value, String field) {
        double number = parseDouble(value, field);
        if (number <= 0) {
            throw new ValidationException(field + " must be greater than 0.");
        }
        return number;
    }

    public static int requirePositiveInt(String value, String field) {
        try {
            int number = Integer.parseInt(requireText(value, field));
            if (number <= 0) {
                throw new ValidationException(field + " must be greater than 0.");
            }
            return number;
        } catch (NumberFormatException e) {
            throw new ValidationException(field + " must be a whole number.");
        }
    }

    public static double requireLatitude(String value, String field) {
        double lat = parseDouble(value, field);
        if (!GeoUtils.isValidLatitude(lat)) {
            throw new ValidationException(field + " must be between -90 and 90.");
        }
        return lat;
    }

    public static double requireLongitude(String value, String field) {
        double lon = parseDouble(value, field);
        if (!GeoUtils.isValidLongitude(lon)) {
            throw new ValidationException(field + " must be between -180 and 180.");
        }
        return lon;
    }

    /** Returns null for an empty optional field. */
    public static Double optionalDouble(String value, String field) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return parseDouble(value, field);
    }

    /** Trimmed text, or null for an empty optional field. */
    public static String optionalText(String value, String field, int maxLength) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String text = value.trim();
        if (text.length() > maxLength) {
            throw new ValidationException(field + " must be at most " + maxLength + " characters.");
        }
        return text;
    }

    /** A number greater than 0, or null for an empty optional field. */
    public static Double optionalPositive(String value, String field) {
        Double number = optionalDouble(value, field);
        if (number != null && number <= 0) {
            throw new ValidationException(field + " must be greater than 0.");
        }
        return number;
    }

    /** A yyyy-MM-dd date that is today or later, or null for an empty optional field. */
    public static LocalDate optionalFutureDate(String value, String field) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            LocalDate date = LocalDate.parse(value.trim());
            if (date.isBefore(LocalDate.now())) {
                throw new ValidationException(field + " cannot be in the past.");
            }
            return date;
        } catch (DateTimeParseException e) {
            throw new ValidationException(field + " is not a valid date.");
        }
    }

    public static int parseId(String value, String field) {
        try {
            return Integer.parseInt(requireText(value, field));
        } catch (NumberFormatException e) {
            throw new ValidationException(field + " is invalid.");
        }
    }

    private static double parseDouble(String value, String field) {
        try {
            return Double.parseDouble(requireText(value, field));
        } catch (NumberFormatException e) {
            throw new ValidationException(field + " must be a number.");
        }
    }
}
