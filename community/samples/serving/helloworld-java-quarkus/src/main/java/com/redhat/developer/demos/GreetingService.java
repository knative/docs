package com.redhat.developer.demos;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GreetingService {

  private static final String RESPONSE_STRING_FORMAT = "%s Knative World!";

  public String greet(String prefix) {
    return String.format(RESPONSE_STRING_FORMAT, prefix);
  }

}
