(defproject helloworld "1.0.0-SNAPSHOT"
  :description "Hello World - Clojure sample"
  :dependencies [[org.clojure/clojure "1.12.6"]
                 [ring/ring-jetty-adapter "1.15.6"]]
  :main helloworld.core
  :uberjar-name "helloworld.jar")
