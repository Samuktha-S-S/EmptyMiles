package com.emptymiles.exception;

/** User input is missing or invalid (shown back on the form). */
public class ValidationException extends RuntimeException {

    public ValidationException(String message) {
        super(message);
    }

    public ValidationException(String message, Throwable cause) {
        super(message, cause);
    }
}
