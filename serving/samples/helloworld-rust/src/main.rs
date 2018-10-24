#![deny(warnings)]
extern crate hyper;
extern crate pretty_env_logger;

use hyper::{Body, Response, Server};
use hyper::service::service_fn_ok;
use hyper::rt::{self, Future};
use std::env;

fn main() {
    pretty_env_logger::init();

    let mut port: u16 = 8080;
    match env::var("PORT") {
        Ok(p) => {
            match p.parse::<u16>() {
                Ok(n) => {port = n;},
                Err(_e) => {},
            };
        }
        Err(_e) => {},
    };
    let addr = ([0, 0, 0, 0], port).into();

    let new_service = || {
        service_fn_ok(|_| {

            let mut hello = "Hello ".to_string();
            match env::var("TARGET") {
                Ok(target) => {hello.push_str(&target);},
                Err(_e) => {hello.push_str("World")},
            };

            Response::new(Body::from(hello))
        })
    };

    let server = Server::bind(&addr)
        .serve(new_service)
        .map_err(|e| eprintln!("server error: {}", e));

    println!("Listening on http://{}", addr);

    rt::run(server);
}