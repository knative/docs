package org.knative.examples.cloudevents.vertx;

import io.cloudevents.http.vertx.VertxMessageFactory;
import io.cloudevents.CloudEvent;
import io.cloudevents.message.Message;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Vertx;

public class CloudEventReceiverVerticle extends AbstractVerticle {

  public static void main(String[] args) {
    Vertx vertx = Vertx.vertx();
    vertx.deployVerticle(new CloudEventReceiverVerticle());
  }

  public void start() {
    vertx.createHttpServer()
        .requestHandler(req -> {
          // Transform the HttpRequest to Event
          VertxMessageFactory.fromHttpServerRequest(req)
              .map(Message::toEvent)
              .onComplete(asyncResult -> {
                if (asyncResult.succeeded()) {
                  CloudEvent event = asyncResult.result();

                  System.out.println("Received event: " + event);
                  req.response().setStatusCode(202).end();
                } else {
                  System.out.println("Error while decoding the event: " + asyncResult.cause());
                  req.response().setStatusCode(500).end();
                }
              });
        })
        .listen(8080, serverResult -> {
          if (serverResult.succeeded()) {
            System.out.println("Server started on port " + serverResult.result().actualPort());
          } else {
            System.out.println("Error starting the server");
            serverResult.cause().printStackTrace();
          }
        });
  }
}
