package com.example.helloworld;

import static spark.Spark.*;

public class HelloWorldApplication {
	
	static String  message;

	
	public static void main(String args[]) {
		//Default port in SparkJava is 4567
		// Setting the PORT to 8080 here
		if(System.getenv("PORT") != null)
			port(Integer.valueOf(System.getenv("PORT")));
			
		if( System.getenv("TARGET") == null) 
			message = "World";
		else
			message = System.getenv("TARGET");
		
		get("/", (req,res) -> "Hello " + message);
	}
	

}
