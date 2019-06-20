package com.example.helloworld;

import static org.junit.jupiter.api.Assertions.assertEquals;

import javax.inject.Inject;

import org.junit.jupiter.api.Test;

import io.micronaut.http.HttpResponse;
import io.micronaut.http.HttpStatus;
import io.micronaut.http.client.RxHttpClient;
import io.micronaut.http.client.annotation.Client;
import io.micronaut.test.annotation.MicronautTest;

@MicronautTest
public class HelloWorldControllerTest {

    @Inject
    @Client("/")
    RxHttpClient client;

    @Test
    public void testIndex() throws Exception {
        HttpResponse<String> response = client.toBlocking().exchange("/", String.class);
        assertEquals(HttpStatus.OK, response.status());
        assertEquals("Hello World: NOT SPECIFIED", response.body());
    }
}
