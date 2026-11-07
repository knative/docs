package com.example.helloworld;

import io.vertx.core.Future;
import io.vertx.core.Vertx;
import io.vertx.core.http.HttpServer;

import java.util.Map;

public final class HelloWorld {
    private HelloWorld() {
    }

    static int port(Map<String, String> environment) {
        int port = Integer.parseInt(environment.getOrDefault("PORT", "8080"));
        if (port < 1 || port > 65535) {
            throw new IllegalArgumentException("PORT must be between 1 and 65535");
        }
        return port;
    }

    static String greeting(Map<String, String> environment) {
        return "Hello World: " + environment.getOrDefault("TARGET", "NOT SPECIFIED");
    }

    static Future<HttpServer> listen(Vertx vertx, int port, String greeting) {
        return vertx.createHttpServer()
                .requestHandler(request -> request.response()
                        .setChunked(true)
                        .putHeader("content-type", "text/plain")
                        .end(greeting))
                .listen(port, "0.0.0.0");
    }

    public static void main(String[] args) {
        Map<String, String> environment = System.getenv();
        int port = port(environment);
        String greeting = greeting(environment);
        Vertx vertx = Vertx.vertx();
        Runtime.getRuntime().addShutdownHook(new Thread(() ->
                vertx.close().toCompletionStage().toCompletableFuture().join()));
        listen(vertx, port, greeting).onFailure(error -> {
            error.printStackTrace(System.err);
            System.exit(1);
        });
    }
}
