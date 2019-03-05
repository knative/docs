package com.example.helloworld;

import static spark.Spark.*;

<<<<<<< HEAD:docs/serving/samples/hello-world/helloworld-java/src/main/java/com/example/helloworld/HelloworldApplication.java
@SpringBootApplication
public class HelloworldApplication {

	@Value("${TARGET:World}")
	String target;

	@RestController
	class HelloworldController {
		@GetMapping("/")
		String hello() {
			return "Hello " + target + "!";
		}
=======
public class HelloWorldApplication {
	
	public static void main(String args[]) {
		port(8080);
		get("/hello", (req,res) -> "Hello World");
>>>>>>> Added Hello World Java using Spark Java Framework:serving/samples/helloworld-java/src/main/java/com/example/helloworld/HelloworldApplication.java
	}
	

}
