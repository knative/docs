package io.automatiko.examples.registration.service;

import javax.enterprise.context.ApplicationScoped;

import io.automatiko.engine.app.rest.model.User;

@ApplicationScoped
public class UserService {

    public boolean isValid(User user) {
        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            return false;
        }
        if (user.getFirstName() == null || user.getFirstName().isEmpty()) {
            return false;
        }
        if (user.getLastName() == null || user.getLastName().isEmpty()) {
            return false;
        }

        return true;
    }

    public User assignUserIdAndPassword(User user) {

        String userid = user.getFirstName().substring(0, 1) + user.getLastName();

        user.username(userid.toLowerCase());
        user.password("S3cr3T");

        return user;
    }
}
