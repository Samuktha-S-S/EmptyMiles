package com.emptymiles.service;

import com.emptymiles.dao.UserDAO;
import com.emptymiles.dao.impl.UserDAOImpl;
import com.emptymiles.exception.AuthenticationException;
import com.emptymiles.exception.ValidationException;
import com.emptymiles.model.User;
import com.emptymiles.model.enums.Role;
import com.emptymiles.util.PasswordUtil;
import com.emptymiles.util.ValidationUtil;

/** Registration and login. */
public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this(new UserDAOImpl());
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public User register(String name, String email, String phone, String password, String confirmPassword, String role) {
        String cleanName = ValidationUtil.requireText(name, "Name");
        String cleanEmail = ValidationUtil.requireEmail(email);
        String cleanPhone = ValidationUtil.requirePhone(phone);
        ValidationUtil.requireText(password, "Password");
        if (password.length() < 6) {
            throw new ValidationException("Password must be at least 6 characters.");
        }
        if (!password.equals(confirmPassword)) {
            throw new ValidationException("Passwords do not match.");
        }
        Role userRole;
        try {
            userRole = Role.valueOf(ValidationUtil.requireText(role, "Account type"));
        } catch (IllegalArgumentException e) {
            throw new ValidationException("Choose Customer or Delivery Partner.");
        }
        if (userDAO.findByEmail(cleanEmail) != null) {
            throw new ValidationException("An account with this email already exists.");
        }

        User user = new User(cleanName, cleanEmail, cleanPhone, PasswordUtil.hash(password), userRole);
        user.setId(userDAO.create(user));
        return user;
    }

    public User login(String email, String password) {
        if (email == null || email.isBlank() || password == null || password.isEmpty()) {
            throw new AuthenticationException("Enter your email and password.");
        }
        User user = userDAO.findByEmail(email.trim().toLowerCase());
        if (user == null || !PasswordUtil.verify(password, user.getPassword())) {
            throw new AuthenticationException("Invalid email or password.");
        }
        return user;
    }
}
