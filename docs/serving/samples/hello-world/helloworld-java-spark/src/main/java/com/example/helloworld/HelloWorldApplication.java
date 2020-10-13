package com.example.helloworld;

import static spark.Spark.*;

public class HelloWorldApplication {

    static String  message;


    public static void main(String args[]) {

        /*
        * Please Note:
        * Default port in SparkJava is 4567
        * We are using the environment variable PORT or default to 8080
        */

        port(Integer.valueOf(System.getenv().getOrDefault("PORT", "8080")));

        if( System.getenv("TARGET") == null)
            message = "World";
        else
            message = System.getenv("TARGET");

        get("/", (req,res) -> "Hello " + message);
    }


}
