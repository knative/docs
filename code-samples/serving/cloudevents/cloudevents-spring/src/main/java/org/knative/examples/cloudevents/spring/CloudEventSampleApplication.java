package org.knative.examples.cloudevents.spring;

import java.net.URI;
import java.time.Duration;
import java.util.Map;
import java.util.function.Consumer;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.cloud.function.cloudevent.CloudEventMessageBuilder;
import org.springframework.cloud.function.cloudevent.CloudEventsFunctionExtensionConfiguration;
import org.springframework.cloud.function.cloudevent.CloudEventMessageUtils;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.web.client.RestClient;

@SpringBootApplication(proxyBeanMethods = false)
@Import(CloudEventsFunctionExtensionConfiguration.class)
public class CloudEventSampleApplication {

	public static void main(String[] args) {
		SpringApplication.run(CloudEventSampleApplication.class, args);
	}

	private static <T> Message<T> response(T data) {
		return CloudEventMessageBuilder.withData(data)
			.setType("org.knative.examples.cloudevents.spring.Response")
			.setSource("https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-spring")
			.setHeader(MessageHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
			.build();
	}

	@Bean
	@ConditionalOnExpression("'${K_SINK:}'==''")
	public Function<Map<String, Object>, Message<Map<String, Object>>> echo() {
		return CloudEventSampleApplication::response;
	}

	@Bean
	@ConditionalOnExpression("'${K_SINK:}'!=''")
	public Consumer<Message<Map<String, Object>>> sink(@Value("${K_SINK}") String url) {
		SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
		factory.setConnectTimeout(Duration.ofSeconds(5));
		factory.setReadTimeout(Duration.ofSeconds(10));
		RestClient client = RestClient.builder().requestFactory(factory).build();
		return message -> {
			Message<Map<String, Object>> event = response(message.getPayload());
			client.post()
				.uri(URI.create(url))
				.contentType(MediaType.APPLICATION_JSON)
				.headers(headers -> CloudEventMessageUtils.getAttributes(event)
					.forEach((name, value) -> headers.set(name, value.toString())))
				.body(event.getPayload())
				.retrieve()
				.toBodilessEntity();
		};
	}

}
