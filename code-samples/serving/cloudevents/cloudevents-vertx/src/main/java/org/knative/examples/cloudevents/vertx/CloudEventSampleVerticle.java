package org.knative.examples.cloudevents.vertx;

import io.cloudevents.CloudEvent;
import io.cloudevents.core.builder.CloudEventBuilder;
import io.cloudevents.core.message.MessageReader;
import io.cloudevents.http.vertx.VertxMessageFactory;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Handler;
import io.vertx.core.Promise;
import io.vertx.core.Vertx;
import io.vertx.core.http.HttpServerRequest;
import io.vertx.ext.web.client.WebClient;
import io.vertx.ext.web.client.WebClientOptions;
import java.net.URI;

public class CloudEventSampleVerticle extends AbstractVerticle {

  static final URI OUTPUT_SOURCE =
      URI.create(
          "https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-vertx");
  private final int port;
  private final URI sink;
  private WebClient client;

  public CloudEventSampleVerticle() {
    this(configuredPort(System.getenv("PORT")), configuredSink(System.getenv("K_SINK")));
  }

  // Tests can use an ephemeral listener and a real local HTTP sink.
  CloudEventSampleVerticle(int port, URI sink) {
    this.port = port;
    this.sink = sink;
  }

  public static void main(String[] args) {
    CloudEventSampleVerticle app = new CloudEventSampleVerticle();
    Vertx vertx = Vertx.vertx();
    vertx
        .deployVerticle(app)
        .onFailure(
            cause -> {
              cause.printStackTrace();
              vertx.close().onComplete(ignored -> System.exit(1));
            });
  }

  static int configuredPort(String value) {
    int port = value == null ? 8080 : Integer.parseInt(value);
    if (port < 1 || port > 65535) {
      throw new IllegalArgumentException("PORT must be between 1 and 65535");
    }
    return port;
  }

  static URI configuredSink(String value) {
    if (value == null || value.isBlank()) {
      return null;
    }
    URI sink = URI.create(value);
    if (!("http".equalsIgnoreCase(sink.getScheme()) || "https".equalsIgnoreCase(sink.getScheme()))
        || sink.getHost() == null) {
      throw new IllegalArgumentException("K_SINK must be an absolute HTTP(S) URL");
    }
    return sink;
  }

  @Override
  public void start(Promise<Void> startPromise) {
    Handler<HttpServerRequest> handler;
    if (sink == null) {
      handler = generateEchoHandler();
    } else {
      client = WebClient.create(vertx, new WebClientOptions().setConnectTimeout(2000));
      handler = generateSinkHandler(client, sink);
    }
    vertx
        .createHttpServer()
        .requestHandler(handler)
        .listen(port)
        .onSuccess(server -> System.out.println("Server started on port " + server.actualPort()))
        .<Void>mapEmpty()
        .onComplete(startPromise);
  }

  @Override
  public void stop() {
    if (client != null) {
      client.close();
    }
  }

  private static CloudEvent transform(CloudEvent event) {
    System.out.println("Received event: " + event);
    return CloudEventBuilder.v1(event).withSource(OUTPUT_SOURCE).build();
  }

  /** Replies with the transformed event in binary mode. */
  public static Handler<HttpServerRequest> generateEchoHandler() {
    return request ->
        VertxMessageFactory.createReader(request)
            .map(MessageReader::toEvent)
            .onSuccess(
                event ->
                    VertxMessageFactory.createWriter(request.response().setStatusCode(202))
                        .writeBinary(transform(event)))
            .onFailure(
                cause -> {
                  System.out.println("Error while decoding the event: " + cause);
                  request.response().setStatusCode(400).end();
                });
  }

  /** Forwards the transformed event to a sink; the caller receives no response event. */
  public static Handler<HttpServerRequest> generateSinkHandler(WebClient client, URI sink) {
    return request ->
        VertxMessageFactory.createReader(request)
            .map(MessageReader::toEvent)
            .onComplete(
                decoded -> {
                  if (decoded.failed()) {
                    System.out.println("Error while decoding the event: " + decoded.cause());
                    request.response().setStatusCode(400).end();
                    return;
                  }
                  VertxMessageFactory.createWriter(client.postAbs(sink.toString()).timeout(5000))
                      .writeBinary(transform(decoded.result()))
                      .onComplete(
                          delivery -> {
                            if (delivery.succeeded()
                                && delivery.result().statusCode() >= 200
                                && delivery.result().statusCode() < 300) {
                              request.response().setStatusCode(202).end();
                            } else {
                              System.out.println(
                                  "Sink delivery failed: "
                                      + (delivery.failed()
                                          ? delivery.cause()
                                          : delivery.result().statusCode()));
                              request.response().setStatusCode(500).end();
                            }
                          });
                });
  }
}
