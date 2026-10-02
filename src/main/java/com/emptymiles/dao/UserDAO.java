package com.emptymiles.dao;

import com.emptymiles.model.User;

/** Database operations on the users table. */
public interface UserDAO {

    /** Inserts the user and returns the new id. */
    int create(User user);

    User findById(int id);

    User findByEmail(String email);
}
