package com.emptymiles.util;

import com.emptymiles.exception.DataAccessException;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** Opens JDBC connections using the settings in src/main/resources/db.properties. */
public final class DBConnection {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("db.properties not found on the classpath");
            }
            PROPS.load(in);
            Class.forName(PROPS.getProperty("db.driver"));
        } catch (IOException | ClassNotFoundException e) {
            throw new IllegalStateException("Could not load database settings", e);
        }
    }

    private DBConnection() {
    }

    /** Caller must close the connection (use try-with-resources). */
    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(
                    PROPS.getProperty("db.url"),
                    PROPS.getProperty("db.username"),
                    PROPS.getProperty("db.password"));
        } catch (SQLException e) {
            throw new DataAccessException("Cannot connect to MySQL. Check db.properties and that MySQL is running.", e);
        }
    }
}
