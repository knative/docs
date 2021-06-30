package org.knative.examples.cloudevents.spring;

import java.net.URI;
import java.util.Map;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.util.SocketUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = WebEnvironment.DEFINED_PORT)
public class KSinkCloudEventSampleApplicationIntegrationTests {

	@Autowired
	private TestRestTemplate rest;

	@Autowired
	private TestController controller;

	@Value("${server.port}")
	private int port;

	@BeforeAll
	static void setUp() {
		System.setProperty("server.port", SocketUtils.findAvailableTcpPort() + "");
		System.setProperty("K_SINK", "http://localhost:${server.port}/sink");
	}

	@AfterAll
	static void tearDown() {
		System.clearProperty("server.port");
		System.clearProperty("K_SINK");
	}

	@Test
	void postAndCheckHeaders() throws Exception {

		ResponseEntity<String> response = rest.exchange(RequestEntity.post(URI.create("http://localhost:" + port + "/")) //
				.header("ce-id", "12345") //
				.header("ce-specversion", "1.0") //
				.header("ce-type", "io.spring.event") //
				.header("ce-source", "https://spring.io/events") //
				.contentType(MediaType.APPLICATION_JSON) //
				.body("{\"name\":\"Dave\"}"), String.class);

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.ACCEPTED);
		assertThat(response.getBody()).isNull();
		HttpHeaders headers = response.getHeaders();

		assertThat(headers).doesNotContainKey("ce-id");
		assertThat(headers).doesNotContainKey("ce-source");

		Map<String, String> sink = controller.getHeaders();
		assertThat(sink).containsKey("ce-id");
		assertThat(sink.get("ce-id")).isNotEqualTo("12345");
		assertThat(sink).containsEntry("ce-type", "org.knative.examples.cloudevents.spring.Response");
		assertThat(sink).containsEntry("ce-source",
				"https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-spring");

	}

	@TestConfiguration
	@RestController
	static class TestController {

		private Map<String, Object> body;

		private Map<String, String> headers;

		@PostMapping("/sink")
		public String ok(@RequestBody Map<String, Object> body, @RequestHeader Map<String, String> headers) {
			this.body = body;
			this.headers = headers;
			return "OK";
		}

		public Map<String, String> getHeaders() {
			return headers;
		}

		public Map<String, Object> getBody() {
			return body;
		}

	}

}
