package io.automatiko.examples.registration.service;

import javax.enterprise.context.ApplicationScoped;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.automatiko.engine.app.rest.model.User;

@ApplicationScoped
public class NotificationService {

    private static final Logger LOGGER = LoggerFactory.getLogger(NotificationService.class);

    public void sendSuccessNotification(User user) {

        LOGGER.info("*****************************");
        LOGGER.info("User {} {}, has been successfully registered", user.getFirstName(), user.getLastName());
        LOGGER.info("Email with details is sent to {}", user.getEmail());
        LOGGER.info("*****************************");
    }

    public void sendInvalidDataNotification(User user) {

        LOGGER.error("*****************************");
        LOGGER.error("User {} {}, has not been registered due to invalid data", user.getFirstName(), user.getLastName());
        LOGGER.error("Email with details is sent to {}", user.getEmail());
        LOGGER.error("*****************************");
    }

    public void sendServerErrorNotification(User user) {

        LOGGER.error("*****************************");
        LOGGER.error("User {} {}, has not been registered due to server error", user.getFirstName(), user.getLastName());
        LOGGER.error("Email with details is sent to to service administrator");
        LOGGER.error("*****************************");
    }
}
