organization := "Scala & Akka Examples for Knative Serving"

name := "helloworld-scala"

version := "0.0.1"

scalaVersion := "2.12.8"

mainClass in Compile := Some("klang.HelloWorldScala")

scalacOptions ++= Seq("-encoding", "UTF-8")

lazy val akkaVersion = "2.5.16"
lazy val akkaHttpVersion = "10.1.5"

libraryDependencies ++= Seq(
    "com.typesafe.akka" %% "akka-actor" % akkaVersion,
    "com.typesafe.akka" %% "akka-stream" % akkaVersion,
    "com.typesafe.akka" %% "akka-http"  % akkaHttpVersion)
