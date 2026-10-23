---
audience: developer
components:
  - functions
  - serving
  - eventing
function: explanation
---

# 어떤 Knative 컴포넌트를 사용해야 할까요?

Knative는 쿠버네티스(Kubernetes) 위에서 애플리케이션 배포를 단순화해주는 프로젝트입니다. Knative 프로젝트는 몇 가지 컴포넌트로 구성되어 있습니다. 이 문서의 목적은 각 컴포넌트를 설명하고, 어떤 상황에 어떤 컴포넌트를 사용해야 하는지 안내하는 것입니다.


## Knative Serving

[Knative Serving](https://knative.dev/docs/serving/)은 쿠버네티스 사용자 정의 리소스(Custom Resource Definitions, CRD) 형태로 여러 오브젝트를 정의합니다. 이 리소스들은 클러스터에서 서버리스 워크로드가 어떻게 동작할지 정의하고 제어하는 데 사용됩니다.

간단히 말해, 사용자는 Knative Serving을 이용해 쿠버네티스 위에 컨테이너화된 애플리케이션을 배포할 수 있습니다. Knative Serving 컴포넌트는 트래픽 라우팅, 오토스케일링, 리비전 추적, 보안 및 기타 설정을 처리합니다. 이를 통해 쿠버네티스를 직접 다루지 않아도 될 정도로 애플리케이션 배포를 쉽게 만들어줍니다.

Knative Serving은 애플리케이션에 가장 적합하며, 다음과 같은 예시가 있습니다.

- 프론트엔드 웹 애플리케이션
- 백엔드 서비스
- 배치 프로세스
- API 서빙
- AI 추론(Inferencing)

주목할 점은, 이러한 서비스들은 대부분 엔드포인트가 필요하다는 것입니다. HTTP/S가 가장 일반적인 프로토콜이지만, [gRPC를 사용하는 방법](https://github.com/knative/docs/tree/main/code-samples/serving/grpc-ping-go)도 존재합니다.

간단히 판단하는 방법은 여러분의 서비스가 HTTP 요청으로 호출되는지를 묻는 것입니다. 그렇다면 Knative Serving이 적합한 컴포넌트입니다.



## Knative Eventing

[Knative Eventing](https://knative.dev/docs/eventing/)은 [이벤트 기반 아키텍처(event-driven architecture)](https://en.wikipedia.org/wiki/Event-driven_architecture)를 애플리케이션에 적용할 수 있게 해주는 API 모음입니다. 이 API를 사용하면 이벤트 생산자(소스, source)로부터 이벤트 소비자(싱크, sink)로 이벤트를 라우팅하는 컴포넌트를 만들 수 있습니다.

Knative Eventing을 사용하면 개발자는 이벤트 소스와 소비자 간의 바인딩을 단순화할 수 있습니다. 이는 여러분의 서비스와 연결해야 하는 이벤트 소스 사이의 추상화 계층 역할을 합니다.

현재 지원되는 이벤트 소스는 다음과 같습니다.

- [API Server Source](https://knative.dev/docs/eventing/sources/apiserversource/)
- [Apache CouchDB](https://couchdb.apache.org/)
- [Apache Kafka](https://kafka.apache.org/)
- [Ceph](https://ceph.io)
- [ContainerSource](https://knative.dev/docs/eventing/custom-event-source/containersource/)
- [GitHub](https://github.com)
- [GitLab](https://gitlab.com)
- [Kogito](https://kogito.kie.org/)
- [PingSource](https://knative.dev/docs/eventing/sources/ping-source/)
- [RabbitMQ](https://rabbitmq.com)
- [Redis](https://redis.io)
- [SinkBinding](https://knative.dev/docs/eventing/custom-event-source/sinkbinding/)

이 외에도 다양한 서드파티 소스를 [여기](https://knative.dev/docs/eventing/sources/#third-party-sources)에서 확인할 수 있습니다.

Knative Eventing은 애플리케이션 자체를 위한 것이 아니라, 이벤트 생산자와 소비자를 선언적으로 연결하기 위한 것입니다. 예를 들어 [Python Flask](https://flask.palletsprojects.com/en/3.0.x/) 애플리케이션을 호스팅하는 용도로는 Knative Eventing을 사용하지 않습니다.

이벤트 소스를 애플리케이션에 선언적으로 연결하고 싶다면 Knative Eventing을 사용하게 됩니다. 특히 위에서 언급한 애플리케이션들을 메시지 큐나 데이터베이스로 사용하고 있다면 Eventing을 사용하게 됩니다.

## Knative Functions
Knative에 새롭게 추가된 것이 [Knative Functions](https://knative.dev/docs/functions/)입니다. 이는 [FaaS(Function-as-a-Service)](https://en.wikipedia.org/wiki/Function_as_a_service) 방식에 더 익숙한 개발자를 위한 기능입니다.

컨테이너화를 배우는 것은 누군가에게는 학습 곡선이 될 수 있는데, Knative Functions는 개발자가 오직 코드에만 집중할 수 있도록 해줍니다. 내부적으로는 여전히 쿠버네티스이기 때문에, 플랫폼 엔지니어는 여전히 자유롭게 플랫폼을 설계할 수 있습니다.

내부적으로 여전히 쿠버네티스이기 때문에, [OCI(Open Container Initiative)](https://opencontainers.org/about/overview/) 형식의 컨테이너가 생성되고 배포됩니다. 핵심은 Knative Functions의 추상화가 이 컨테이너의 생성과 배포 과정을 자동화한다는 점입니다.

이 방식은 개발자가 OCI 컨테이너에 익숙하지 않거나, 개발자가 Knative나 쿠버네티스와 관련된 다른 요소보다 코드 작성에만 집중하기를 원하는 경우에 가장 적합합니다.
