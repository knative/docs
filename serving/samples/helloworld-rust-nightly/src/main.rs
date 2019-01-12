#![feature(proc_macro_hygiene, decl_macro)]
  #[macro_use] extern crate rocket;
  use std::env;

  #[get("/")]
  fn hello() -> String {
    let mut res = String::from("Hello ");

    match env::var("TARGET") {
      Ok(target) => {res.push_str(&target);},
      Err(_e) => {res.push_str("World")},
    };

    res
  }

  fn main() {
    rocket::ignite()
      .mount("/", routes![hello])
      .launch();
  }
  