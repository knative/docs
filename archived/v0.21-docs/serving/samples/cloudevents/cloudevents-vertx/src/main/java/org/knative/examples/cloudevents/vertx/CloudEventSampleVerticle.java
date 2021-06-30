package org.knative.examples.cloudevents.vertx;

import io.cloudevents.CloudEvent;
import io.cloudevents.core.builder.CloudEventBuilder;
import io.cloudevents.core.message.MessageReader;
import io.cloudevents.http.vertx.VertxMessageFactory;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Handler;
import io.vertx.core.Promise;
import io.vertx.core.Vertx;
import io.vertx.core.buffer.Buffer;
import io.vertx.core.http.HttpServer;
import io.vertx.core.http.HttpServerRequest;
import io.vertx.core.http.HttpServerResponse;
import io.vertx.ext.web.client.HttpResponse;
import io.vertx.ext.web.client.WebClient;

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
      server.requestHandler(generateSinkHandler(WebClient.create(vertx), env.get()));
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
      VertxMessageFactory
          .createReader(request)
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
              VertxMessageFactory
                  .createWriter(response)
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
  public static Handler<HttpServerRequest> generateSinkHandler(WebClient client, URI sink) {
    return serverRequest -> {
      // Transform the HttpRequest to Event
      VertxMessageFactory
          .createReader(serverRequest)
          .map(MessageReader::toEvent)
          .onComplete(asyncResult -> {
            if (asyncResult.failed()) {
              System.out.println("Error while decoding the event: " + asyncResult.cause());

              // Reply with a failure
              serverRequest
                  .response()
                  .setStatusCode(400)
                  .end();
              return;
            }

            CloudEvent event = asyncResult.result();
            System.out.println("Received event: " + event);

            // Let's modify the event changing the source
            CloudEvent outputEvent = CloudEventBuilder
                .v1(event)
                .withSource(URI.create("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-vertx"))
                .build();

            // Send the request to the sink and check the response
            VertxMessageFactory
                .createWriter(client.postAbs(sink.toString()))
                .writeBinary(outputEvent)
                .onComplete(ar -> {
                  if (ar.failed()) {
                    System.out.println("Something bad happened while sending event to the sink: " + ar.cause());
                    serverRequest
                        .response()
                        .setStatusCode(500)
                        .end();
                    return;
                  }

                  HttpResponse<Buffer> response = ar.result();


                  if (response.statusCode() >= 200 && response.statusCode() < 300) {
                    serverRequest
                        .response()
                        .setStatusCode(202)
                        .end();
                  } else if (ar.succeeded()) {
                    System.out.println("Error received from sink: " + response.statusCode() + " " + response.statusMessage());
                    serverRequest
                        .response()
                        .setStatusCode(500)
                        .end();
                  }
                });
          });
    };
  }


}
