package io.automatiko.examples;

import static com.github.tomakehurst.wiremock.client.WireMock.aResponse;
import static com.github.tomakehurst.wiremock.client.WireMock.get;
import static com.github.tomakehurst.wiremock.client.WireMock.matchingJsonPath;
import static com.github.tomakehurst.wiremock.client.WireMock.post;
import static com.github.tomakehurst.wiremock.client.WireMock.stubFor;
import static com.github.tomakehurst.wiremock.client.WireMock.urlEqualTo;
import static com.github.tomakehurst.wiremock.client.WireMock.urlMatching;

import java.util.Collections;
import java.util.Map;

import com.github.tomakehurst.wiremock.WireMockServer;

import io.quarkus.test.common.QuarkusTestResourceLifecycleManager;

public class WiremockPetstore implements QuarkusTestResourceLifecycleManager {

    private WireMockServer wireMockServer;

    @Override
    public Map<String, String> start() {
        wireMockServer = new WireMockServer();
        wireMockServer.start();

        stubFor(get(urlEqualTo("/v2/user/jdoe"))
                .willReturn(aResponse()
                        .withHeader("Content-Type", "application/json")
                        .withBody("{\n" +
                                "  \"id\": 0,\n" +
                                "  \"username\": \"john\",\n" +
                                "  \"firstName\": \"John\",\n" +
                                "  \"lastName\": \"Doe\",\n" +
                                "  \"email\": \"john@email.com\",\n" +
                                "  \"password\": \"secret\",\n" +
                                "  \"phone\": \"123456\",\n" +
                                "  \"userStatus\": 0\n" +
                                "}")));

        stubFor(get(urlEqualTo("/v2/user/mary"))
                .willReturn(aResponse()
                        .withHeader("Content-Type", "application/json")
                        .withStatus(500)));

        stubFor(get(urlEqualTo("/v2/user/mike"))
                .willReturn(aResponse()
                        .withHeader("Content-Type", "application/json")
                        .withStatus(404)));

        stubFor(post(urlEqualTo("/v2/user"))
                .willReturn(aResponse()
                        .withHeader("Content-Type", "application/json")
                        .withStatus(200)));

        stubFor(post(urlEqualTo("/v2/user")).withRequestBody(matchingJsonPath("$[?(@.firstName == 'mary')]"))
                .willReturn(aResponse()
                        .withHeader("Content-Type", "application/json")
                        .withStatus(500)));

        stubFor(get(urlMatching(".*")).atPriority(10).willReturn(aResponse().proxiedFrom("https://petstore.swagger.io/v2")));

        return Collections.singletonMap("swaggerpetstore/mp-rest/url", wireMockServer.baseUrl() + "/v2");
    }

    @Override
    public void stop() {
        if (null != wireMockServer) {
            wireMockServer.stop();
        }
    }
}
