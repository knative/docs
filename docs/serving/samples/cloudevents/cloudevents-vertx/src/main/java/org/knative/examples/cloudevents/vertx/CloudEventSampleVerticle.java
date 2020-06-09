package org.knative.examples.cloudevents.vertx;

import io.cloudevents.core.builder.CloudEventBuilder;
import io.cloudevents.CloudEvent;
import io.cloudevents.core.message.MessageReader;
import io.cloudevents.http.vertx.VertxHttpClientRequestMessageWriter;
import io.cloudevents.http.vertx.VertxHttpServerResponseMessageWriter;
import io.cloudevents.http.vertx.VertxMessageReaderFactory;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Handler;
import io.vertx.core.Promise;
import io.vertx.core.Vertx;
import io.vertx.core.http.*;

import java.net.URI;
import java.util.Optional;

public class CloudEventSampleVerticle extends AbstractVerticle {

  public static void main(String[] args) {
    Vertx vertx = Vertx.vertx();
    vertx.deployVerticle(new CloudEventSampleVerticle());
  }

  public void start(Promise<Void> startPromise) {
    HttpServer server = vertx.createHttpServer();

    // Get the port
    int port = Optional.ofNullable(System.getenv("PORT")).map(Integer::parseInt).orElse(8080);

    // Get the sink uri, if any
    Optional<URI> env = Optional.ofNullable(System.getenv("K_SINK")).map(URI::create);
    if (env.isPresent()) {
      server.requestHandler(generateSinkHandler(vertx.createHttpClient(), env.get()));
    } else {
      // If K_SINK is not set, just echo back the events
      server.requestHandler(generateEchoHandler());
    }

    server
        // Listen and complete verticle deploy
        .listen(port, serverResult -> {
          if (serverResult.succeeded()) {
            System.out.println("Server started on port " + serverResult.result().actualPort());
            startPromise.complete();
          } else {
            System.out.println("Error starting the server");
            serverResult.cause().printStackTrace();
            startPromise.fail(serverResult.cause());
          }
        });
  }

  /**
   * Generates an handler that does the echo of the received event
   */
  public static Handler<HttpServerRequest> generateEchoHandler() {
    return request -> {
      // Transform the HttpRequest to Event
      VertxMessageReaderFactory
          .fromHttpServerRequest(request)
          .map(MessageReader::toEvent)
          .onComplete(asyncResult -> {
            if (asyncResult.succeeded()) {
              CloudEvent event = asyncResult.result();
              System.out.println("Received event: " + event);

              // Let's modify the event changing the source
              CloudEvent outputEvent = CloudEventBuilder
                  .v1(event)
                  .withSource(URI.create("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-vertx"))
                  .build();

              // Set response status code
              HttpServerResponse response = request
                  .response()
                  .setStatusCode(202);

              // Reply with the event in binary mode
              VertxHttpServerResponseMessageWriter
                  .create(response)
                  .writeBinary(outputEvent);
            } else {
              System.out.println("Error while decoding the event: " + asyncResult.cause());

              // Reply with a failure
              request
                  .response()
                  .setStatusCode(400)
                  .end();
            }
          });
    };
  }

  /**
   * Generates an handler that sink the does the echo of the received event
   */
  public static Handler<HttpServerRequest> generateSinkHandler(HttpClient client, URI sink) {
    return serverRequest -> {
      // Transform the HttpRequest to Event
      VertxMessageReaderFactory
          .fromHttpServerRequest(serverRequest)
          .map(MessageReader::toEvent)
          .onComplete(asyncResult -> {
            if (asyncResult.succeeded()) {
              CloudEvent event = asyncResult.result();
              System.out.println("Received event: " + event);

              // Let's modify the event changing the source
              CloudEvent outputEvent = CloudEventBuilder
                  .v1(event)
                  .withSource(URI.create("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-vertx"))
                  .build();

              // Prepare the http request to the sink
              HttpClientRequest sinkRequest = client.postAbs(sink.toString());

              // Define how to handle the response from the sink
              sinkRequest.handler(sinkResponse -> {
                if (sinkResponse.statusCode() >= 200 && sinkResponse.statusCode() < 300) {
                  serverRequest
                      .response()
                      .setStatusCode(202)
                      .end();
                } else {
                  System.out.println("Error received from sink: " + sinkResponse.statusCode() + " " + sinkResponse.statusMessage());
                  serverRequest
                      .response()
                      .setStatusCode(500)
                      .end();
                }
              });

              // Send the event to K_SINK
              VertxHttpClientRequestMessageWriter
                  .create(sinkRequest)
                  .writeBinary(event);
            } else {
              System.out.println("Error while decoding the event: " + asyncResult.cause());

              // Reply with a failure
              serverRequest
                  .response()
                  .setStatusCode(400)
                  .end();
            }
          });
    };
  }


}
