module github.com/knative/docs

go 1.14

require (
	cloud.google.com/go/storage v1.10.0
	github.com/cloudevents/sdk-go/v2 v2.2.0
	github.com/eclipse/paho.mqtt.golang v1.1.1
	github.com/form3tech-oss/jwt-go v3.2.2+incompatible
	github.com/golang/protobuf v1.4.2
	github.com/google/go-github v17.0.0+incompatible
	github.com/google/uuid v1.1.1
	github.com/kelseyhightower/envconfig v1.4.0
	golang.org/x/net v0.0.0-20200904194848-62affa334b73
	golang.org/x/oauth2 v0.0.0-20200107190931-bf48bf16ab8d
	google.golang.org/grpc v1.31.1
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	gopkg.in/go-playground/webhooks.v3 v3.13.0
	gopkg.in/yaml.v2 v2.3.0
	knative.dev/net-istio v0.18.1-0.20201021044017-91100a5459fb
	knative.dev/test-infra v0.0.0-20201021201032-c3d2f3850008
)

replace go.opencensus.io => go.opencensus.io v0.20.2
