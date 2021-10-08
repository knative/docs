package io.automatiko.examples.registration;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;
import java.util.UUID;

import javax.inject.Inject;

import org.junit.jupiter.api.Test;

import io.automatiko.examples.registration.MockEventSource.EventData;
import io.quarkus.test.common.QuarkusTestResource;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;

@QuarkusTest
@QuarkusTestResource(WiremockPetstore.class)
public class UserRegistrationTest {

    @Inject
    MockEventSource eventSource;

    // @formatter:off
    @Test
    public void testSuccessPath() {
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body("{\"user\" : {\"email\" : \"mike.strong@email.com\",  \"firstName\" : \"mike\",  \"lastName\" : \"strong\"}}")
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        List<EventData> events = eventSource.events();
        assertEquals(1, events.size());
        
        EventData data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration", data.source);
        assertEquals("io.automatiko.examples.userRegistration.generateusernameandpassword", data.type);

        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.generateusernameandpassword")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.generateusernameandpassword", data.source);
        assertEquals("io.automatiko.examples.userRegistration.getuser", data.type);  
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.getuser")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.getuser", data.source);
        assertEquals("io.automatiko.examples.userRegistration.registeruser", data.type);   
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.registeruser")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.registeruser", data.source);
        assertEquals("io.automatiko.examples.userRegistration.notifyregistered", data.type);   
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.notifyregistered")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.notifyregistered", data.source);
        assertEquals("io.automatiko.examples.userRegistration.userregistered", data.type);     
    }
    
    @Test
    public void testAlreadyRegisteredPath() {
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body("{\"user\" : {\"email\" : \"john.doe@email.com\",  \"firstName\" : \"john\",  \"lastName\" : \"doe\"}}")
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        List<EventData> events = eventSource.events();
        assertEquals(1, events.size());
        
        EventData data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration", data.source);
        assertEquals("io.automatiko.examples.userRegistration.generateusernameandpassword", data.type);

        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.generateusernameandpassword")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.generateusernameandpassword", data.source);
        assertEquals("io.automatiko.examples.userRegistration.getuser", data.type);  
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.getuser")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.getuser", data.source);
        assertEquals("io.automatiko.examples.userRegistration.alreadyregistered", data.type);   
          
    }
    
    @Test
    public void testInvalidDataPath() {
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body("{\"user\" : {\"email\" : \"john.doe@email.com\",  \"firstName\" : \"john\",  \"lastName\" : \"\"}}")
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        List<EventData> events = eventSource.events();
        assertEquals(1, events.size());
        
        EventData data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration", data.source);
        assertEquals("io.automatiko.examples.userRegistration.invaliddata", data.type);        
          
    }
    
    @Test
    public void testRegistrationFailurePath() {
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body("{\"user\" : {\"email\" : \"mary.strong@email.com\",  \"firstName\" : \"mary\",  \"lastName\" : \"strong\"}}")
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        List<EventData> events = eventSource.events();
        assertEquals(1, events.size());
        
        EventData data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration", data.source);
        assertEquals("io.automatiko.examples.userRegistration.generateusernameandpassword", data.type);

        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.generateusernameandpassword")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.generateusernameandpassword", data.source);
        assertEquals("io.automatiko.examples.userRegistration.getuser", data.type);  
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.getuser")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.getuser", data.source);
        assertEquals("io.automatiko.examples.userRegistration.registeruser", data.type);   
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.registeruser")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.registeruser", data.source);
        assertEquals("io.automatiko.examples.userRegistration.notifyservererror", data.type);   
        
        given()
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .header("ce-id", UUID.randomUUID().toString())
            .header("ce-type", "io.automatiko.examples.userRegistration.notifyservererror")
            .header("ce-source", "test")
            .header("ce-specversion", "1.0")
            .body(data.getData())
        .when()
            .post("/")
        .then()
            .statusCode(204);
        
        events = eventSource.events();
        assertEquals(1, events.size());
        
        data = events.get(0);
        assertEquals("io.automatiko.examples.userRegistration.notifyservererror", data.source);
        assertEquals("io.automatiko.examples.userRegistration.registrationfailed", data.type);     
    }
    
    // @formatter:on
}