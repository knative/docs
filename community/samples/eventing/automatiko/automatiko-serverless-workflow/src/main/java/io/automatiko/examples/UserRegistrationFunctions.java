package io.automatiko.examples;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.databind.node.ObjectNode;

import io.automatiko.engine.api.Functions;

public class UserRegistrationFunctions implements Functions {

    private static final Logger LOGGER = LoggerFactory.getLogger("UserRegistration");

    public static void isValid(Object vars) {
        ObjectNode data = (ObjectNode) vars;
        ObjectNode user = (ObjectNode) data.get("user");

        if (!user.has("email") || user.get("email").asText().isEmpty()) {
            data.put("valid", false);
            return;
        }
        if (!user.has("firstName") || user.get("firstName").asText().isEmpty()) {
            data.put("valid", false);
            return;
        }
        if (!user.has("lastName") || user.get("lastName").asText().isEmpty()) {
            data.put("valid", false);
            return;
        }

        data.put("valid", true);
    }

    public static ObjectNode assignUserIdAndPassword(Object vars) {
        ObjectNode data = (ObjectNode) vars;
        ObjectNode user = (ObjectNode) data.get("user");
        String userid = user.get("firstName").asText().substring(0, 1) + user.get("lastName").asText();

        user.put("username", userid.toLowerCase());
        user.put("password", "S3cr3T");

        data.put("username", userid.toLowerCase());

        return data;
    }

    public static void notifyInvalidData(Object vars) {
        ObjectNode user = (ObjectNode) vars;
        LOGGER.error("*****************************");
        LOGGER.error("User {} {}, has not been registered due to invalid data", user.get("firstName").asText(),
                user.get("lastName").asText());
        LOGGER.error("Email with details is sent to {}", user.get("email").asText());
        LOGGER.error("*****************************");
    }

    public static void notifySuccess(Object vars) {
        ObjectNode user = (ObjectNode) vars;
        LOGGER.info("*****************************");
        LOGGER.info("User {} {}, has been successfully registered", user.get("firstName").asText(),
                user.get("lastName").asText());
        LOGGER.info("Email with details is sent to {}", user.get("email").asText());
        LOGGER.info("*****************************");
    }

    public static void notifyServerError(Object vars) {
        ObjectNode user = (ObjectNode) vars;
        LOGGER.error("*****************************");
        LOGGER.error("User {} {}, has not been registered due to server error", user.get("firstName").asText(),
                user.get("lastName").asText());
        LOGGER.error("Email with details is sent to to service administrator");
        LOGGER.error("*****************************");
    }
}
