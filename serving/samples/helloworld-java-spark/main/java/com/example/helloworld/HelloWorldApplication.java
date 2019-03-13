package com.example.helloworld;

import static spark.Spark.*;

public class HelloWorldApplication {
	
	public static void main(String args[]) {
		port(8080);
		get("/", (req,res) -> "Hello World");
	}
	

}
