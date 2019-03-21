package com.redhat.developer.demos;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/")
public class GreeterResource {

  @Inject
  GreetingService greetingService;

  @ConfigProperty(name = "message.prefix")
  String messagePrefix;

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/")
  public String greet() {
    return greetingService.greet(messagePrefix);
  }

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/healthz")
  public String health() {
    return "OK";
  }
}
