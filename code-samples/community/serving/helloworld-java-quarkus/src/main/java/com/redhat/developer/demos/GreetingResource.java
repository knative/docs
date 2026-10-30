package com.redhat.developer.demos;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.Optional;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/")
public class GreetingResource {
  @ConfigProperty(name = "target")
  Optional<String> target;

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String hello() {
    return "Hello " + target.orElse("World") + "!";
  }
}
