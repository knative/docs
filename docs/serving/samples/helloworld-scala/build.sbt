enablePlugins(JavaAppPackaging, DockerPlugin)

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

// Make sure that the application.conf and possibly other resources are included

import NativePackagerHelper._

mappings in Universal ++= directory( baseDirectory.value / "src" / "main" / "resources" )

// Inherit the package name
packageName in Docker := packageName.value

// Inherit the version
version in Docker := version.value

// Change this if you are changing which port to use in the app
dockerExposedPorts := Seq(8080)

// You can specify some other jdk Docker image here:
dockerBaseImage := "openjdk"

// If you want to supply specific JVM parameters, do that here:
// javaOptions in Universal ++= Seq()

// If you change this, set this to an email address in the format of: "Name <email adress>"
maintainer := ""

// To use your Docker Hub repository set this to "docker.io/yourusername/yourreponame".
// When using Minikube Docker Repository set it to "dev.local", if you set it to anything else
// then run the following command after `docker:publishLocal`:
//   `docker tag yourreponame/helloworld-scala:<version> dev.local/helloworld-scala:<version>`
dockerRepository := Some("your_repository_name")

// For more information about which Docker configuration options are available,
// see: https://www.scala-sbt.org/sbt-native-packager/formats/docker.html
