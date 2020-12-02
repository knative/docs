package org.knative.examples.cloudevents.spring;

import java.net.URI;
import java.util.Map;
import java.util.function.Consumer;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.cloud.function.cloudevent.CloudEventAttributesProvider;
import org.springframework.cloud.function.cloudevent.CloudEventMessageUtils;
import org.springframework.cloud.function.web.util.HeaderUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.http.RequestEntity;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication(proxyBeanMethods = false)
public class CloudEventSampleApplication {

	public static void main(String[] args) {
		SpringApplication.run(CloudEventSampleApplication.class, args);
	}

	@Bean
	public CloudEventAttributesProvider cloudEventAttributesProvider() {
		return attrs -> attrs.setType("org.knative.examples.cloudevents.spring.Response")
				.setSource("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-spring");
	}

	@Bean
	@ConditionalOnExpression("'${K_SINK:}'==''")
	public Function<Foo, Foo> echo() {
		return message -> message;
	}

	@Bean
	@ConditionalOnExpression("'${K_SINK:}'!=''")
	public Consumer<Message<Map<String, Object>>> sink(CloudEventAttributesProvider provider,
			RestTemplateBuilder builder, @Value("${K_SINK}") String url) {
		RestTemplate client = builder.build();
		return message -> client.exchange(RequestEntity.post(URI.create(url))
				.headers(HeaderUtils
						.fromMessage(new MessageHeaders(CloudEventMessageUtils.generateAttributes(message, provider))))
				.body(message.getPayload()), byte[].class);
	}

}

class Foo {

	private String name;

	public Foo() {
	}

	public Foo(String value) {
		this.name = value;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Override
	public String toString() {
		return "Foo [name=" + this.name + "]";
	}

}
