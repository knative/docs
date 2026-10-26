package org.knative.examples.cloudevents.spring;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.Locale;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/** Validate JSON and bridge case-insensitive HTTP names to SCF message headers. */
@Component
class HttpHeaderFilter extends OncePerRequestFilter {

	private final ObjectMapper mapper;

	private final boolean sinkMode;

	HttpHeaderFilter(ObjectMapper mapper, @Value("${K_SINK:}") String sink) {
		this.mapper = mapper;
		this.sinkMode = !sink.isEmpty();
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
			throws ServletException, IOException {
		if (!"POST".equals(request.getMethod())) {
			response.sendError(405);
			return;
		}
		byte[] body = request.getInputStream().readNBytes(1024 * 1024 + 1);
		if (body.length > 1024 * 1024) {
			response.sendError(413);
			return;
		}
		try {
			JsonNode json = mapper.readTree(body);
			if (json == null || !json.isObject()) {
				throw new IllegalArgumentException("Expected a JSON object");
			}
			MediaType contentType = request.getContentType() == null ? MediaType.APPLICATION_JSON
					: MediaType.parseMediaType(request.getContentType());
			if (contentType.isCompatibleWith(MediaType.valueOf("application/cloudevents+json"))) {
				for (String name : List.of("id", "source", "type", "specversion")) {
					if (!json.hasNonNull(name) || !json.get(name).isString() || json.get(name).asString().isBlank()) {
						throw new IllegalArgumentException("Missing CloudEvent attribute: " + name);
					}
				}
				if (!"1.0".equals(json.get("specversion").asString()) || !json.path("data").isObject()) {
					throw new IllegalArgumentException("Expected a v1 JSON-object CloudEvent");
				}
				URI.create(json.get("source").asString());
			}
			else if (Collections.list(request.getHeaderNames())
				.stream()
				.anyMatch(name -> name.toLowerCase(Locale.ROOT).startsWith("ce-"))) {
				for (String name : List.of("id", "source", "type", "specversion")) {
					String value = request.getHeader("ce-" + name);
					if (value == null || value.isBlank()) {
						throw new IllegalArgumentException("Missing CloudEvent attribute: " + name);
					}
				}
				if (!"1.0".equals(request.getHeader("ce-specversion"))) {
					throw new IllegalArgumentException("Expected CloudEvents 1.0");
				}
				URI.create(request.getHeader("ce-source"));
			}
		}
		catch (RuntimeException ex) {
			response.sendError(400, "Expected valid JSON or a CloudEvents 1.0 JSON object");
			return;
		}
		HttpServletRequest normalized = new HttpServletRequestWrapper(request) {
			@Override
			public Enumeration<String> getHeaderNames() {
				return Collections.enumeration(Collections.list(super.getHeaderNames())
					.stream()
					.map(name -> name.toLowerCase(Locale.ROOT))
					.toList());
			}

			@Override
			public ServletInputStream getInputStream() {
				ByteArrayInputStream input = new ByteArrayInputStream(body);
				return new ServletInputStream() {
					@Override
					public int read() {
						return input.read();
					}

					@Override
					public boolean isFinished() {
						return input.available() == 0;
					}

					@Override
					public boolean isReady() {
						return true;
					}

					@Override
					public void setReadListener(ReadListener listener) {
						throw new UnsupportedOperationException("Synchronous request body");
					}
				};
			}

			@Override
			public BufferedReader getReader() {
				return new BufferedReader(new InputStreamReader(getInputStream(), StandardCharsets.UTF_8));
			}
		};
		HttpServletResponse output = new HttpServletResponseWrapper(response) {
			@Override
			public void setHeader(String name, String value) {
				if (!sinkMode || !name.toLowerCase(Locale.ROOT).startsWith("ce-")) {
					super.setHeader(name, value);
				}
			}

			@Override
			public void addHeader(String name, String value) {
				if (!sinkMode || !name.toLowerCase(Locale.ROOT).startsWith("ce-")) {
					super.addHeader(name, value);
				}
			}
		};
		chain.doFilter(normalized, output);
	}

}
