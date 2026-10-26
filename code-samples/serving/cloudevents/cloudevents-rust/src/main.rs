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

use actix_web::{post, web, App, HttpRequest, HttpResponse, HttpServer};
use cloudevents::binding::actix::{HttpRequestExt, HttpResponseBuilderExt};
use cloudevents::binding::reqwest::RequestBuilderExt;
use cloudevents::{EventBuilder, EventBuilderV10};
use std::time::Duration;

const SOURCE: &str =
    "https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-rust";
const EVENT_TYPE: &str = "dev.knative.docs.sample";

struct AppState {
    sink: Option<String>,
    client: reqwest::Client,
}

impl AppState {
    fn new(sink: Option<String>) -> Result<Self, reqwest::Error> {
        Ok(Self {
            // An explicitly empty K_SINK is equivalent to an unset K_SINK.
            sink: sink.filter(|url| !url.is_empty()),
            client: reqwest::Client::builder()
                .timeout(Duration::from_secs(30))
                .build()?,
        })
    }
}

fn port(value: Option<String>) -> u16 {
    value.and_then(|value| value.parse().ok()).unwrap_or(8080)
}

#[post("/")]
async fn handle_event(
    req: HttpRequest,
    payload: web::Payload,
    state: web::Data<AppState>,
) -> Result<HttpResponse, actix_web::Error> {
    let request_event = req.to_event(payload).await?;
    log::info!("{}", request_event);

    // Preserve the original event's ID, data, and extensions; change only source and type.
    let response_event = EventBuilderV10::from(request_event)
        .source(SOURCE)
        .ty(EVENT_TYPE)
        .build()
        .map_err(actix_web::error::ErrorInternalServerError)?;

    if let Some(sink) = &state.sink {
        let response = state
            .client
            .post(sink)
            .event(response_event)
            .map_err(actix_web::error::ErrorInternalServerError)?
            .send()
            .await
            .map_err(actix_web::error::ErrorInternalServerError)?;

        if response.status().is_success() {
            Ok(HttpResponse::Accepted().finish())
        } else {
            Ok(HttpResponse::InternalServerError().body(format!(
                "Received from {} status code {}",
                sink,
                response.status().as_str()
            )))
        }
    } else {
        HttpResponse::Ok().event(response_event)
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();
    let port = port(std::env::var("PORT").ok());
    let state =
        web::Data::new(AppState::new(std::env::var("K_SINK").ok()).map_err(std::io::Error::other)?);

    HttpServer::new(move || {
        App::new()
            .app_data(state.clone())
            .wrap(actix_web::middleware::Logger::default())
            .service(handle_event)
    })
    .bind(("0.0.0.0", port))?
    .workers(1)
    .run()
    .await
}
