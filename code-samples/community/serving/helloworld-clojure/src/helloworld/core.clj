(ns helloworld.core
  (:require [ring.adapter.jetty :as jetty])
  (:gen-class))

(defn handler [_request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body (str "Hello " (or (System/getenv "TARGET") "World") "!\n")})

(defn -main [& _args]
  (jetty/run-jetty handler
                   {:port (Integer/parseInt (or (System/getenv "PORT") "8080"))}))
