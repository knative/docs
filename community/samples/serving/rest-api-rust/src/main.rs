#![feature(proc_macro_hygiene, decl_macro)]
#[macro_use] extern crate rocket;
use rocket::http::{RawStr, Status};

#[get("/?<name>&<age>")]
fn hello(name: Option<&RawStr>, age: Option<u8>) -> String {
  let mut res = String::from("Hello");

  if let Some(name) = name {
    res = format!("{} {}", res, name.as_str());
  }

  if let Some(age) = age {
    res = format!("{}, you are {} years old", res, age);
  }

  format!("{}.", res)
}

#[get("/coffee")]
fn coffee() -> Status {
  Status::ImATeapot
}

fn main() {
  rocket::ignite()
    .mount("/", routes![hello, coffee])
    .launch();
}
