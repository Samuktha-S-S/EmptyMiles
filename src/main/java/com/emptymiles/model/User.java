package com.emptymiles.model;

import com.emptymiles.model.enums.Role;

import java.time.LocalDateTime;

/** A customer or a delivery partner (table: users). */
public class User {

    private int id;
    private String name;
    private String email;
    private String phone;
    private String password;   // stored as a salted hash
    private Role role;
    private LocalDateTime createdAt;

    public User() {
    }

    public User(String name, String email, String phone, String password, Role role) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.password = password;
        this.role = role;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isCustomer() { return role == Role.CUSTOMER; }
    public boolean isPartner() { return role == Role.PARTNER; }
}
