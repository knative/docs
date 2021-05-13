organization := "Scala & Akka Examples for Knative Serving"

name := "helloworld-scala"

version := "0.0.1"

scalaVersion := "2.13.3"

mainClass in Compile := Some("example.HelloWorldScala")

scalacOptions ++= Seq("-encoding", "UTF-8")

lazy val akkaVersion = "2.6.10"
lazy val akkaHttpVersion = "10.2.1"

libraryDependencies ++= Seq(
    "com.typesafe.akka" %% "akka-actor" % akkaVersion,
    "com.typesafe.akka" %% "akka-stream" % akkaVersion,
    "com.typesafe.akka" %% "akka-http"  % akkaHttpVersion)
