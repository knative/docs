package com.example.hello

import io.ktor.application.*
import io.ktor.http.*
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main(args: Array<String>) {
    val target = System.getenv("TARGET") ?: "NOT SPECIFIED"
    embeddedServer(Netty, 8080) {
        routing {
            get("/") {
                call.respondText("Hello World: $target", ContentType.Text.Html)
            }
        }
    }.start(wait = true)
}
