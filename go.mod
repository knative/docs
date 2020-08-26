module github.com/knative/docs

go 1.14

require (
	cloud.google.com/go v0.55.0 // indirect
	cloud.google.com/go/storage v1.6.0
	github.com/cloudevents/sdk-go/v2 v2.2.0
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/eclipse/paho.mqtt.golang v1.1.1
	github.com/golang/protobuf v1.3.5
	github.com/google/go-github v17.0.0+incompatible
	github.com/google/go-querystring v1.0.0 // indirect
	github.com/google/martian v2.1.1-0.20190517191504-25dcb96d9e51+incompatible // indirect
	github.com/gorilla/mux v1.7.3 // indirect
	github.com/hashicorp/golang-lru v0.5.4 // indirect
	github.com/kelseyhightower/envconfig v1.4.0
	github.com/onsi/ginkgo v1.11.0 // indirect
	github.com/onsi/gomega v1.8.1 // indirect
	github.com/openzipkin/zipkin-go v0.2.2
	github.com/prometheus/client_golang v1.5.0 // indirect
	github.com/prometheus/procfs v0.0.11 // indirect
	github.com/satori/go.uuid v1.2.0
	go.opencensus.io v0.22.4
	go.uber.org/zap v1.14.1 // indirect
	golang.org/x/net v0.0.0-20200324143707-d3edc9973b7e
	golang.org/x/oauth2 v0.0.0-20200107190931-bf48bf16ab8d
	golang.org/x/sys v0.0.0-20200327173247-9dae0f8f5775 // indirect
	golang.org/x/tools v0.0.0-20200329025819-fd4102a86c65 // indirect
	google.golang.org/genproto v0.0.0-20200326112834-f447254575fd // indirect
	google.golang.org/grpc v1.28.0
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	gopkg.in/go-playground/webhooks.v3 v3.13.0
	gopkg.in/yaml.v2 v2.2.8
	knative.dev/test-infra/scripts v0.0.0-20200610004422-8b4a5283a123
)

replace go.opencensus.io => go.opencensus.io v0.20.2
