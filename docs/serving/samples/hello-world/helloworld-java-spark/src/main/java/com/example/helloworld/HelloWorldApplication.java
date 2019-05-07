package com.example.helloworld;

import static spark.Spark.*;

public class HelloWorldApplication {
	
	static String  message;

	
	public static void main(String args[]) {
		
	/*
     * Please Note: 
     * Default port in SparkJava is 4567
     * If you wish to use port of your choice, 
     * uncomment the following code and set the
     * required port
     */

		//private static final String PORT = "8080";
        //port(Integer.valueOf(System.getenv("PORT")));
			
		if( System.getenv("TARGET") == null) 
			message = "World";
		else
			message = System.getenv("TARGET");
		
		get("/", (req,res) -> "Hello " + message);
	}
	

}
