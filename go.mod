module github.com/knative/docs

go 1.18

require (
	cloud.google.com/go/storage v1.10.0
	github.com/cloudevents/sdk-go/v2 v2.2.0
	github.com/golang/protobuf v1.4.3
	github.com/google/go-github v17.0.0+incompatible
	github.com/google/go-github/v32 v32.1.0
	github.com/kelseyhightower/envconfig v1.4.0
	golang.org/x/net v0.7.0
	golang.org/x/oauth2 v0.0.0-20201208152858-08078c50e5b5
	google.golang.org/grpc v1.36.0
	gopkg.in/go-playground/webhooks.v3 v3.13.0
	gopkg.in/yaml.v2 v2.3.0
	knative.dev/hack v0.0.0-20230317131237-3b8ef01d7c4f
)

require (
	cloud.google.com/go v0.72.0 // indirect
	github.com/fsnotify/fsnotify v1.4.9 // indirect
	github.com/google/go-cmp v0.5.5 // indirect
	github.com/google/go-querystring v1.0.0 // indirect
	github.com/google/uuid v1.2.0 // indirect
	github.com/googleapis/gax-go/v2 v2.0.5 // indirect
	github.com/hashicorp/golang-lru v0.5.4 // indirect
	github.com/jstemmer/go-junit-report v0.9.1 // indirect
	github.com/lightstep/tracecontext.go v0.0.0-20181129014701-1757c391b1ac // indirect
	github.com/onsi/ginkgo v1.12.1 // indirect
	github.com/onsi/gomega v1.10.1 // indirect
	go.opencensus.io v0.23.0 // indirect
	go.uber.org/atomic v1.7.0 // indirect
	go.uber.org/multierr v1.6.0 // indirect
	go.uber.org/zap v1.16.0 // indirect
	golang.org/x/crypto v0.1.0 // indirect
	golang.org/x/lint v0.0.0-20200302205851-738671d3881b // indirect
	golang.org/x/mod v0.6.0-dev.0.20220419223038-86c51ed26bb4 // indirect
	golang.org/x/sys v0.5.0 // indirect
	golang.org/x/text v0.7.0 // indirect
	golang.org/x/tools v0.1.12 // indirect
	google.golang.org/api v0.36.0 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/genproto v0.0.0-20201214200347-8c77b98c765d // indirect
	google.golang.org/protobuf v1.25.0 // indirect
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	honnef.co/go/tools v0.0.1-2020.1.5 // indirect
)

replace go.opencensus.io => go.opencensus.io v0.20.2
