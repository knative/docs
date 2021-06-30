package org.knative.examples.cloudevents.spring;

import java.net.URI;
import java.util.Arrays;

import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
public class CloudEventSampleApplicationIntegrationTests {

	@Autowired
	private TestRestTemplate rest;

	@LocalServerPort
	private int port;

	@Test
	void postAndCheckHeaders() throws Exception {

		ResponseEntity<String> response = rest.exchange(RequestEntity.post(URI.create("http://localhost:" + port + "/")) //
				.header("ce-id", "12345") //
				.header("ce-specversion", "1.0") //
				.header("ce-type", "io.spring.event") //
				.header("ce-source", "https://spring.io/events") //
				.body("{\"name\":\"Dave\"}"), String.class);

		HttpHeaders headers = response.getHeaders();

		assertThat(headers).containsKey("ce-id");
		assertThat(headers).containsKey("ce-source");
		assertThat(headers).containsKey("ce-type");

		assertThat(headers.get("ce-id")).isNotEqualTo("12345");
		assertThat(headers).containsEntry("ce-type", Arrays.asList("org.knative.examples.cloudevents.spring.Response"));
		assertThat(headers).containsEntry("ce-source",
				Arrays.asList("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-spring"));

	}

}
