(ns helloworld.core
  (:use ring.adapter.jetty)
  (:gen-class))

(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body (str "Hello World: "
              (if-let [target (System/getenv "TARGET")]
                target
                "NOT SPECIFIED")
              "!\n")})

(defn -main [& args]
  (run-jetty handler {:port 8080}))
