(ns hello-world.core
  (:gen-class)
  (:use ring.adapter.jetty))

(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Hello World"})

(defn -main []
  (run-jetty handler {:port 8080}))
