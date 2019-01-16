(ns helloworld.core
  (:use ring.adapter.jetty)
  (:gen-class))

(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body (str "Hello "
              (if-let [target (System/getenv "TARGET")]
                target
                "World")
              "!\n")})

(defn -main [& args]
  (run-jetty handler {:port (if-let [port (System/getenv "PORT")]
                              (Integer/parseInt port)
                              8080)}))
