module github.com/knative/docs

go 1.14

require (
	cloud.google.com/go/storage v1.10.0
	github.com/cloudevents/sdk-go/v2 v2.2.0
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/eclipse/paho.mqtt.golang v1.1.1
	github.com/golang/protobuf v1.4.2
	github.com/google/go-github v17.0.0+incompatible
	github.com/kelseyhightower/envconfig v1.4.0
	github.com/openzipkin/zipkin-go v0.2.2
	github.com/satori/go.uuid v1.2.0
	go.opencensus.io v0.22.4
	golang.org/x/net v0.0.0-20200904194848-62affa334b73
	golang.org/x/oauth2 v0.0.0-20200107190931-bf48bf16ab8d
	google.golang.org/grpc v1.31.1
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	gopkg.in/go-playground/webhooks.v3 v3.13.0
	gopkg.in/yaml.v2 v2.3.0
	knative.dev/net-istio v0.18.1-0.20201012033616-9e988bf8ae1b
	knative.dev/test-infra v0.0.0-20201009204121-322fb08edae7
)

replace go.opencensus.io => go.opencensus.io v0.20.2
