package example

import akka.actor.ActorSystem
import akka.event.LoggingAdapter
import akka.http.scaladsl.Http
import akka.http.scaladsl.model._
import ContentTypes._
import akka.http.scaladsl.server.Directives._
import akka.stream.{ActorMaterializer, Materializer}
import scala.concurrent.ExecutionContext
import scala.util.{Failure, Success}


object HelloWorldScala {
  def main(args: Array[String]): Unit = {
    // Creates and initializes an Akka Actor System
    implicit val system: ActorSystem = ActorSystem("HelloWorldScala")
    // Specifies where any Futures in this code will execute
    implicit val ec: ExecutionContext = system.dispatcher
    // Obtains a logger to be used for the sample
    val log: LoggingAdapter = system.log
    // Obtains a reference to the configuration for this application
    val config = system.settings.config

    // These are read from the application.conf file under `resources`
    val target = config.getString("helloworld.target")
    val host = config.getString("helloworld.host")
    val port = config.getInt("helloworld.port")

    // Here we define the endpoints exposed by this application
    val serviceRoute =
      path("") {
        get {
          log.info("Received request to HelloWorldScala")
          complete(HttpEntity(`text/html(UTF-8)`, s"Hello $target!"))
        }
      }

    // Here we create the Http server, and bind it to the host and the port,
    // so we can serve requests using the route(s) we defined previously.
    val binding = Http().newServerAt(host, port).bind(serviceRoute) andThen {
      case Success(sb) =>
        log.info("Bound: {}", sb)
      case Failure(t) =>
        log.error(t, "Failed to bind to {}:{}—shutting down", host, port)
        system.terminate()
    }
  }
}
