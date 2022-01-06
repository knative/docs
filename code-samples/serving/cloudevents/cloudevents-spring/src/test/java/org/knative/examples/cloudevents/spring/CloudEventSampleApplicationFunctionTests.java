package org.knative.examples.cloudevents.spring;

import java.util.function.Function;

import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.cloud.function.context.FunctionCatalog;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class CloudEventSampleApplicationFunctionTests {

	@Autowired
	private FunctionCatalog catalog;

	@Test
	public void functionInvocation() {
		Function<Foo, Foo> function = catalog.lookup("echo");
		assertThat(function.apply(new Foo("Dave")).getName()).isEqualTo("Dave");
	}

}
