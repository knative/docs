/*
Copyright 2020 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#[macro_use]
extern crate log;

use actix_web::dev::HttpResponseBuilder;
use actix_web::http::StatusCode;
use actix_web::{post, web, App, HttpRequest, HttpResponse, HttpServer};
use cloudevents::{EventBuilder, EventBuilderV10};
use cloudevents_sdk_actix_web::{HttpRequestExt, HttpResponseBuilderExt};
use cloudevents_sdk_reqwest::RequestBuilderExt;

#[post("/")]
async fn reply_event(
    req: HttpRequest,
    payload: web::Payload,
) -> Result<HttpResponse, actix_web::Error> {
    let request_event = req.to_event(payload).await?;
    info!("{}", request_event);

    // Build response event cloning the original event and setting the new type and source
    let response_event = EventBuilderV10::from(request_event)
        .source("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-rust")
        .ty("dev.knative.docs.sample")
        .build()
        // If i can't build the event, fail with internal server error
        .map_err(actix_web::error::ErrorInternalServerError)?;

    HttpResponseBuilder::new(StatusCode::OK)
        .event(response_event)
        .await
}

#[post("/")]
async fn forward_event(
    req: HttpRequest,
    payload: web::Payload,
    sink_url: web::Data<String>,
) -> Result<HttpResponse, actix_web::Error> {
    let sink_url: &str = &sink_url;

    let request_event = req.to_event(payload).await?;
    info!("{}", request_event);

    // Build response event cloning the original event and setting the new type and source
    let forward_event = EventBuilderV10::from(request_event)
        .source("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-rust")
        .ty("dev.knative.docs.sample")
        .build()
        // If i can't build the event, fail with internal server error
        .map_err(actix_web::error::ErrorInternalServerError)?;

    let client = reqwest::Client::new();
    let response = client.post(sink_url)
        .event(forward_event)
        .map_err(actix_web::error::ErrorInternalServerError)?
        .send()
        .await
        // If something went wrong when sending the event, fail with internal server error
        .map_err(actix_web::error::ErrorInternalServerError)?;

    if response.status().is_success() {
        Ok(HttpResponseBuilder::new(StatusCode::ACCEPTED).finish())
    } else {
        Ok(
            HttpResponseBuilder::new(StatusCode::INTERNAL_SERVER_ERROR).body(format!(
                "Received from {} status code {}",
                sink_url,
                response.status().as_str()
            )),
        )
    }
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    // Setup logger
    std::env::set_var("RUST_LOG", "info");
    env_logger::init();

    // Get port from envs
    let port: u16 = std::env::var("PORT")
        .ok()
        .map(|e| e.parse().ok())
        .flatten()
        .unwrap_or(8080);

    // Create the HTTP server
    HttpServer::new(|| {
        let app_base = App::new().wrap(actix_web::middleware::Logger::default());

        // Get k_sink env
        let k_sink = std::env::var("K_SINK").ok();

        // If k_sink is configured, then we start the app in forward mode
        // Otherwise, we set it in reply mode
        match k_sink {
            Some(sink) => app_base.data(sink).service(forward_event),
            None => app_base.service(reply_event),
        }
    })
    .bind(("127.0.0.1", port))?
    .workers(1)
    .run()
    .await
}
