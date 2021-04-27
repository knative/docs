module github.com/knative/docs

go 1.14

require (
	cloud.google.com/go/storage v1.10.0
	github.com/cloudevents/sdk-go/v2 v2.2.0
	github.com/eclipse/paho.mqtt.golang v1.1.1
	github.com/form3tech-oss/jwt-go v3.2.2+incompatible
	github.com/fsnotify/fsnotify v1.4.9 // indirect
	github.com/golang/protobuf v1.4.3
	github.com/google/go-cmp v0.5.5 // indirect
	github.com/google/go-github v17.0.0+incompatible
	github.com/google/go-querystring v1.0.0 // indirect
	github.com/google/uuid v1.2.0
	github.com/hashicorp/golang-lru v0.5.4 // indirect
	github.com/kelseyhightower/envconfig v1.4.0
	github.com/onsi/gomega v1.10.1 // indirect
	go.opencensus.io v0.23.0 // indirect
	go.uber.org/multierr v1.6.0 // indirect
	go.uber.org/zap v1.16.0 // indirect
	golang.org/x/net v0.0.0-20201209123823-ac852fbbde11
	golang.org/x/oauth2 v0.0.0-20201208152858-08078c50e5b5
	golang.org/x/sys v0.0.0-20201214210602-f9fddec55a1e // indirect
	golang.org/x/tools v0.0.0-20210106214847-113979e3529a // indirect
	google.golang.org/api v0.36.0 // indirect
	google.golang.org/genproto v0.0.0-20201214200347-8c77b98c765d // indirect
	google.golang.org/grpc v1.36.0
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	gopkg.in/go-playground/webhooks.v3 v3.13.0
	gopkg.in/yaml.v2 v2.3.0
	honnef.co/go/tools v0.0.1-2020.1.5 // indirect
	knative.dev/hack v0.0.0-20210426064739-88c69cd1eca7
)

replace go.opencensus.io => go.opencensus.io v0.20.2
