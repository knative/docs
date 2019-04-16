package com.example.hello

import io.ktor.application.*
import io.ktor.http.*
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main(args: Array<String>) {
    val target = System.getenv("TARGET") ?: "World"
    val port = System.getenv("PORT") ?: "8080"
    embeddedServer(Netty, port.toInt()) {
        routing {
            get("/") {
                call.respondText("Hello $target!", ContentType.Text.Html)
            }
        }
    }.start(wait = true)
}